// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");

async function main() {
    //Deploying Normal Contract
    const Greeter = await ethers.getContractFactory("ERC20Factory");
    const greeter = await Greeter.deploy();
    console.log("Deployed Factory \n--------------------\n", greeter);
    await greeter.deployed();
    console.log("Factory Contract Address", greeter.address);

    //call the function getBytecode 
    //the params are name, symbil, decimals, totalSupply
    const childBytecode = await greeter.getBytecode("First ERC20", "MIT", 18, 100000);
    console.log("Bytecode of the child contract", childBytecode);

    //call the function getAddress
    //the params are bytecode and salt strength
    const childAddress = await greeter.getAddress(childBytecode, 1);
    console.log("Address of the child contract", childAddress);

    //call the function deploy
    //the params are bytecode and salt strength
    const childDeploy = await greeter.deploy(childBytecode, 1);
    console.log("child contract deployed at address \n--------------------\n", childDeploy);
    

    //Deploying Upgradable Contract
    // const Greeter = await ethers.getContractFactory("GreeterUpgrade");
    // const greeter = await upgrades.deployProxy(Greeter,["Hello World"],{initializer: 'initialize'});
    // await greeter.deployed();
    // console.log("Greeter Upgradable Contract Address", greeter.address);

    //Upgrading Upgradable Contract
    // const proxyAddress = '0x9539f8A71e8129623050ee117a92Efa6c5a23e5b';
    // const Greeter = await ethers.getContractFactory("GreeterUpgrade");
    // const GreeterAddress = await upgrades.prepareUpgrade (proxyAddress,Greeter);
    // console.log("Greeter upgrade address :",GreeterAddress);
}

(async function () {
    try {
        const res = await main();
        console.log("res", res);
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
})();
