pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Sealable.sol";

contract TestSealable {


  function testRecordSeal() public {
    Sealable sealable = new Sealable();

    bytes32 sealId = 0x000000000000000000000000000000000000000000000000000000000000001;
	bytes32 sealValue = 0xa7834034bd059ecf00b0661f88f1e7242450bf1951c1e76803e80ce4182e2e9c;
	bytes32 expected = 0xa7834034bd059ecf00b0661f88f1e7242450bf1951c1e76803e80ce4182e2e9c;

	sealable.recordSeal(sealId, sealValue);

    Assert.equal(sealable.getSeal(sealId), expected, "seal valued should be equal");
  }
  
}