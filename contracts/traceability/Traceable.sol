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
        int256 latitude;
        int256 longitude;
    }

    event LogRawMaterialAdded(address sender, address rawMaterial);
    event LogNewPositionAdded(address sender, uint256 _date);

    constructor(bytes32 _id) public{
        id = _id;
    }

    /**
    * @dev Add an allowed administrator
    * @param _allowedAdministrator address
    */
    function addAllowedModifier(address _allowedAdministrator)
      public
      onlyOwner
      nonEmptyAddress(_allowedAdministrator)
    {
        addAddressToWhitelist(_allowedAdministrator);
    }

    /**
    * @dev Add a raw material
    * @param _rawMaterial address
    */
    function addRawMaterial(address _rawMaterial)
      public
      onlyWhitelisted()
      nonEmptyAddress(_rawMaterial)
    {
        rawMaterials.push(_rawMaterial);
        emit LogRawMaterialAdded(msg.sender, _rawMaterial);
    }

    /**
    * @dev Add a historical position
    */
    function addStep(uint256 _timestamp, int256 _latitude, int256 _longitude)
      public
      onlyWhitelisted()
    {
        historicalPositions.push(Position({
            timestamp : _timestamp,
            latitude : _latitude,
            longitude : _longitude
            })
        );
        emit LogNewPositionAdded(msg.sender,_timestamp);
    }

    /**
    * @dev Get number of historical positions of the product
    * @return the number of historical position saved for this product
    */
    function getStepsCount()
      public
      constant
      returns (uint)
    {
        return historicalPositions.length;
    }

    /**
    * @dev Get historical position at a specific index
    * @param _index index of the historical position
    */
    function getStep(uint _index)
      public
      constant
      returns (uint256, int256, int256)
    {
        require(_index>=0 && _index<historicalPositions.length);
        Position storage step = historicalPositions[_index];
        return (step.timestamp, step.latitude, step.longitude);
    }

    /**
    * @dev Throws if zero
    */
    modifier nonZeroUint256(uint256 _value){
        require(_value != uint256(_value));
        _;
    }

    /**
    * @dev Throws if empty
    */
    modifier nonEmptyAddress(address _value){
        require(_value != address(0));
        _;
    }
}
