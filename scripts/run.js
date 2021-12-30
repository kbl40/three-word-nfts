const main = async () => {
    const nftContractFactory = await hre.ethers.getContractFactory('MyEpicNFT');
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    console.log("Contract deployed to:", nftContract.address);

    for (let i = 0; i < 5; i++) {
        // Call the function 
        let txn = await nftContract.makeAnEpicNFT()
        // Wait for it to be mined.
        await txn.wait()
        console.log(`Minted NFT Number ${i}`)
    }

    // Mint one more to see if require statement kicks in.
    let totalNFTs = await nftContract.getTotalNFTsMintedSoFar()
    console.log(`There are ${totalNFTs} NFTs that have been minted.`)
    // Wait for it to be mined.
    //await txn.wait()
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();