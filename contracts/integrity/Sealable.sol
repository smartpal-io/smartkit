pragma solidity ^0.4.17;

import "../../node_modules/zeppelin-solidity/contracts/ownership/Whitelist.sol";

/**
 * @title Sealable
 * @dev Sealable allows users to submit a seal as a proof of integrity of anything.
 * @dev The seal can be for example the hash of a document.
 * @dev See the tests Sealable.test.js for specific usage examples.
 */
contract Sealable is Whitelist {

  mapping (bytes32 => bytes32) private seals;

  event LogNewSealRecorded(bytes32 indexed id, bytes32 indexed seal);


  /**
   * @notice Create a new Sealable Contract.
   */
  function Sealable() public {
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
  function recordSeal(bytes32 id, bytes32 seal) public onlyWhitelisted {
     require(seals[id] == bytes32(0x0));
     seals[id]=seal;
     emit LogNewSealRecorded(id,seal);
  }

  /**
   * Use this getter function to access the seal value
   * @param id of the seal
   * @return the seal
   */
  function getSeal(bytes32 id) public view returns(bytes32) {
    return seals[id];
  }

  /**
   * Use this method to verify a seal validity
   * @param id of the seal
   * @param seal value
   */
  function verifySeal(bytes32 id, bytes32 seal) public view returns(bool) {
    return seals[id]==seal;
  }

}
