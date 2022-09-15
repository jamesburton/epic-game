const names = ["Bob","Geoff","Smeagle","Bill","Connie","Chris","Luna","Spotty","Gwen","Akuma"];
const images = [
    "https://media4.giphy.com/media/14bWswbeWGzYEo/200.gif",
    "https://i.gifer.com/2m8D.gif",
    "https://25.media.tumblr.com/a00f3513da12f84db4962a661239fbea/tumblr_mzvw8cJFIc1qf9mevo1_500.gif",
    "https://25.media.tumblr.com/tumblr_m9938dQX5a1r6e9hpo1_500.gif",
    "https://24.media.tumblr.com/tumblr_m8njxrrpby1rvv4x1o1_500.gif",
    "https://66.media.tumblr.com/6ba1e4174b2f6e56e68a5b3bdbdf96ba/tumblr_ng4jyz0KrH1s63c00o1_250.gif",
    "https://24.media.tumblr.com/cb72de91559f27e2bd5ec98d665d4a13/tumblr_n3j7v2ozVD1rlb6iho1_400.gif",
    "https://25.media.tumblr.com/31b46c7f7695ff5823d13767e7c303f8/tumblr_mo5e1h5TgO1sqv1wuo1_500.gif",
    "https://25.media.tumblr.com/tumblr_m9qk8kw9NR1rvv4x1o1_500.gif",
    "https://24.media.tumblr.com/a42e0a8cb1019ad3f86d736903f56807/tumblr_metc6hYpVb1rzpyc0o1_500.gif",
];
const hp = [50,35,199,100,2000,600,89,27,130,109];
const damage = [200,300,50,100,10,75,120,45,137,666];

const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    // const gameContract = await gameContractFactory.deploy(
    //   ["Leo", "Aang", "Pikachu"],       // Names
    //   ["https://i.imgur.com/pKd5Sdk.png", // Images
    //   "https://i.imgur.com/xVu4vFL.png", 
    //   "https://i.imgur.com/WMB6g9u.png"],
    //   [100, 200, 300],                    // HP values
    //   [100, 50, 25]                       // Attack damage values
    // );
    const gameContract = await gameContractFactory.deploy(
        names, images, hp, damage
    );
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);

    let txn;
    txn = await gameContract.mintCharacterNFT(0);
    await txn.wait();
    console.log("Minted NFT #1");
  
    txn = await gameContract.mintCharacterNFT(1);
    await txn.wait();
    console.log("Minted NFT #2");
  
    txn = await gameContract.mintCharacterNFT(2);
    await txn.wait();
    console.log("Minted NFT #3");
  
    txn = await gameContract.mintCharacterNFT(1);
    await txn.wait();
    console.log("Minted NFT #4");
  
    console.log("Done deploying and minting!");
    
    // Get the value of the NFT's URI.
    let returnedTokenUri = await gameContract.tokenURI(1);
    console.log("Token URI:", returnedTokenUri);
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