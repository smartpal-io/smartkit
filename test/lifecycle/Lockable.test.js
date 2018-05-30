import expectThrow from "../../node_modules/openzeppelin-solidity/test/helpers/expectThrow";
import expectEvent from "../../node_modules/openzeppelin-solidity/test/helpers/expectEvent";
import assertRevert from '../../node_modules/openzeppelin-solidity/test/helpers/assertRevert';

const LockableMock = artifacts.require('Lockable');

require('chai')
  .use(require('chai-as-promised'))
.should();

contract('Lockable', function (accounts) {
  
  let mock;
  
  const [
    owner,
    anyone,
  ] = accounts;

  before(async function () {
    mock = await LockableMock.new(1148850588);
  });

  context('in normal conditions', () => {
    it('should be locked with a past date (date -> year 2009)', async function () {
      await expectEvent.inTransaction(
        mock.setDateLimit(991084188, { from: owner }),
        'LogDateLimitUpdated'
      );
      const isLocked = await mock.isLocked();
      isLocked.should.be.equal(true);
    });

	it('should update date limit when setDateLimit is called (date -> year 2011)', async function () {
      const beforeModification = await mock.getDateLimit();
	  await expectEvent.inTransaction(
        mock.setDateLimit(1306616988, { from: owner }),
        'LogDateLimitUpdated'
      );
      const afterModification = await mock.getDateLimit();
      beforeModification.toNumber().should.be.equal(991084188);
      afterModification.toNumber().should.be.equal(1306616988);
    });
	
	it('should not update date limit when setDateLimit is not called by the owner', async function () {
      await assertRevert(
        mock.setDateLimit(1306616988, { from: anyone }),
      );
      const afterModification = await mock.getDateLimit();
      afterModification.toNumber().should.be.equal(1306616988);
    });
	
  });
});