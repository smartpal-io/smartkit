pragma solidity ^0.4.24;

import "../openzeppelin-solidity/Whitelist.sol";

/**
 * @title RoomBookingService
 * @dev RoomBookingService allows users to manage room booking
 * @dev See the tests RoomBookingService.test.js for specific usage examples.
 */
contract RoomBookingService is Whitelist {

    // contract data
    mapping(bytes32 => Room) private rooms;

    // possible status of a room
    enum Status {FREE, BOOKED, LOCKED}

    // definition of the Room structure
    struct Room {
        bytes32 id; // unique identifier of the room
        uint256 capacity; // the capacity of the room (e.g number of persons it can contains inside)
        Status status;
        address bookedBy; // the address which have booked the room
        uint256 bookedFrom; // timestamp when the booking starts, equals to 0 if not booked
        uint256 bookedUntil; // timestamp when the booking ends, equals to 0 if not booked
        bool initialized; // utility boolean to check the presence of a room in the rooms mapping
    }

    event LogRoomAdded(bytes32  roomId, uint256 capacity);
    event LogRoomBooked(bytes32  roomId, address by);
    event LogRoomFreed(bytes32  roomId, address by);


    constructor() public{
        addAddressToWhitelist(msg.sender);
    }

    /**
    * @dev Add a room
    */
    function addRoom(bytes32 _roomId, uint256 _capacity) public onlyOwner() nonZeroBytes32(_roomId) nonZeroUint256(_capacity) {
        // check if a room with same id already added
        require(!rooms[_roomId].initialized);
        rooms[_roomId] = Room({
            id : _roomId,
            capacity : _capacity,
            status : Status.FREE,
            bookedBy : address(0x0),
            bookedFrom : 0,
            bookedUntil : 0,
            initialized : true
            });
        emit LogRoomAdded(_roomId, _capacity);
    }

    /**
    * @dev Get room status
    */
    function getRoomStatus(bytes32 _roomId) public view returns (uint){
        // check if the room exists
        require(rooms[_roomId].initialized);
        return uint(rooms[_roomId].status);
    }

    /**
    * @dev Book a room
    * @param _roomId the identifier of the room to book
    * @param _from the timestamp when to start the booking
    * @param _until the timestamp when to start the booking
    * The sender of the message must be whitelisted to book a room
    * The room must be available at this time slot
    */
    function book(bytes32 _roomId, uint256 _from, uint256 _until) public onlyWhitelisted() onlyIfGreater(_from, _until) onlyInFuture(_from){
        // check if the room exists
        require(rooms[_roomId].initialized);
        checkAvailability(_roomId, _from, _until);
        internalBook(_roomId, msg.sender, _from, _until);
        emit LogRoomBooked(_roomId, msg.sender);
    }

    /**
    * @dev Free a booked room before the end of the booking
    * Throws if the sender address does not match the bookedBy address
    */
    function free(bytes32 _roomId) public onlyWhitelisted() {
        // check if the room exists
        require(rooms[_roomId].initialized);
        require(rooms[_roomId].bookedBy == msg.sender);
        internalFree(_roomId);
        emit LogRoomFreed(_roomId, msg.sender);
    }

    /**
    * Check the availability of a given room at a given time
    * @param _from the timestamp when to start the booking
    * @param _until the timestamp when to start the booking
    * Throws if the room is not available
    */
    function checkAvailability(bytes32 _roomId, uint256 _from, uint256 _until) internal onlyNotLocked(rooms[_roomId].status) {
        if (!isAvailableInRange(rooms[_roomId], _from, _until)) {
            // check if booking limit reached
            if (now >= rooms[_roomId].bookedUntil) {
                // force freeing the room if the booked until limit expired
                internalFree(_roomId);
            } else {
                revert();
            }
        }
    }

    function isAvailableInRange(Room room, uint256 _from, uint256 _until) internal pure returns (bool){
        if( room.status == Status.FREE && room.bookedFrom == 0 && room.bookedUntil == 0){
            return true;
        }
        else{
            return !isOverlap(room.bookedFrom, room.bookedUntil, _from, _until);
        }
    }


    function internalBook(bytes32 _roomId, address _by, uint256 _from, uint256 _until) internal onlyNotLocked(rooms[_roomId].status) {
        rooms[_roomId].status = Status.BOOKED;
        rooms[_roomId].bookedFrom = _from;
        rooms[_roomId].bookedUntil = _until;
        rooms[_roomId].bookedBy = _by;
    }

    function internalFree(bytes32 _roomId) internal onlyNotLocked(rooms[_roomId].status) {
        rooms[_roomId].status = Status.FREE;
        rooms[_roomId].bookedFrom = 0;
        rooms[_roomId].bookedUntil = 0;
        rooms[_roomId].bookedBy = 0x0;
    }


    /**
    * @dev Check if there is an overlap given two inclusive integer ranges [x1:x2] and [y1:y2], where x1 ≤ x2 and y1 ≤ y2
    */
    function isOverlap(uint256 x1, uint256 x2, uint256 y1, uint256 y2) internal pure returns(bool){
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
    modifier onlyNotLocked(Status _status){
        require(_status != Status.LOCKED);
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