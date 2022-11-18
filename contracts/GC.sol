//multiple mint// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract GiftCode is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    // for payment?
    IERC20 public s_token;
    // Store Contract
    address public s_storeAddress;
    address public s_profileAddress;

    // ------------------------------------------

    constructor() ERC721("Gift Code", "GC") {
        // safeMint(msg.sender, "uri");
    }

    // ------ MODIFIER
    modifier onlyStore() {
        require(msg.sender == s_storeAddress , "Only store");
        _;
    }
    modifier onlyProfile() {
        require(msg.sender == s_profileAddress , "Only Profile");
        _;
    }

    // ------ OWNER
    function setStoreAddress(address _storeAddress) external onlyOwner {
        s_storeAddress = _storeAddress;
    }

    function airdropGC(address to, uint amount) external onlyStore {
         // need baseURI?
        
        for(uint i = 0; i< amount; i++){
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(to, tokenId);
            _setTokenURI(tokenId, "uri");
        }
    }
    function mint(address to, uint mintThrow ) external onlyStore {
         // need baseURI?
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, "uri");
    }

    // function useGC(address _address) external onlyProfile {

    // }
    // function checkGC() returns(bool) {

    // }

    function withdrawToken(address _tokenContract, uint256 _amount)
        external
        onlyOwner
    {
        IERC20 tokenContract = IERC20(_tokenContract);

        tokenContract.transfer(msg.sender, _amount);
    }

    // ------ PUBLIC FUNCTIONS

    // ------------------------------------------
    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
