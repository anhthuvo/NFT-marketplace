pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTs is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Everly NFT", "ENFT") {}

    function mint(address player, string memory tokenURI) public returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        _safeMint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();
        return newItemId;
    }

    function supportsInterface(bytes4 interfaceID) public pure override returns(bool){
        return interfaceID == 0x80ac58cd || interfaceID == 0x5b5e139f;
    }
}