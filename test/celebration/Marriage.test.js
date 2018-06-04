import expectThrow from "../../node_modules/openzeppelin-solidity/test/helpers/expectThrow";
import expectEvent from "../../node_modules/openzeppelin-solidity/test/helpers/expectEvent";
import assertRevert from '../../node_modules/openzeppelin-solidity/test/helpers/assertRevert';

const MarriageMock = artifacts.require('Marriage');

require('chai')
  .use(require('chai-as-promised'))
.should();

contract('Marriage', function (accounts) {
  
  let mock;
  let parner1Address = "0xc0ffee254729296a45a3885639AC7E10F9d54979";
  let partner1FriendlyName = "John";
  let partner2FriendlyName = "Lisa";
  let parner2Address = "0x999999cf1046e68e36E1aA2E0E07105eDDD1f08E";
  
  const [
    owner,
    anyone,
  ] = accounts;

  before(async function () {
    mock = await MarriageMock.new();
  });

  context('in normal conditions', () => {
    it('should be married', async function () {

          await expectEvent.inTransaction(
                mock.marry(partner1FriendlyName, parner1Address, partner2FriendlyName, parner2Address, { from: owner }),
                'LogJustMarried'
              );
    });

	
  });
});