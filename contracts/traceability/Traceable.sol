pragma solidity ^0.4.24;

import "../openzeppelin-solidity/Whitelist.sol";

/**
 * @title Traceable
 * @dev Helps manage the traceability of a product
 * @dev See the tests Traceable.test.js for specific usage examples.
 */
contract Traceable is Whitelist {

    //product id
    bytes32 id;

    // raw materials used in this product
    address [] private rawMaterials;

    // historical product positions
    Position [] private historicalPositions;

    // definition of the Position structure
    struct Position {
        uint256 timestamp;
        uint256 latitude;
        uint256 longitude;
        address sender;
    }

    event LogRawMaterialAdded(address sender, address rawMaterial);
    event LogNewPositionAdded(address sender, uint256 _date);

    constructor(bytes32 _id) public{
        id = _id;
        addAddressToWhitelist(msg.sender);
    }

    /**
    * @dev Add a raw material
    */
    function addRawMaterial(address _rawMaterial) public onlyWhitelisted() nonEmptyAddress(_rawMaterial){
        rawMaterials.push(_rawMaterial);
        emit LogRawMaterialAdded(msg.sender, _rawMaterial);
    }

    /**
    * @dev Add a step
    */
    function addStep(uint256 _timestamp, uint256 _latitude, uint256 _longitude) public onlyWhitelisted() {
        // check if a room with same id already added

        historicalPositions.push(Position({
            timestamp : _timestamp,
            latitude : _latitude,
            longitude : _longitude,
            sender : msg.sender
            })
        );

        emit LogNewPositionAdded(msg.sender,_timestamp);
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
    modifier nonEmptyAddress(address value){
        require(value != address(0));
        _;
    }
}