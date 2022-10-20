pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Asset is ERC1155{
    uint asset=0;
    constructor(string memory _URI) ERC1155(_URI){
        _mint(msg.sender,asset, 1, "");
    }
}

interface OTC_interface{
    function buyAssets() external payable returns(bool);
    function activate(address _contract,uint[] memory _tokens, bool _activate) external returns(bool);
    function editPrice(uint _price) external returns(bool);
    function revokeOffer(address _userOffered)  external returns(bool);
    function redeemValue() external returns(bool);
}

contract OTC is ERC1155,OTC_interface{
    // change name??
    uint buyerToken=0;                 // Editor can send buyer token to a prospective buyer
    uint editorToken = 1;             //  Editor Token allows the editor to edit aspects of the contract
    uint public price;                      //   price of contract sale
    bool public activationStatus= false;    //    tells if contract has been activated
    uint public totalContracts=0;
    uint public totalTokens=0;
    bool public dealComplete =false;

    uint[] private totalsingleTokens;
    uint[] private tmpsingletoken;
    uint[] private tokenList;

    Asset public Approved;
    //Generate Buyer and editor token
    // buyer token allows a buyer the liberty to engage with the contract
    // Editor token can edit contract: price/
    constructor(string memory _URI,uint _price, address _token) ERC1155(_URI){
        Approved = Asset(_token);
        price = _price;
        _mint(msg.sender,buyerToken, 1, "");
        _mint(msg.sender,editorToken, 1, "");
    }
    // Assets hold contracts and total tokens
    mapping(uint => Assets) public assets;
    struct Assets{
        address AssetContract;
        uint[] tokens;
    }
    // allows only the buyer to have the liberty to buy assets in an OTC Deal
    modifier buyer{
        require(balanceOf(msg.sender,buyerToken) == 1, "user must hold buyer token");
        require(msg.value >= price,"insuficent funds");
        require(activationStatus == true, "contract has not been activated");
        _;
    } 
    // allows editor of the contract to edit the price or kill the contract
    modifier editor{
        require(balanceOf(msg.sender,buyerToken) == 1, "user must hold editor token");
        _;
    }
    //Buyer can accept opffer from user 
    function buyAssets() public payable buyer returns(bool){
        distrabution();
        dealComplete = true;
        return true;
    } 
    //Load assets into contract also add multiple contracts with multiple tokens
    function activate(address _contract,uint[] memory _tokens, bool _activate) public editor returns(bool){
        require(activationStatus == false, "contract has already been activated");

        assets[totalContracts] = Assets(_contract,_tokens);
        totalContracts++;

        activationStatus = _activate;

        require(Approved.isApprovedForAll(msg.sender,address(this))==true,"isApprovedForAll on token contract is false must equal true");
        totalTokens += _tokens.length;
        //Retrive tokens from msg.sender
         delete tmpsingletoken;

        for(uint i; i <= tokenList.length;i++){
            tmpsingletoken.push(1);
        }

        Approved.safeBatchTransferFrom(msg.sender,address(this),_tokens,tmpsingletoken,"");

        return true;

    } 
    //Editor can change price 
    function editPrice(uint _price) public editor returns(bool){
        price = _price;
        return true;
    } 
    // Editor can destory contract offer and burn
    function revokeOffer(address _userOffered)  public editor returns(bool){
        require(balanceOf(_userOffered,1) == 1);
        require(dealComplete= false, "Deal already complete");
        distrabution();

        _burn(_userOffered,buyerToken, 1);
        return true;
    }
    //Originator can redeem
    function redeemValue() editor public returns(bool){
        require(dealComplete == true, "contract still pending");
        require(dealComplete= false, "Deal already complete");

        msg.sender.call{value: address(this).balance }("");  
        return true;
    }
    //issues assets to correct parties
    // if true forward loop else backweards loop
    function distrabution() internal returns(bool){
        //issue assets to apropriate parties
        //loop through list of contracts

        for(uint count=0;count<=totalContracts;count++){
            //Token = redeemingAssets(assets[count].AssetContract);
            //loop thorugh contract tokens
            tokenList = assets[count].tokens;
            for(uint i; i <= tokenList.length;i++){
                totalsingleTokens.push(1);
            }    
            Approved.safeBatchTransferFrom(address(this),msg.sender,assets[count].tokens,totalsingleTokens,"");
        }
        return true;
    }
}
