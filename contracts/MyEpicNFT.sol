// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// Imports
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import { Base64 } from "./libraries/Base64.sol";

// We inherit the contract we imported giving us access to the contract's methods
contract MyEpicNFT is ERC721URIStorage {
    // OpenZeppelin feature to keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 totalNFTs;

    // Here is our SVG code that can be used as a base
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // Three arrays that we will pick random words from.
    string[] firstWords = ["Holy", "Lethargic", "Kludge", "Notorious", "Erratic", "Tender", "Mighty", "Tiny", "Round", "Royal", "Warped", "Silent", "Sordid", "Bald", "Missing", "Ragged"];
    string[] secondWords = ["Tacos", "Beets", "Bethoven", "Crumble", "Trifle", "Vader", "Gunther", "Ross", "Stimpy", "Sonic", "Mario", "Link", "Batman", "Narrator", "Farza", "Cardi"];
    string[] thirdWords = ["Maker", "King", "Wok", "Time", "Smite", "Shill", "Slab", "Draper", "Football", "Mercy", "Pinky", "Couch", "Mic", "Bag", "Mirror", "Fuzzy"];
    
    // Add an event.
    event NewEpicNFTMinted(address sender, uint256 tokenId);
    
    constructor() ERC721 ("SquareNFT", "SQUARE") {
        console.log("This is my NFT contract. Whoa!!!");
    }

    // Function to randomly pick a word from each array.
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        // Seed the random generator.
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        // Squash the number between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }
    
    function getTotalNFTsMintedSoFar() public view returns (uint256) {
        console.log("%s total NFTs have been minted", totalNFTs);
        return totalNFTs;
    }

    // A function user's will hit to get their NFTs.
    function makeAnEpicNFT() public {
        require(_tokenIds.current() < 50, "Only 50 NFTs in this series can be minted");
        // Get the current tokenId, which starts at 0.
        uint256 newItemId = _tokenIds.current();

        totalNFTs += 1;

        // Go and randomly grab one word from each of the three arrays.
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(abi.encodePacked(first, second, third));

        // Concatenate it all together and then close the <text> and <svg> tags.
        string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));
        
        // Get all the JSON metadata in place and base64 encode it
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // We prepend data:application/json;base64 to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n-------------------");
        console.log(
            string(
                abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenUri
                )
            )
        );
        console.log("--------------------\n");

        // Actually mint the NFT to the sender using msg.sender
        _safeMint(msg.sender, newItemId);

        // Set the NFTs data.
        _setTokenURI(newItemId, finalTokenUri);

        // Increment the counter for when the next NFT is minted.
        _tokenIds.increment();
        console.log("An NFT with ID %s has been minted to %s", newItemId, msg.sender);

        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}