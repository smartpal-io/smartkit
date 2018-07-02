pragma solidity ^0.4.24;

import "../openzeppelin-solidity/Whitelist.sol";

/**
 * @title RoomBookingService
 * @dev RoomBookingService allows users to manage room booking
 * @dev See the tests RoomBookingService.test.js for specific usage examples.
 */
contract RoomBookingService is Whitelist {
    
    uint constant maxRoomBooking = 10;

    // contract data
    mapping(bytes32 => Room) private rooms;

    // definition of the Room structure
    struct Room {
        bytes32 id; // unique identifier of the room
        uint256 capacity; // the capacity of the room (e.g number of persons it can contains inside)
        mapping (uint => Booking) bookings;
        uint numberOfBookings;
        bool initialized; // utility boolean to check the presence of a room in the rooms mapping
    }
    
    struct Booking{
        address bookedBy; // the address which have booked the room
        uint256 bookedFrom; // timestamp when the booking starts, equals to 0 if not booked
        uint256 bookedUntil; // timestamp when the booking ends, equals to 0 if not booked
        bool initialized; // utility boolean to check the presence
    }

    // triggered when a room is added
    event LogRoomAdded(bytes32 roomId, uint256 capacity);
    // triggered when a room is booked
    event LogRoomBooked(bytes32 roomId, address by);
    // triggered when a room is freed
    event LogRoomFreed(bytes32 roomId, address by);
    event LogSlotAvailable(bytes32 roomId, uint slot);


    constructor() public{
        addAddressToWhitelist(msg.sender);
    }

    /**
    * @dev Add a room
    * @param _roomId the identifier of the room
    * @param _capacity the capacity of the room
    */
    function addRoom(bytes32 _roomId, uint256 _capacity)
        onlyOwner
        nonZeroBytes32(_roomId)
        nonZeroUint256(_capacity)
        public
    {
        // check if a room with same id already added
        require(!rooms[_roomId].initialized);
        rooms[_roomId] = Room({
            id : _roomId,
            capacity : _capacity,
            numberOfBookings: 0,
            initialized : true
            });
        emit LogRoomAdded(_roomId, _capacity);
    }
    
    /**
    * @dev Return if the room is available in given interval
    * @param _roomId the identifier of the room
    * @param _from the starting timestamp
    * @param _until the ending timestamp
    */
    function isRoomAvailable(bytes32 _roomId, uint256 _from, uint256 _until)
        public
        view
        returns (bool)
    {
        // check if the room exists
        require(rooms[_roomId].initialized);
        return isAvailableInRange(_roomId, _from, _until);
    }

    
    /**
    * @dev Book a room
    * @param _roomId the identifier of the room to book
    * @param _from the timestamp when to start the booking
    * @param _until the timestamp when to start the booking
    * The sender of the message must be whitelisted to book a room
    * The room must be available at this time slot
    */
    function book(bytes32 _roomId, uint256 _from, uint256 _until)
        onlyWhitelisted
        onlyIfGreater(_from, _until)
        onlyInFuture(_from)
        public
    {
        // check if the room exists
        require(rooms[_roomId].initialized);
        // check if the room is available at this timeslot
        if(!isAvailableInRange(_roomId, _from, _until)){
            revert();
        }
        
        uint availableSlot = getFirstAvailableSlot(_roomId);
        internalBook(_roomId, availableSlot, msg.sender, _from, _until);
        
        emit LogRoomBooked(_roomId, msg.sender);
    }

    function getNumberOfBookings(bytes32 _roomId )
    onlyWhitelisted
    view
    public
    returns (uint)
    {
        // check if the room exists
        require(rooms[_roomId].initialized);
        return rooms[_roomId].numberOfBookings;
    }

    
    /*/**
    * @dev Free a booked room before the end of the booking
    * Throws if the sender address does not match the bookedBy address
    function free(bytes32 _roomId)
        onlyWhitelisted
        public
    {
        // check if the room exists
        require(rooms[_roomId].initialized);
        require(rooms[_roomId].bookedBy == msg.sender);
        internalFree(_roomId);
        emit LogRoomFreed(_roomId, msg.sender);
    }*/
    
    
    function hasAvailableSlot(Room room)
    pure
    internal
    returns (bool)
    {
        return room.numberOfBookings < maxRoomBooking;
    }

    function isAvailableInRange(bytes32 _roomId, uint256 _from, uint256 _until)
        view
        internal
        returns (bool)
    {
        if(!hasAvailableSlot(rooms[_roomId])){
            return false;
        }
        
        if(rooms[_roomId].numberOfBookings == 0){
            return true;
        }
        
        for(uint i = 0; i < rooms[_roomId].numberOfBookings; i++){
            if(!isOverlap(rooms[_roomId].bookings[i].bookedFrom, rooms[_roomId].bookings[i].bookedUntil, _from, _until)){
                return true;
            }
        }
        return false;
        
    }
    
    function getFirstAvailableSlot(bytes32 _roomId)
        view
        internal
        returns (uint)
    {
        if(rooms[_roomId].numberOfBookings == 0){
            return 0;
        }
        for(uint i = 0; i < rooms[_roomId].numberOfBookings; i++){
            if(rooms[_roomId].bookings[i].bookedFrom == 0 && rooms[_roomId].bookings[i].bookedUntil == 0){
                return i;
            }
        }  
        // throw if no slot available for this room
        revert();
    }
    


    function internalBook(bytes32 _roomId, uint slot, address _by, uint256 _from, uint256 _until)
        internal
    {
        rooms[_roomId].bookings[slot].bookedFrom = _from;
        rooms[_roomId].bookings[slot].bookedUntil = _until;
        rooms[_roomId].bookings[slot].bookedBy = _by;
        rooms[_roomId].numberOfBookings++;
    }

    /*function internalFree(bytes32 _roomId)
        internal
    {
        rooms[_roomId].bookedFrom = 0;
        rooms[_roomId].bookedUntil = 0;
        rooms[_roomId].bookedBy = 0x0;
    }*/


    /**
    * @dev Check if there is an overlap given two inclusive integer ranges [x1:x2] and [y1:y2], where x1 ≤ x2 and y1 ≤ y2
    */
    function isOverlap(uint256 x1, uint256 x2, uint256 y1, uint256 y2)
        internal
        pure
        returns (bool)
    {
        return x1 <= y2 && y1 <= x2;
    }

    /**
     * @dev Throws if max is not strictly greater than min
     */
    modifier onlyIfGreater(uint256 min, uint256 max){
        require(max > min);
        _;
    }


    /**
     * @dev Throws if the status is LOCKED
     */
    modifier onlyInFuture(uint256 date){
        require(date > now);
        _;
    }

    /**
    * @dev Throws if zero
    */
    modifier nonZeroBytes32(bytes32 value){
        require(value != bytes32(0x00));
        _;
    }

    /**
    * @dev Throws if zero
    */
    modifier nonZeroUint256(uint256 value){
        require(value != uint256(0));
        _;
    }
}