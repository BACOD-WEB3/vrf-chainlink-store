// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// TODO:
// - PRIVATE s_tokenPositions, s_childsParent, s_childsParent
// - set boundary for transfer token
// - flexible URI TOKEN ?

// Interface GiftCodes
contract ShuocialProfile is  ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => uint256) public s_tokenPositions;
    mapping(address => address) public s_childsParent;
    mapping(address => address[]) public s_childsParent;

    address public s_signerWL;
    string public s_baseURI;


    constructor() ERC721("ShuoCIAL Profile", "SHUO") {
        // signerWL =
        // baseURI =
    }
    // ------ MODIFIER
    modifier onlyOnce() {
           require(balanceOf(msg.sender) == 0, "You already had profile token");
        _;
    }
    // ------ OWNER
    //   function setPosition(uint256 _position, uint256 _tokenId)
    //     external
    //     onlyOwner
    // {
    //     s_tokenPositions[_tokenId] = _position;
    // }

    // function setParent(address _child, address _parent) public onlyOwner {
    //     s_childsParent[_child] = _parent;
    // }

    // function setChildren(address _parent, address[] memory _children)
    //     public
    //     onlyOwner
    // {
    //     s_parentsChild[_parent] = _children;
    // }


    // ------ PUBLIC FUNCTIONS

    // mint from whitelist
    function mintByWL(string memory uri) external onlyOnce
    {
        // TODO: add ecrecover for wl -> require  / modifier
        // --------
        // for hackthon purpose -> free mint


        // --------
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
        s_tokenPositions[tokenId] = 1;
        // TODO: airdrop fakeUSD
    }

    // mint from invitation
    function mintByCode(string memory uri, address _addressParent) external onlyOnce {
        // TODO: erecover
        // --
        uint256 parentTokenId = tokenOfOwnerByIndex(_addressParent, 0);
        uint256 parentPosition = tokenPositions[_parentTokenId];
        require(parentPosition != 0, "Parent position is zero");

        // --> CHECK GIFTCODE CONTRACT
        // --> useGiftcode


        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        // increase the position
        s_tokenPositions[tokenId] = parentPosition + 1;
        s_childsParent[msg.sender] = _addressParent;
        s_parentsChild[_addressParent].push(msg.sender);

        // TODO: airdrop fakeUSD
    }

    // mint from product
    function mintByProduct() external onlyOnce {
        // TODO:
        // store address -> validate -> mint
    }

    
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    // ------ INTERNAL
     function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        super._beforeTokenTransfer(from, to, tokenId);
        require(balanceOf(to) == 0, "The target address already has profile token" );

        address _parent = s_childsParent(from);
        address[] memory _children = s_parentsChild(from);
        s_childsParent[to] = _parent;
        s_parentsChild[to] = _children;

        // update parent 
        address[] memory _parentChilds = s_parentsChild(_parent);

        for (uint256 i = 0; i < _parentChilds.length; i++) {
            address current = _parentChilds[i];
            if (current == from) {
                _parentChilds[i] = to;
            }
        }
        s_parentsChild[_parent] = _parentChilds;

        // update parent for children
        for (uint256 i = 0; i < _children.length; i++) {
            s_childsParent[_children[i]] = to;
        }

        delete parentsChild[from];
        delete childsParent[from];
    }

}

// ----------------
// deploy, setup tokenPayment, setup vendorAddress (+ setupAddressWLSigner)
// ----------------
// 1. user need to approve contract address in fUSD before executing
// 2.
