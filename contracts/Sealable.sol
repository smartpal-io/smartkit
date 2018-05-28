pragma solidity ^0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/ownership/Whitelist.sol";

/**
 * @title Sealable
 * @dev Sealable allows users to submit a seal as a proof of integrity of anything.
 * @dev The seal can be for example the hash of a document.
 * @dev See the tests Sealable.test.js for specific usage examples.
 */
contract Sealable is Whitelist {

  struct Seal{
	bytes32 value;
  }

  mapping (bytes32 => Seal) private seals;

  event LogNewSealRecorded(bytes32 indexed id, bytes32 indexed sealValue);


  /**
   * @notice Create a new Sealable Contract.
   */
  constructor() public {
    addAddressToWhitelist(msg.sender);
  }

  /**
   * @notice Register a new delegate authorized to add seal
   */
  function registerDelegate(address delegate) onlyOwner public returns(bool success) {  
	return addAddressToWhitelist(delegate);
  }
  
  /**
   * @notice Record a new seal in the registry.
   */
  function recordSeal(bytes32 id, bytes32 sealValue) public onlyWhitelisted {
     require(seals[id].value == bytes32(0x0));
     seals[id]= Seal({value: sealValue});
     emit LogNewSealRecorded(id,sealValue);
  }

  /**
   * Use this getter function to access the seal value
   * @param id of the seal
   * @return the seal
   */
  function getSeal(bytes32 id) public view returns(bytes32) {
	return seals[id].value;
  }

  /**
   * Use this method to verify a seal validity
   * @param id of the seal
   * @param sealValue value
   */
  function verifySeal(bytes32 id, bytes32 sealValue) public view returns(bool) {
    return seals[id].value==sealValue;
  }

}
