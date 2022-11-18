// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";


//
interface IGiftCode {
    function mint(address to, uint256 productId) external;
    function airdropGC(address to, uint256 amount) external;

    function balanceOf(address owner) external view returns (uint256 balance);
  
}
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



contract BacoStore is VRFConsumerBaseV2, ConfirmedOwner{
    // ------------------------VRF

     event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
        bool isGC;
        bool isDistribution;
        address _buyer;
    }
    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
    bytes32 keyHash =
        0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 2_000_000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 1;

    // ------------------------VRF

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
    uint256 public s_SURPRISE_giftcodeID = 98;
    uint256 public s_maxParentTree;
    uint256[] public s_products;
    uint256[] public s_uints;

    // address
    ISubscriptionNFT public s_subscriptionsContract;
    IProfileToken public s_profileContract;
    ISocialPoints public s_socialPoints;
    IGiftCode public s_giftcodeAddress;
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


    constructor(  
        uint64 subscriptionId,
        ISubscriptionNFT _subsAddress,
        IProfileToken _profileAddress,
        ISocialPoints _socialAddress,
        IGiftCode _gcAddress,
        address _vendorAddress,
        IERC20 _tokenPayment,
        IERC20 _fakeUSD
    )
        VRFConsumerBaseV2(0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed)
        ConfirmedOwner(msg.sender) //change to treasuryAddress instead? and use automation?
     {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed
        );
        s_subscriptionId = subscriptionId; // VRF
        // basic
        s_subscriptionsContract = _subsAddress;
        s_profileContract = _profileAddress;
        s_socialPoints = _socialAddress;
        s_giftcodeAddress = _gcAddress;
        // 
        s_vendorAddress = _vendorAddress;
        s_tokenPayment = _tokenPayment;
        s_fakeUSD = _fakeUSD;

        // distribution
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
    function setGiftCodeAddress(IGiftCode _address) onlyOwner external{
        s_giftcodeAddress = _address;
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

            //  randomDistribution(false,true)

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

    function requestRandom(bool _isGC, bool _isDistributon)
        internal
        returns (uint256 requestId)
    {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false,
            isGC: _isGC,
            isDistribution: _isDistributon,
            _buyer: msg.sender
            // bool isGC;
            // bool isDistribution;
            // address _buyer;
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        // add address?
        emit RequestSent(requestId, numWords);
        return requestId;
    }
   

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        address requesterAddress = s_requests[_requestId]._buyer;


        // - gift codes?
        if(s_requests[_requestId].isGC){
            uint amountAidrop = _randomWords[0] % 10;
            s_giftcodeAddress.airdropGC(requesterAddress, amountAidrop);
            // *points ??
        }


        // - random distribution?
        if(s_requests[_requestId].isDistribution){
            // msg.snder
            // random words
            // [address]
            // amount -> USDT
        }

        // emit ExtInfo
        emit RequestFulfilled(_requestId, _randomWords);
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

        // check balance
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

            if(_productId == s_SURPRISE_giftcodeID){
                // airdropBONUS
                requestRandom(true, false);
            }else{
                IProductFactory(item.nftAddress).mint(msg.sender, _productId);
            }

        } else {
            // mint subscription
            // address of SUBSCRIPTION NFT
            s_subscriptionsContract.mint(msg.sender);
        }

        s_socialPoints.issuePoints(msg.sender, item.socialPoints);
      
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