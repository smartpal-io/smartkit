var Sealable = artifacts.require("Sealable");
contract(Sealable, function() {
  it("should record a new seal", function() {
    var sealable;
    var result;
    return Sealable.deployed().then(function(instance) {
      sealable = instance;
      sealable.recordSeal('0x000000000000000000000000000000000000000000000000000000000000001',"0xe7834034bd059ecf00b0661f88f1e7242450bf1951c1e76803e80ce4182e2e9c");
    }).then(function() {
      return sealable.getSeal('0x000000000000000000000000000000000000000000000000000000000000001');
    }).then(function(hash) {
      result = hash;
    }).then(function() {
      assert.ok(result,"0xe7834034bd059ecf00b0661f88f1e7242450bf1951c1e76803e80ce4182e2e9c", "Seal not valid");
    });
  });
});
