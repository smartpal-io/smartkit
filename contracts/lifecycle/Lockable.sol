pragma solidity ^0.4.21;

import "../../node_modules/zeppelin-solidity/contracts/ownership/Whitelist.sol";

/**
 * @title Lockable
 * @dev It allows to give a date limit to a contract. 
 * After this date the contract is blocked. The owner may postpone the date limit.
 */
contract Lockable is Ownable {

  uint256 private dateLimit;
  
  event LogDateLimitUpdated(uint256 indexed dateLimit);

  
  /**
   * @dev Create a new Lockable Contract.
   * @param _datelimit uint256 date limit of the contract (timestamp as seconds since unix epoch)
   */
  function DayLimit(uint256 _datelimit) public {
    dateLimit = _datelimit;
  }

  /**
   * @dev sets the date limit. 
   * @param _newDateLimit uint256 new date limit of the contract (timestamp as seconds since unix epoch)
   */
  function setDateLimit(uint256 _newDateLimit) public onlyOwner{
    dateLimit = _newDateLimit;
	emit LogDateLimitUpdated(dateLimit);
  }

  /**
   * @dev return contract status. 
   * @return status (true if the contract is locked)
   */
  function isLocked() public view returns(bool){
    return block.timestamp>dateLimit;
  }

  /**
   * @dev Throws if called when the contract is locked.
   */
  modifier onlyUnlock() {
    require(block.timestamp<=dateLimit);
    _;
  }

}
