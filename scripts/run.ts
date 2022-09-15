const names = ["Bob","Geoff","Smeagle","Bill","Connie","Chris","Luna","Spotty","Gwen","Akuma"];
const images = [
    // "https://media4.giphy.com/media/14bWswbeWGzYEo/200.gif",
    // "https://i.gifer.com/2m8D.gif",
    // "https://25.media.tumblr.com/a00f3513da12f84db4962a661239fbea/tumblr_mzvw8cJFIc1qf9mevo1_500.gif",
    // "https://25.media.tumblr.com/tumblr_m9938dQX5a1r6e9hpo1_500.gif",
    // "https://24.media.tumblr.com/tumblr_m8njxrrpby1rvv4x1o1_500.gif",
    // "https://66.media.tumblr.com/6ba1e4174b2f6e56e68a5b3bdbdf96ba/tumblr_ng4jyz0KrH1s63c00o1_250.gif",
    // "https://24.media.tumblr.com/cb72de91559f27e2bd5ec98d665d4a13/tumblr_n3j7v2ozVD1rlb6iho1_400.gif",
    // "https://25.media.tumblr.com/31b46c7f7695ff5823d13767e7c303f8/tumblr_mo5e1h5TgO1sqv1wuo1_500.gif",
    // "https://25.media.tumblr.com/tumblr_m9qk8kw9NR1rvv4x1o1_500.gif",
    // "https://24.media.tumblr.com/a42e0a8cb1019ad3f86d736903f56807/tumblr_metc6hYpVb1rzpyc0o1_500.gif",
    // Uploaded to IPFS and saved as CIDs instead
    "bafybeib65hkuhz3vf6iqqfr6vnrfgd472rc4pewwe5smxhodhwe74tskwm",
    "bafybeid2kywyycwjzqg2iuzitsgfs3znxeli2h4fpty4ri3h5ifpnfmqqy",
    "bafybeibxnc6fm3mbd5vwu3ckwok3t4ctmpaahqinea7rylylwm6yehrbra",
    "bafybeiedi53oaxiexfgnptiqtuq2pn72gnhufjfdvg36eefvacedcbrpqe",
    "bafybeibnklplb5urtmsspnkn6kkphdbvqwnnpwaf5s7mxvorlodc3tedqq",
    "bafybeidwcsd5oef6475tw6bczvdealyf63gh72gyn23ukiih6bxeh74wfq",
    "bafybeici4vy3br7nq7yav75wlakqyljqa7jq3wkeguqazs5udilaqhxety",
    "bafybeib2h2yweocsxnkb4bmhvnsskuuxkwwdgp5q2ewzfdczadgh7i2coa",
    "bafybeib6o27ojblh2twp6bpyljrd6ajm32fhesabmw5pmbdsicey4l6uum",
    "bafybeidznrhawibys2cmt4b5ct6hwefqf25e2wll4skpyl7al5e5ynvisy",
];
const hp = [50,35,199,100,2000,600,89,27,130,109];
const damage = [200,300,50,100,10,75,120,45,137,666];

const bossName = 'Stay Puft';
// const bossImage = 'https://upload.wikimedia.org/wikipedia/en/0/01/Mr._Stay-Puft_Marshmallow_Man.png';
const bossImage = 'bafkreid6htlwldmqwfi36xru3zpr55bjmtmc6mtxjty2643rldbklxron4';
const bossHP = 10000;
const bossDamage = 50;

const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    const gameContract = await gameContractFactory.deploy(
        names, images, hp, damage,
        bossName, bossImage, bossHP, bossDamage
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
  
    txn = await gameContract.attackBoss();
    await txn.wait();
  
    txn = await gameContract.attackBoss();
    await txn.wait();
    
    txn = await gameContract.mintCharacterNFT(2);
    await txn.wait();
    console.log("Minted NFT #3");
      
    txn = await gameContract.attackBoss();
    await txn.wait();

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