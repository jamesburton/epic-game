// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Helper we wrote to encode in Base64
import "./libraries/Base64.sol";

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

// Our contract inherits from ERC721, which is the standard NFT contract!
contract MyEpicGame is ERC721 {
  event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
  event AttackComplete(address sender, uint newBossHp, uint newPlayerHp);

  struct CharacterAttributes {
    uint characterIndex;
    string name;
    string imageURI;        
    uint hp;
    uint maxHp;
    uint attackDamage;
  }

  // The tokenId is the NFTs unique identifier, it's just a number that goes
  // 0, 1, 2, 3, etc.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  CharacterAttributes[] defaultCharacters;

  // We create a mapping from the nft's tokenId => that NFTs attributes.
  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

  struct BigBoss {
    string name;
    string imageURI;
    uint hp;
    uint maxHp;
    uint attackDamage;
  }

  BigBoss public bigBoss;

  // A mapping from an address => the NFTs tokenId. Gives me an ez way
  // to store the owner of the NFT and reference it later.
  mapping(address => uint256) public nftHolders;

  uint256 private seed;

  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
    uint[] memory characterAttackDmg,
    // Below, you can also see I added some special identifier symbols for our NFT.
    // This is the name and symbol for our token, ex Ethereum and ETH. I just call mine
    // Heroes and HERO. Remember, an NFT is just a token!
    string memory bossName, // These new variables would be passed in via run.js or deploy.js.
    string memory bossImageURI,
    uint bossHp,
    uint bossAttackDamage
  )
    ERC721("Heroes", "HERO")
  {
    // Initialize the boss. Save it to our global "bigBoss" state variable.
    bigBoss = BigBoss({
        name: bossName,
        imageURI: bossImageURI,
        hp: bossHp,
        maxHp: bossHp,
        attackDamage: bossAttackDamage
    });

    console.log("Done initializing boss %s w/ HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);

    for(uint i = 0; i < characterNames.length; i += 1) {
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        hp: characterHp[i],
        maxHp: characterHp[i],
        attackDamage: characterAttackDmg[i]
      }));

      CharacterAttributes memory c = defaultCharacters[i];
      
      // Hardhat's use of console.log() allows up to 4 parameters in any order of following types: uint, string, bool, address
      console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
    }

    // I increment _tokenIds here so that my first NFT has an ID of 1.
    // More on this in the lesson!
    _tokenIds.increment();
  }

  // Users would be able to hit this function and get their NFT based on the
  // characterId they send in!
  function mintCharacterNFT(uint _characterIndex) external {
    // Get current tokenId (starts at 1 since we incremented in the constructor).
    uint256 newItemId = _tokenIds.current();

    // The magical function! Assigns the tokenId to the caller's wallet address.
    _safeMint(msg.sender, newItemId);

    // We map the tokenId => their character attributes. More on this in
    // the lesson below.
    nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      hp: defaultCharacters[_characterIndex].hp,
      maxHp: defaultCharacters[_characterIndex].maxHp,
      attackDamage: defaultCharacters[_characterIndex].attackDamage
    });

    console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);
    
    // Keep an easy way to see who owns what NFT.
    nftHolders[msg.sender] = newItemId;

    // Increment the tokenId for the next person that uses it.
    _tokenIds.increment();

    // Emit CharacterVFTMinted event
    emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
  }

  // FROM https://github.com/willitscale/solidity-util/blob/000a42d4d7c1491cde4381c29d4b775fa7e99aac/lib/Strings.sol#L90
  /**
     * Index Of
     *
     * Locates and returns the position of a character within a string starting
     * from a defined offset
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string acting as the haystack to be
     *              searched
     * @param _value The needle to search for, at present this is currently
     *               limited to one character
     * @param _offset The starting point to start searching from which can start
     *                from 0, but must not exceed the length of the string
     * @return int The position of the needle starting from 0 and returning -1
     *             in the case of no matches found
     */
  function _indexOf(string memory _base, string memory _value, uint _offset)
    internal
    pure
    returns (int) {
    bytes memory _baseBytes = bytes(_base);
    bytes memory _valueBytes = bytes(_value);

    assert(_valueBytes.length == 1);

    for (uint i = _offset; i < _baseBytes.length; i++) {
        if (_baseBytes[i] == _valueBytes[0]) {
            return int(i);
        }
    }

    return -1;
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

    string memory strHp = Strings.toString(charAttributes.hp);
    string memory strMaxHp = Strings.toString(charAttributes.maxHp);
    string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

    string memory json = Base64.encode(
        abi.encodePacked(
        '{"name": "',
        charAttributes.name,
        ' -- NFT #: ',
        Strings.toString(_tokenId),
        '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
        // Added support for using IPFS CID, by detecting lack of a colon 
        _indexOf(charAttributes.imageURI,':',0) == -1 ? 'ipfs://' : '',
        charAttributes.imageURI,
        '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
        strAttackDamage,'} ]}'
        )
    );

    string memory output = string(
        abi.encodePacked("data:application/json;base64,", json)
    );
    
    return output;
  }

  function attackBoss() public {
    // Get the state of the player's NFT.
    uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
    // - NB: Using 'storage' so that changes are persisted in the blockchain
    CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
    console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
    console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);
    // Make sure the player has more than 0 HP.
    require (
        player.hp > 0,
        "Error: character must have HP to attack boss."
    );

    // Make sure the boss has more than 0 HP.
    require (
        bigBoss.hp > 0,
        "Error: boss must have HP to attack character."
    );
    seed = (block.difficulty + block.timestamp + seed) % 100;
    //uint256 attackDamage = (player.attackDamage/2) + ((seed * player.attackDamage / 200));
    uint256 attackDamage = player.attackDamage; // Leave play with max damage
    // Allow player to attack boss.
    // if (bigBoss.hp < player.attackDamage) {
    if (bigBoss.hp < attackDamage) {
        bigBoss.hp = 0;
    } else {
        // bigBoss.hp = bigBoss.hp - player.attackDamage;
        bigBoss.hp = bigBoss.hp - attackDamage;
    }
    seed = (block.difficulty + block.timestamp + seed) % 100;
    attackDamage = (seed * bigBoss.attackDamage) / 100; // Boss applies 0-100% of maximum damage
    attackDamage = (bigBoss.attackDamage / 4) + (3 * seed * bigBoss.attackDamage) / 400; // Boss applies 25-100% of maximum damage
    // Allow boss to attack player.
    // if (player.hp < bigBoss.attackDamage) {
    if (player.hp < attackDamage) {
        player.hp = 0;
    } else {
        //player.hp = player.hp - bigBoss.attackDamage;
        player.hp = player.hp - attackDamage;
    }
    
    // Console for ease.
    console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
    console.log("Boss attacked player for %s damage. New player hp: %s\n", attackDamage, player.hp);

    // Emit event
    emit AttackComplete(msg.sender, bigBoss.hp, player.hp);
  }

  function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
    // Get the tokenId of the user's character NFT
    uint256 userNftTokenId = nftHolders[msg.sender];
    // If the user has a tokenId in the map, return their character.
    if (userNftTokenId > 0) {
        return nftHolderAttributes[userNftTokenId];
    }
    // Else, return an empty character.
    else {
        CharacterAttributes memory emptyStruct;
        return emptyStruct;
    }
  }

  function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
    return defaultCharacters;
  }

  function getBigBoss() public view returns (BigBoss memory) {
    return bigBoss;
  }
}