pragma solidity ^0.8.4;

contract UtilsCommon {
    function ceil(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 remain = a%b;
      uint256 divide = a/b;
      if (remain != 0) {
        return divide + 1;
      }
      return divide;
    }

    function validatePage(uint256 pageSize, uint256 currentPage, uint256 total) internal pure {
        require(total > 0, "0 NFT in total");
        require(pageSize*currentPage > 0, "pageSize and currentPage are not higher than 0");
        uint256 totalPage = ceil(total, pageSize);
        require(currentPage > totalPage, "Current page is higher than total page");
    }
}