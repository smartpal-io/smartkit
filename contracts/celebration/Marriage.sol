pragma solidity ^0.4.0;

import "../openzeppelin-solidity/Whitelist.sol";

contract Marriage is Whitelist {

    struct Partner {
        string friendlyName;
        address partnerAddress;
    }

    event LogJustMarried(uint256 timestamp, address partner1Address, address partner2Address);

    Partner public  partner1;
    Partner public partner2;

    constructor() public {
        addAddressToWhitelist(msg.sender);
    }

    function marry(string partner1FriendlyName, address partner1Address,
        string partner2FriendlyName, address partner2Address) public onlyWhitelisted{

        trustedMarry(
        Partner({friendlyName : partner1FriendlyName, partnerAddress : partner1Address}),
        Partner({friendlyName : partner2FriendlyName, partnerAddress : partner2Address})
        );
        emit LogJustMarried(block.timestamp, partner1Address, partner2Address);
    }

    function trustedMarry(Partner partner1Entry, Partner partner2Entry) private onlyWhitelisted {
        partner1 = partner1Entry;
        partner2 = partner2Entry;
    }

    // This function gets executed if a transaction with invalid data is sent to
    // the contract or just ether without data. We revert the send so that no-one
    // accidentally loses money when using the contract.
    function() {
        revert();
    }
}
