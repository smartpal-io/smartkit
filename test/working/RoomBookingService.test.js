import expectThrow from "../../node_modules/openzeppelin-solidity/test/helpers/expectThrow";
import expectEvent from "../../node_modules/openzeppelin-solidity/test/helpers/expectEvent";
import assertRevert from '../../node_modules/openzeppelin-solidity/test/helpers/assertRevert';

const RoomBookingServiceMock = artifacts.require('RoomBookingService');

require('chai')
  .use(require('chai-as-promised'))
.should();

contract('RoomBookingService', function (accounts) {
  
  let mock;
  let roomId ='0x01' ;
  let capacity = 1;
  
  const [
    owner,
    anyone,
  ] = accounts;

  before(async function () {
    mock = await RoomBookingServiceMock.new();
  });

  context('in normal conditions', () => {
    it('should add a room and trigger LogRoomAdded event when the owner call addRoom', async function () {
      await expectEvent.inTransaction(
        mock.addRoom(roomId, capacity, { from: owner }),
        'LogRoomAdded'
      );
    });

    it('should add a room and trigger LogRoomAdded event when the owner call addRoom', async function () {
       var roomStatus = await mock.getRoomStatus(roomId);
       console.log("room status : ", roomStatus.toNumber());
    });

    it('should not add a room and revert when anyone call addRoom', async function () {
          await assertRevert(
            mock.addRoom(roomId, capacity, { from: anyone }),
          );
     });


  });
});