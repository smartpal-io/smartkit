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

    constructor() public{
        addAddressToWhitelist(msg.sender);
    }

    /**
    * @dev Add a room
    */
    function addRoom(bytes32 _id, uint256 _capacity) public onlyOwner() nonZeroBytes32(_id) nonZeroUint256(_capacity) {
        // check if a room with same id already added
        require(!rooms[_id].initialized);
        rooms[_id] = Room({
            id : _id,
            capacity : _capacity,
            status : Status.FREE,
            bookedBy : address(0x0),
            bookedFrom : 0,
            bookedUntil : 0,
            initialized : true
            });
    }

    /**
    * @dev Book a room
    * @param _id the identifier of the room to book
    * @param _from the timestamp when to start the booking
    * @param _until the timestamp when to start the booking
    * The sender of the message must be whitelisted to book a room
    * The room must be available at this time slot
    */
    function book(bytes32 _id, uint256 _from, uint256 _until) public onlyWhitelisted() onlyIfGreater(_from, _until) {
        // check if the room exists
        require(rooms[_id].initialized);
        checkAvailability(rooms[_id], _from, _until);
        internalBook(rooms[_id], msg.sender, _from, _until);
    }

    /**
    * @dev Free a booked room before the end of the booking
    * Throws if the sender address does not match the bookedBy address
    */
    function free(bytes32 _id) public onlyWhitelisted() {
        // check if the room exists
        require(rooms[_id].initialized);
        require(rooms[_id].bookedBy == msg.sender);
        internalFree(rooms[_id]);
    }

    /**
    * Check the availability of a given room at a given time
    * @param _from the timestamp when to start the booking
    * @param _until the timestamp when to start the booking
    * Throws if the room is not available
    */
    function checkAvailability(Room room, uint _from, uint _until) internal onlyNotLocked(room.status) {
        if (!isAvailable(room)) {
            // check if booking limit reached
            if (now >= room.bookedUntil) {
                internalFree(room);
            } else {
                revert();
            }
        }
    }

    function isAvailable(Room room) internal pure returns (bool){
        return room.status == Status.FREE;
    }

    function internalBook(Room room, address _by, uint256 _from, uint256 _until) internal onlyNotLocked(room.status) {
        room.status = Status.BOOKED;
        room.bookedFrom = _from;
        room.bookedUntil = _until;
        room.bookedBy = _by;
    }

    function internalFree(Room room) internal onlyNotLocked(room.status) {
        room.status = Status.FREE;
        room.bookedFrom = 0;
        room.bookedUntil = 0;
        room.bookedBy = 0x0;
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
    * @dev Throws if zero
    */
    modifier nonZeroBytes32(bytes32 value){
        require(value != bytes32(value));
        _;
    }

    /**
    * @dev Throws if zero
    */
    modifier nonZeroUint256(uint256 value){
        require(value != uint256(value));
        _;
    }
}