// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

error NotStore();
error ProductCollectionNotFound();

// TODO: change to 1155
contract ShuoNFTProduct is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    IERC20 public s_token;
    // Store Contract
    address public s_storeAddress;

    struct Product {
        uint256 productId;
        string metadataUri;
        string category;
    }

    mapping(uint256 => Product) public s_productCollections;
    mapping(uint256 => Product) public s_tokenProductCollection;

    event CollectionCreated(uint256 productId, string uri, string category);

    // ------------------------------------------

    constructor() ERC721("Shuo Product", "SP") {
        safeMint(msg.sender, "uri");
    }

    // ------ MODIFIER
    modifier onlyStore() {
        if (msg.sender != s_storeAddress) {
            revert NotStore();
        }
        _;
    }

    // ------ OWNER
    // 1.
    function setStoreAddress(address _storeAddress) external onlyOwner {
        s_storeAddress = _storeAddress;
    }

    function withdrawToken(address _tokenContract, uint256 _amount)
        external
        onlyOwner
    {
        IERC20 tokenContract = IERC20(_tokenContract);

        tokenContract.transfer(msg.sender, _amount);
    }

    // ------ STORE
    function createCollection(
        uint256 _productId,
        string memory _metadataUri,
        string memory _category
    ) external onlyStore {
        Product memory product = Product(_productId, _metadataUri, _category);
        s_productCollections[_productId] = product;
        emit CollectionCreated(_productId, _metadataUri, _category);
    }

    function mint(address _to, uint256 _productId) external onlyStore {
        Product memory product = s_productCollections[_productId];
        if (product.productId == 0) {
            revert ProductCollectionNotFound();
        }
        s_productCollections[_tokenIdCounter] = product;
        _safeMint(_to, _tokenIdCounter);
        _tokenIdCounter++;
    }

    // ------ PUBLIC FUNCTIONS

    function getOwnedProducts(address _owner)
        external
        view
        returns (Product[] memory)
    {
        uint256 balance = balanceOf(_owner);
        Product[] memory products = new Product[](balance);
        for (uint256 i = 0; i < balance; i += 1) {
            uint256 tokenId = tokenOfOwnerByIndex(_owner, i);
            Product memory product = tokenProductCollection[tokenId];
            products[i] = product;
        }
        return products;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        Product memory product = s_productCollections[tokenId];
        return product.metadataUri;
    }

    // ------------------------------------------
}
