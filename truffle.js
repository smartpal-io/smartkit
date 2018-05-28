module.exports = {
   networks: {
  development: {
    host: "127.0.0.1",
    port: 8545,
    network_id: "*" // match any network
  },
  docker: {
    host: "192.168.99.100", // docker machine ip
    port: 8545,
    network_id: "*",  // match any network
  }
}
};
