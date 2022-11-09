// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";


// interfaces, abstract contract
interface IProductFactory {
    function mint(address to, uint256 productId) external;

    function mint(address to) external;

    function createCollection(
        uint256 productId,
        string memory uri,
        string memory category
    ) external;
}
interface ISubscriptionNFT {
    function mint(address to) external;
}


error ErrorPricing(address nftAddress, uint256 price);
error BalanceToLow(uint256 buyerBalance);

// payback
contract ShuoStore is Ownable {
    struct StoreItem {
        uint256 price;
        uint256 socialPoints;
        string uri;
        string category;
        address nftAddress;
    }

    mapping(uint256 => StoreItem) public s_storeItems;
    mapping(uint256 => uint256) public s_productArrayIndexes;
    uint256[] public s_products;
    uint256 public s_subscriptionProductID;
    IERC20 public s_tokenPayment;
    IERC20 public s_fakeUSD;

    event ItemBought(address buyer, address nftAddress, uint256 price);
    event CreatedProduct(
        uint256 productId,
        uint256 price,
        uint256 socialPoints,
        string uri,
        string category,
        address nftAddress
    );
    constructor() {
        // s_subscriptionProductID =
        // s_tokenPayment = 
        // s_fakeUSD =
        // s_subscriptionNF =
    }


    // ------ OWNER
    function listingProduct(
        uint256 _productId,
        address _nftAddress,
        string memory _uri,
        string memory _category,
        uint256 _socialPoints
    ) external onlyOwner {
        if(_productId != s_subscriptionProductID){
            IProductFactory(_nftAddress).createCollection(
                _productId,
                _uri,
                _category
            );
        }
        s_storeItems[_productId] = s_storeItems(
            _nftAddress,
            _price,
            _uri,
            _category,
            _socialPoints
        );
        s_products.push(_productId);
        s_productArrayIndexes[_productId] = s_products.length - 1;

        emit CreatedProduct(
            _productId,
            _price,
            _socialPoints,
            _uri,
            _category,
            _nftAddress
        );
    }

    function removeListedProduct(uint256 _productId) onlyOwner external{

    }

    // ------ PUBLIC
    // MINT SUBSCRIPTION first time on buy product
    // on FE -> check balance -> approve
    function purchaseProduct(uint256 _productId) external  {
        StoreItem memory item = s_storeItems[_productId];

        require(item.price != 0, "Product price is missing");
        require(
            item.nftAddress != address(0),
            "Product address is missing"
        );

        // prepare pay with ERC20
        uint256 allowance = s_tokenPayment.allowance(msg.sender, address(this));
        uint256 buyerBalance = s_tokenPayment.balanceOf(msg.sender);

        if (item.price > buyerBalance || item.price >= allowance) {
            revert ErrorPricing(item.nftAddress, item.price);
        }

        // hack-thon => airdrop fakeUSD
        // s_fakeUSD.transfer

        // distribute to parents
        // distributeParents()

        // mint product & subscription
        if (_productId != s_subscriptionProductID) {
            IProductFactory(item.nftAddress).mint(msg.sender, _productId);
              // if first time, give SUBS-NFT : hack-thon demo feature
            if(IProductFactory(item.nftAddress).balanceOf(msg.sender) == 0) {
                ISubscriptionNFT(item.nftAddress).mint(msg.sender);
            }
        } else {
            // mint subscription
            // address of SUBSCRIPTION NFT
            ISubscriptionNFT(item.nftAddress).mint(msg.sender);
        }
      
        emit ItemBought(msg.sender, item.nftAddress, item.price);
    }


    function getProductPrice(uint256 _productId)
        external
        view
        returns (uint256)
    {
        return s_storeItems[_productId].price;
    }
   function getStoreItem(uint256 _productId)
        external
        view
        returns (StoreItem memory)
    {
        return s_storeItems[_productId];
    }
}



// --------------------------------------------

// interface GC, Product, Social, Subscription

// deploy store
// setup contract -> ProductFactory, SocialPoints, Subscription

// setup vendorAddress
// setup s_subscriptionProductID

// PRODUCTS
// - set subscription product -> with subscriptionNFT address
// LOOT_BOX

// PRODUCTS_NFT -> MINT GIFTCODES
// events





// -- test why cannot send freeUSD?