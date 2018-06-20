pragma solidity ^0.4.24;

import "../openzeppelin-solidity/Whitelist.sol";

/**
 * @title Traceable
 * @dev Helps manage the traceability of a product
 * @dev See the tests Traceability.test.js for specific usage examples.
 */
contract Traceable is Whitelist {

    //product id
    string id;

    // raw materials used in this product
    address [] private rawMaterials;

    // historical product positions
    Position [] private historicalPositions;

    // definition of the Position structure
    struct Position {
        uint256 date;
        string latitude;
        string longitude;
        address sender;
    }

    constructor(string _id) public{
        id = _id;
        addAddressToWhitelist(msg.sender);
    }

    /**
    * @dev Add a raw material
    */
    function addRawMaterial(address _rawMaterial) public onlyWhitelisted() nonEmptyAddress(_rawMaterial) {
        rawMaterials.push(_rawMaterial);
    }

    /**
    * @dev Add a step
    */
    function addStep(uint256 _date, string _latitude, string _longitude) public onlyWhitelisted()
    nonZeroUint256(_date) nonEmptyString(_latitude) nonEmptyString(_longitude) {
        // check if a room with same id already added
        historicalPositions.push(Position({
            date : _date,
            latitude : _latitude,
            longitude : _longitude,
            sender : msg.sender
            })
        );
    }


    /**
    * @dev Throws if zero
    */
    modifier nonZeroUint256(uint256 value){
        require(value != uint256(value));
        _;
    }

    /**
    * @dev Throws if empty
    */
    modifier nonEmptyString(string value){
        require(bytes(value).length != 0);
        _;
    }

    /**
    * @dev Throws if empty
    */
    modifier nonEmptyAddress(address value){
        require(value != address(0));
        _;
    }
}