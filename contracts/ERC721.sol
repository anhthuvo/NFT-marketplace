pragma solidity ^0.8.4;

contract ERC721 {
    mapping(address => uint256) internal balances;
    mapping(uint256 => address) internal owners;
    mapping(address => mapping(address => bool)) private operators;
    mapping(uint256 => address) private approvals;

    event Transfer( address indexed _from, address indexed _to, uint256 indexed _tokenId );
    event Approval( address indexed _owner, address indexed _approved, uint256 indexed _tokenId );
    event ApprovalForAll( address indexed _owner, address indexed _operator, bool _approved );

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "Address is zero");
        return balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = owners[_tokenId];
        require(owner != address(0), "NFT belongs to zero address");
        return owner;
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operators[_owner][_operator];
    }

    function approve(address _approved, uint256 _tokenId) public payable {
        address owner = ownerOf(_tokenId);
        require(_approved != address(0), "Address is zero");
        require( owner == msg.sender || isApprovedForAll(owner, msg.sender), "Unauthorized");
        approvals[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        require(owners[_tokenId] != address(0), "NFT belongs to zero address");
        return approvals[_tokenId];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public payable {
        address owner = owners[_tokenId];
        require(owner != address(0), "NFT belongs to zero address");
        require(owner == _from , "From is not the owner of token");
        require(msg.sender == owner || getApproved(_tokenId) == msg.sender || isApprovedForAll(owner, msg.sender), "msg.sender is unauthorized to transfer");
        approve(_to, _tokenId);
        owners[_tokenId] = _to;
        balances[_to] += 1;
        balances[_from] -= 1;
        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public payable {
        transferFrom(_from, _to, _tokenId);
        require(_checkOnERC721Received(), "Receiver not implemented");
    }

    function _checkOnERC721Received() private pure returns(bool) {
        return true;
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
        safeTransferFrom(_from, _to, _tokenId, "");
    }
    
    function supportsInterface(bytes4 interfaceID) public pure virtual returns(bool){
        return interfaceID == 0x80ac58cd;
    }
}
