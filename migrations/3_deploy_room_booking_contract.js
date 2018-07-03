var roomBookingService = artifacts.require("RoomBookingService");
module.exports = function(deployer) {
   deployer.deploy(roomBookingService);
};
