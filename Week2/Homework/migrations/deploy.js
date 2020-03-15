Store.deployed().then(function(i) { return i.getProduct(1); })
Store.deployed().then(function(i) { return i.getIndex(); })
Store.deployed().then(function(i) { return i.changeStatusOfProduct(1,1); });

Store.deployed().then(function(instance) { instance.addProduct("Arsenal", "Premier League", "QmZGdjAQ8m6pSXuBi4MFt77djTZVEiec2cowfgj5jiEhxu	", "Home", 1); });
Store.deployed().then(function(instance) { instance.addProduct("AS Roma", "Serie A", "Qmai6dtyBwTp7xXxRqKsjjBNb1uQdmhg9PU85Y1mTj8Ypj", "Away", 1); });
Store.deployed().then(function(instance) { instance.addProduct("AC Milan", "Serie A", "QmfNHg2eTuv2tGZ5GkwA949oF5MWCz21Ks69o1s4ouvJmp", "Home", 1); });
Store.deployed().then(function(instance) { instance.addProduct("Barcelona", "La Liga", "QmcgB4HXdCeWquQLVahxfxmgpqsQFSVKmRLfe3SZDZ2Zhv", "Away", 1); });
Store.deployed().then(function(instance) { instance.addProduct("Chelsea", "Premier League", "QmbfaffcZdB8F7KGDRSyK8FiRyojGJBqD2m4SYAMXSckqf", "Home", 1); });
Store.deployed().then(function(instance) { instance.addProduct("Manchester United", "Premier League", "QmRHEQBJFZDHUJ7Z9PdoHr9QiGsXMAquKFoFPZNKj4B2gd", "Home", 1); });
Store.deployed().then(function(instance) { instance.addProduct("Real Madrid", "La Liga", "QmTknLEvngSMchcksN5DHX3MkBGdXGBrFCs3UmkdStphVz", "Away", 1); });