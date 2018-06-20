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

    enum Status {FREE, BOOKED, LOCKED}

    // definition of the Room structure
    struct Room {
        bytes32 id; // unique identifier of the room
        uint256 capacity; // the capacity of the room (e.g number of persons it can contains inside)
        Status status;
        address bookedBy; // the address which have booked the room
        uint256 bookedFrom; // timestamp when the booking starts, equals to 0 if not booked
        uint256 bookedUntil; // timestamp when the booking ends, equals to 0 if not booked
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

    constructor() public{
        addAddressToWhitelist(msg.sender);
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

    }

    /**
    * @dev Free a booked room before the end of the booking
    * Throws if the sender address does not match the bookedBy address
    */
    function free(bytes32 _id) public onlyWhitelisted()  {
        Room room = rooms[_id];
    }

    /**
    * Check the availability of a given room at a given time
    * @param _from the timestamp when to start the booking
    * @param _until the timestamp when to start the booking
    * Throws if the room is not available
    */
    function checkAvailability(Room room, uint _from, uint _until) internal onlyNotLocked(room.status) {

    }

    function isAvailable(Room room) internal returns (bool){
        return room.status == Status.FREE;
    }

    function free(Room room) internal onlyNotLocked(room.status) {
        room.status = Status.FREE;
        room.bookedFrom = 0;
        room.bookedUntil = 0;
        room.bookedBy = 0x0;
    }
}