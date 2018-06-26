import expectThrow from "../../node_modules/openzeppelin-solidity/test/helpers/expectThrow";
import expectEvent from "../../node_modules/openzeppelin-solidity/test/helpers/expectEvent";
import assertRevert from '../../node_modules/openzeppelin-solidity/test/helpers/assertRevert';

const RoomBookingServiceMock = artifacts.require('RoomBookingService');

const FREE = 0;
const BOOKED = 1;
const LOCKED = 2;

const SECONDS = 1000;
const MINUTES = 60 * SECONDS;

require('chai')
  .use(require('chai-as-promised'))
.should();


contract('RoomBookingService', function (accounts) {

  let mock;
  let roomId ='0x0000000000000000000000000000000000000000000000000000000000000001' ;
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

    it('should get FREE status after room creation', async function () {
       let roomStatus = await mock.getRoomStatus(roomId);
       assert.equal(FREE, roomStatus);
    });

    it('room should be available during booking interval', async function () {
       let from = Date.now() + 1 * MINUTES;
       let until = from + 1 * MINUTES;
       await expectEvent.inTransaction(
         mock.book(roomId, from, until, { from: owner }),
         'LogRoomBooked'
        );
        let isRoomAvailable = await mock.isRoomAvailable(roomId, from, until);
        isRoomAvailable.should.be.equal(false);
    });

    it('should get FREE status after room freed', async function () {
       await expectEvent.inTransaction(
         mock.free(roomId, { from: owner }),
         'LogRoomFreed'
        );
        let roomStatus = await mock.getRoomStatus(roomId);
        assert.equal(FREE, roomStatus);
    });

    it('should not add a room and revert when anyone call addRoom', async function () {
          await assertRevert(
            mock.addRoom(roomId, capacity, { from: anyone }),
          );
     });


  });
});