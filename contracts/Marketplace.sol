pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./utils/Common.sol";

contract Marketplace is ReentrancyGuard, UtilsCommon {
    uint256 internal feePercent;
    address payable feeReciever;
    using Counters for Counters.Counter;
    Counters.Counter private _itemCount;
    Counters.Counter private _onSaleItemCount;
    mapping(uint256 => Item) private itemList;
    mapping(address => uint256) private balanceOf;
    
    event ImportItemToMarket(
        uint256 indexed id,
        uint256 tokenId,
        address nftAddress,
        address owner,
        uint256 price
    );

    event SellItem(
        uint256 indexed id,
        address nftAddress,
        uint256 tokenId,
        address owner,
        uint256 price
    );

    event PurchaseItem(
        uint256 indexed id,
        address nftAddress,
        uint256 tokenId,
        address seller,
        address buyer,
        uint256 price
    );

    struct Item {
        uint256 id;
        uint256 tokenId;
        address nftAddress;
        uint256 price;
        address payable owner;
        bool onSale;
    }

    constructor() {
        feePercent = 1;
        feeReciever = payable(msg.sender);
    }



    // Import item to Market
    // check:
    // - NFT contract support interface ERC721
    // - price > 0
    // - owner owned token
    function importItem(
        address nftAddress,
        address payable owner,
        uint256 tokenId,
        uint256 price
    ) public {
        IERC721 nft = IERC721(nftAddress);
        address _owner = nft.ownerOf(tokenId);
        require(nft.supportsInterface(0x80ac58cd), "NFT do not support ERC721");
        require(owner == _owner, "Owner does not owned NFT");
        require(price > 0, "Price must be higher than 0");

        nft.setApprovalForAll(address(this), true);
        _itemCount.increment();
        uint256 newItemId = _itemCount.current();
        itemList[newItemId] = Item(
            newItemId,
            tokenId,
            nftAddress,
            price,
            owner,
            false
        );
        balanceOf[owner] += 1;
        emit ImportItemToMarket(newItemId, tokenId, nftAddress, owner, price);
    }

    function sellItem(uint256 id, uint256 price) external {
        Item memory item = itemList[id];
        IERC721 nft = IERC721(item.nftAddress);
        address _owner = nft.ownerOf(item.tokenId);
        require(item.price > 0, "NFT does not exist");
        require(msg.sender == _owner, "Owner does not owned NFT");
        if (item.price != price) {
            itemList[id].price = price;
        }
        itemList[id].onSale = true;
        emit SellItem(id, item.nftAddress, item.tokenId, _owner, price);
    }

    function getMyNFTs(uint256 pageSize, uint256 currentPage) external view returns (Item[] memory, uint256, uint256, uint256) {
        uint256 balance = balanceOf[msg.sender];
        validatePage(pageSize, currentPage, balance);
        uint256 end = Math.min(currentPage*pageSize, balance);
        uint256 start = Math.max(currentPage*pageSize - pageSize + 1, 1);
        
        Item[] memory myNFTs = new Item[](start - end + 1);
        uint256 myNFTsCount = 0;
        uint256 collectedNFTsCount = 0;
        for (uint256 i = _itemCount.current(); i <= 1; i--) {
            if (itemList[i].owner == msg.sender) {
                myNFTsCount += 1;
                if (myNFTsCount >= start && myNFTsCount <= end) {
                  myNFTs[collectedNFTsCount] = itemList[i];
                  collectedNFTsCount += 1;
                }
            }
        }
        return (myNFTs, pageSize, currentPage, balance);
    }

    function getOnSaleNFTs(uint256 pageSize, uint256 currentPage) external view returns (Item[] memory, uint256, uint256, uint256) {
        validatePage(pageSize, currentPage, _onSaleItemCount.current());
        uint256 end = Math.min(currentPage*pageSize, _onSaleItemCount.current());
        uint256 start = Math.max(currentPage*pageSize - pageSize + 1, 1);

        Item[] memory onSaleNFTs = new Item[](start - end + 1);
        uint256 onSaleNFTsCount = 0;
        uint256 collectedNFTsCount = 0;
        for (uint256 i = _itemCount.current(); i <= 1; i--) {
            if (itemList[i].onSale) {
                onSaleNFTsCount += 1;
                if (onSaleNFTsCount >= start && onSaleNFTsCount <= end) {
                  onSaleNFTs[collectedNFTsCount] = itemList[i];
                  collectedNFTsCount += 1;
                }
            }
        }
        return (onSaleNFTs, pageSize, currentPage, _onSaleItemCount.current());
    }

    function purchaseNFT(uint256 id) public payable {
      Item memory item = itemList[id];
      require(id > 0, "Item does not exist");
      require(item.onSale, "NFT isn't on sale");
      uint256 totalPrice = item.price + item.price*feePercent/100;
      require(msg.value >= totalPrice, "Your balance cannot afford NFT");
      
      item.owner.transfer(item.price);
      feeReciever.transfer(item.price*feePercent/100);
      
      ERC721 nft = ERC721(item.nftAddress);
      nft.transferFrom(item.owner, msg.sender, item.tokenId);
      address oldOwner = item.owner;
      balanceOf[item.owner] -= 1;
      balanceOf[msg.sender] += 1;
      itemList[id].onSale = false;
      itemList[id].owner = payable(msg.sender);
      _onSaleItemCount.decrement();

      emit PurchaseItem(
        item.id,
        item.nftAddress,
        item.tokenId,
        oldOwner,
        msg.sender,
        totalPrice
    );
    }

    function _getFeePercent() external returns(uint256) {
      return feePercent;
    }
}
