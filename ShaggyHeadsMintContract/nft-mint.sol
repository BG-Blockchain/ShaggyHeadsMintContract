// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// Open Zeppelin imports
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Inherits
contract NFT is ERC721Enumerable, Ownable {
  using Strings for uint256; 

  string public baseURI; 
  string public baseExtension = ".json"; 
  uint256 public cost;
  uint256 public maxSupply; 
  uint256 public maxMintAmount; 
  bool public paused = false;
  mapping(address => uint256) public addressMintedBalance;

  constructor(
    string memory _name, 
    string memory _symbol, 
    string memory _initBaseURI, // usually in form of ipfs://<CID>
    uint256 _maxSupply,
    uint256 _maxMintAmount,
    uint256 _costInWei
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setSupply(_maxSupply);
    setmaxMintAmount(_maxMintAmount);
    setCost(_costInWei);
  }





  // internal
  function _baseURI() internal view virtual override returns (string memory) { 
    return baseURI;
  }

  // public
  function mint(address _to, uint256 _mintAmount) public payable { 
    require(!paused, "the contract is paused"); 
    uint256 supply = totalSupply();
    require(_mintAmount > 0, "need to mint at least 1 NFT"); 
    require(_mintAmount <= maxMintAmount, "max mint amount per session exceeded");
    require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

    if (msg.sender != owner()) { 
        require(msg.value == cost * _mintAmount, "insufficient funds");
    }
    
    for (uint256 i = 1; i <= _mintAmount; i++) {
      addressMintedBalance[_to]++;
      _safeMint(_to, supply + i);
    }
    payable(owner()).transfer(msg.value);
  }

  function walletOfOwner(address _owner) /// Returns list of all token ids owned by given wallet
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount); 
    for (uint256 i; i < ownerTokenCount; i++) { 
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i); 
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual 
    override 
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    ); 

    string memory currentBaseURI = _baseURI(); 
    return bytes(currentBaseURI).length > 0 
        ? string(abi.encodePacked(currentBaseURI, "/", tokenId.toString(), baseExtension)) //Change "/NFTname" to "/YourNFTName". If is fine to use no name but DO NOT REMOVE THE SLASH
        : ""; 
  }

  //only owner
  
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }
  
  function setSupply(uint256 _newSupply) public onlyOwner {
    maxSupply = _newSupply;
  }


  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
 
}