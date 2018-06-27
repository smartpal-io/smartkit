import expectThrow from "../../node_modules/openzeppelin-solidity/test/helpers/expectThrow";
import expectEvent from "../../node_modules/openzeppelin-solidity/test/helpers/expectEvent";
import assertRevert from '../../node_modules/openzeppelin-solidity/test/helpers/assertRevert';

const TraceableMock = artifacts.require('Traceable');

require('chai')
  .use(require('chai-as-promised'))
.should();

contract('Traceable', function (accounts) {

  let mock, rawMaterial;

  const [
    owner,
    anyone,
  ] = accounts;

  before(async function () {
    mock = await TraceableMock.new(1148850588);
    rawMaterial = await TraceableMock.new(2228110111);
    await expectEvent.inTransaction(
        mock.addAllowedModifier(owner, { from: owner }),
        'WhitelistedAddressAdded'
    );
  });

  context('in normal conditions', () => {
    it('should be possible to add raw materials when you are in the whitelist', async function () {
      await expectEvent.inTransaction(
        mock.addRawMaterial(rawMaterial.address, { from: owner }),
        'LogRawMaterialAdded'
      );
    });
    it('should be possible to add a new position for a product if you are in the whitelist', async function () {
      await expectEvent.inTransaction(
        mock.addStep(991084188,40714224, -73961452, { from: owner }),
        'LogNewPositionAdded'
      );
    });
  });

  context('in not normal conditions', () => {
    it('should not be possible to add raw materials when you are not in the whitelist', async function () {
      await assertRevert(
        mock.addRawMaterial(rawMaterial.address, { from: anyone })
      );
    });
   });
});