pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract NFTOTC is ERC1155{
    // change name??
    uint buyerToken=0;                 // Editor can send buyer token to a prospective buyer
    uint editorToken = 0;             //  Editor Token allows the editor to edit aspects of the contract
    uint price;                      //   price of contract sale
    bool loadAssetStatus= false;    //    tells if contract has been activated
    uint totalContracts=0;
    bool dealComplete =false;

    //Generate Buyer and editor token
    // buyer token allows a buyer the liberty to engage with the contract
    // Editor token can edit contract: price/
    constructor(string memory _URI,uint _price) ERC1155(_URI){
        price = _price;
        _mint(msg.sender,buyerToken, 1, "");
        _mint(msg.sender,editorToken, 1, "");
    }
    // Assets hold contracts and total tokens
    mapping(uint => Assets) public assets;
    struct Assets{
        address AssetContract
        uint[] tokens;
    }
    // allows only the buyer to have the liberty to buy assets in an OTC Deal
    modifier buyer{
        require(balanceOf(msg.sender,buyerToken) == 1, "user must hold buyer token");
        require(msg.value >= price,"insuficent funds");
        require(loadAssetStatus == true, "contract has not been activated");
        _;
    } 
    // allows editor of the contract to edit the price or kill the contract
    modifier editor{
        require(balanceOf(msg.sender,buyerToken) == 1, "user must hold editor token");
        _;
    }
    //Buyer can accept opffer from user 
    function buyAssets() public payable buyer return(bool){
        distrabution();
        dealComplete = true;
        return true;
    } 
    //Load assets into contract also add multiple contracts with multiple tokens
    function activate(address _contract,uint[] _tokens, bool _activate) public Editor return(bool){
        require(loadAssetStatus == false, "contract has already been activated");

        Approved public approved;
        assets[totalContracts] = Assets(_contract,_tokens)
        totalContracts++;

        loadAssetStatus = _activate;

        require(approved.isApprovedForAll(msg.sender,address(this))==true,"isApprovedForAll on token contract is false must equal true");

        //Retrive tokens from msg.sender
        //===============>
    } 
    //Editor can change price 
    function editPrice(uint _price) public Editor return(bool){
        price = _price;
    } 
    // Editor can destory contract offer and burn
    function revokeOffer(address _userOffered)  public Editor return(bool){
        require(balanceOf(_userOffered,1) == 1);
        distrabution();

        _burn(_userOffered,buyerToken, 1, "");
        return true
    }
    //Originator can redeem
    function redeemValue()Editor public return(bool){
        require(dealComplete == true, "contract still pending")
        msg.sender.call{value: address(this).balance }("");  
    }
    //issues assets to correct partries
    // if true forward loop else backweards loop
    function distrabution() internal return(bool){
        //issue assets to apropriate parties
        redeemingAssets public Token;
        uint array[] = assets[count].tokens
        //loop through list of contracts
        for(uint count=0;count<=totalContracts;count++){
            Token = redeemingAssets(assets[count].AssetContract);
            //loop thorugh contract tokens
            for(uint tokenCount=0;tokenCount<=(assets[count].tokens).length)
                safeTransfer(address(this),msg.sender,array[tokenCount],"");
        }
    }
}