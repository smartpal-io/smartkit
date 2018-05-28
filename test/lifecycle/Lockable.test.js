import expectThrow from "../../node_modules/zeppelin-solidity/test/helpers/expectThrow";
import expectEvent from "../../node_modules/zeppelin-solidity/test/helpers/expectEvent";

const LockableMock = artifacts.require('Lockable');


contract('Lockable', function (accounts) {
  
  let mock;

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
      beforeModification.should.be.equal(991084188);
      afterModification.should.be.equal(1306616988);
    });
  });
});