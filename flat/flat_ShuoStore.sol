// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: Store.sol


pragma solidity ^0.8.4;




//
interface IProductFactory {
    function mint(address to, uint256 productId) external;

    function balanceOf(address owner) external view returns (uint256 balance);

    function createCollection(
        uint256 productId,
        string memory uri,
        string memory category
    ) external;
}
interface ISubscriptionNFT {
    function mint(address to) external;
    function balanceOf(address owner) external view returns (uint256 balance);

}
interface IProfileToken {
    function getParent(address _child) external view returns (address);
}

interface ISocialPoints {
    function issuePoints(address to, uint256 points) external;
}

// error ErrorPricing(address nftAddress, uint256 price);
// error BalanceToLow(uint256 buyerBalance);
// error InvalidLength();


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

    uint256 public s_subscriptionProductID = 99;
    uint256 public s_maxParentTree;
    uint256[] public s_products;
    uint256[] public s_uints;

    // address
    ISubscriptionNFT public s_subscriptionsContract;
    IProfileToken public s_profileContract;
    ISocialPoints public s_socialPoints;
    address public s_vendorAddress;
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
    event Distributed(
        address indexed from,
        address indexed to,
        uint256 amount
    );
    constructor() {
        // s_subscriptionProductID =
        // s_tokenPayment = 
        // s_fakeUSD =
        // s_subscriptionsContract =
        // s_profileContract =
        // s_vendorAddress =
        // s_maxParentTree
        // s_uints[]
    }


    // ------ OWNER
    function setSubscriptionAddress(ISubscriptionNFT _address) onlyOwner external{
        s_subscriptionsContract = _address;
    }
    function setProfileTokenAddress(IProfileToken _address) onlyOwner external{
        s_profileContract = _address;
    }
    function setSocialPoints(ISocialPoints _address) onlyOwner external{
        s_socialPoints = _address;
    }
    function setVendorAddress(address _address) onlyOwner external{
        s_vendorAddress = _address;
    }
    function setTokenPayment(IERC20 _address) onlyOwner external{
        s_tokenPayment = _address;
    }
    function setFakeUSD(IERC20 _address) onlyOwner external{
        s_fakeUSD = _address;
    }

  
    function setDistributionUnits( uint256 _maxTree, uint256[] memory _units) onlyOwner external  {

        require(_units.length == _maxTree ,"Invalid Length");

        s_maxParentTree = _maxTree;
        s_uints = _units;
    }


    function listingProduct(
        uint256 _productId,
        uint256 _price,
        uint256 _socialPoints,
        string memory _uri,
        string memory _category,
        address _nftAddress
    ) external onlyOwner {
        if(_productId != s_subscriptionProductID){
            IProductFactory(_nftAddress).createCollection(
                _productId,
                _uri,
                _category
            );
        }
        s_storeItems[_productId] = StoreItem(
            _price,
            _socialPoints,
            _uri,
            _category,
            _nftAddress
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

    // INTERNAL ---
     function distributeParents(
        address _child,
        uint256 _totalPayment
    ) internal {
        address[] memory parentsChain = _getParentsChain(_child);
        uint256 distributed;

        for (uint256 i = 0; i < s_maxParentTree; i++) {
            if (parentsChain[i] == address(0)) continue;
            if (!_isSubscribed(parentsChain[i])) continue;

            uint256 amount = (_totalPayment * (s_uints[i])) / 1000;

            s_tokenPayment.transferFrom(_child, parentsChain[i], amount);
            distributed += amount;

            emit Distributed(_child, parentsChain[i], amount);
        }

        s_tokenPayment.transferFrom(
            _child,
            s_vendorAddress,
            _totalPayment - distributed
        );
    }

    function _isSubscribed(address _user) internal view returns (bool) {
        return  s_subscriptionsContract.balanceOf(_user) != 0;
    }

    function _getParentsChain(address _child)
        internal view
        returns (address[] memory parentsChain)
    {
        parentsChain = new address[](s_maxParentTree);
        address currentParent = _child;
        for (uint256 i = 0; i < s_maxParentTree; i++) {
            currentParent = s_profileContract.getParent(currentParent);
            parentsChain[i] = currentParent;
        }
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

        // if (item.price > buyerBalance || item.price >= allowance) {
        //     revert ErrorPricing(item.nftAddress, item.price);
        // }
        require(item.price < buyerBalance && item.price <= allowance, "Error Price");


        // distribute to parents
        distributeParents(msg.sender, item.price);

        // mint product & subscription
        if (_productId != s_subscriptionProductID) {
            // if first time, give SUBS-NFT : hack-thon demo feature
            if(IProductFactory(item.nftAddress).balanceOf(msg.sender) == 0) {
                // todo: boundary not duplicate?
                // ISubscriptionNFT(item.nftAddress).balanceOf(msg.sender) == 0
                s_subscriptionsContract.mint(msg.sender);
            }

            IProductFactory(item.nftAddress).mint(msg.sender, _productId);
        } else {
            // mint subscription
            // address of SUBSCRIPTION NFT
            s_subscriptionsContract.mint(msg.sender);
        }

        s_socialPoints.issuePoints(msg.sender, item.socialPoints);
      
        emit ItemBought(msg.sender, item.nftAddress, item.price);
    }

    function testPoints(uint points)external{
       s_socialPoints.issuePoints(msg.sender, points);
    }

    function testSubscribe()external{
        s_subscriptionsContract.mint(msg.sender);
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
// setup subs_contract address
// setup profile contract address

// PRODUCTS
// - set subscription product -> with subscriptionNFT address
// LOOT_BOX

// PRODUCTS_NFT -> MINT GIFTCODES
// events

