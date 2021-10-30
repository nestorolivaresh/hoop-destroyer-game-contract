// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";

contract HoopDestroyerGame is ERC721 {
    struct PlayerAttributes {
        uint256 playerIndex;
        string name;
        string imageURI;
        uint256 sp;
        uint256 maxSp;
        uint256 shotAccuracy;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    PlayerAttributes[] defaultPlayers;

    mapping(uint256 => PlayerAttributes) public nftHolderAttributes;

    struct HoopBoss {
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    HoopBoss public hoopBoss;

    mapping(address => uint256) public nftHolders;

    event PlayerNFTMinted(address sender, uint256 tokenId, uint256 playerIndex);
    event AttackComplete(uint256 updatedBossHp, uint256 updatedPlayerHp);

    constructor(
        string[] memory playerNames,
        string[] memory playerImageURIs,
        uint256[] memory playerSp,
        uint256[] memory playerShotAccuracy,
        string memory bossName,
        string memory bossImageURI,
        uint256 bossHp,
        uint256 bossAttackDamage
    ) ERC721("Ballers", "BALLER") {
        hoopBoss = HoopBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage
        });

        console.log(
            "Done initializing boss %s w/ HP %s, img %s",
            hoopBoss.name,
            hoopBoss.hp,
            hoopBoss.imageURI
        );

        for (uint256 i = 0; i < playerNames.length; i += 1) {
            defaultPlayers.push(
                PlayerAttributes({
                    playerIndex: i,
                    name: playerNames[i],
                    imageURI: playerImageURIs[i],
                    sp: playerSp[i],
                    maxSp: playerSp[i],
                    shotAccuracy: playerShotAccuracy[i]
                })
            );
            PlayerAttributes memory c = defaultPlayers[i];
            console.log(
                "Done initializing %s w/ HP %s, img %s",
                c.name,
                c.sp,
                c.imageURI
            );
        }
        _tokenIds.increment();
    }

    function mintPlayerNFT(uint256 _playerIndex) external {
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);

        nftHolderAttributes[newItemId] = PlayerAttributes({
            playerIndex: _playerIndex,
            name: defaultPlayers[_playerIndex].name,
            imageURI: defaultPlayers[_playerIndex].imageURI,
            sp: defaultPlayers[_playerIndex].sp,
            maxSp: defaultPlayers[_playerIndex].maxSp,
            shotAccuracy: defaultPlayers[_playerIndex].shotAccuracy
        });

        console.log(
            "Minted NFT w/ tokenId %s and playerIndex %s",
            newItemId,
            _playerIndex
        );
        nftHolders[msg.sender] = newItemId;
        _tokenIds.increment();
        emit PlayerNFTMinted(msg.sender, newItemId, _playerIndex);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        PlayerAttributes memory currentPlayerAttributes = nftHolderAttributes[
            _tokenId
        ];
        string memory strSp = Strings.toString(currentPlayerAttributes.sp);
        string memory strMaxSp = Strings.toString(
            currentPlayerAttributes.maxSp
        );
        string memory strShotAccuracy = Strings.toString(
            currentPlayerAttributes.shotAccuracy
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        currentPlayerAttributes.name,
                        " -- NFT #: ",
                        Strings.toString(_tokenId),
                        '", "description": "NFT part of the HoopDestroyer universe!", "image": "ipfs://',
                        currentPlayerAttributes.imageURI,
                        '", "attributes": [ {"trait_type": "Stamina", "value": ',
                        strSp,
                        ', "max_value":',
                        strMaxSp,
                        '}, {"trait_type": "Shot Accuracy", "value": ',
                        strShotAccuracy,
                        "}] }"
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return output;
    }

    function attackBoss() public {
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        PlayerAttributes storage player = nftHolderAttributes[
            nftTokenIdOfPlayer
        ];

        // Make sure the player has more than 0 HP.
        require(
            player.sp > 0,
            "Error: Your player doesn't have any stamina left."
        );

        // Make sure the boss has more than 0 HP.
        require(hoopBoss.hp > 0, "Error: You have already defeated the boss!");

        console.log(
            "\nPlayer w/ character %s about to attack. Has %s HP and %s AD",
            player.name,
            player.sp,
            player.shotAccuracy
        );
        console.log(
            "Boss %s has %s HP and %s AD",
            hoopBoss.name,
            hoopBoss.hp,
            hoopBoss.attackDamage
        );

        if (hoopBoss.hp < player.shotAccuracy) {
            hoopBoss.hp = 0;
        } else {
            hoopBoss.hp = hoopBoss.hp - player.shotAccuracy;
        }

        if (player.sp < hoopBoss.attackDamage) {
            player.sp = 0;
        } else {
            player.sp = player.sp - hoopBoss.attackDamage;
        }

        emit AttackComplete(hoopBoss.hp, player.sp);
        console.log("Boss attacked player. New player hp: %s\n", player.sp);
    }

    function checkIfUserHasNFT() public view returns (PlayerAttributes memory) {
        uint256 userNftTokenId = nftHolders[msg.sender];

        if (userNftTokenId > 0) {
            return nftHolderAttributes[userNftTokenId];
        } else {
            PlayerAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    function getAllDefaultPlayers()
        public
        view
        returns (PlayerAttributes[] memory)
    {
        return defaultPlayers;
    }

    function getBoss() public view returns (HoopBoss memory) {
        return hoopBoss;
    }
}
