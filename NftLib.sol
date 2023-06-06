// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Library is ERC1155{
    constructor() ERC1155(""){
        libAdmin=msg.sender;
    }

    uint public amountBooks = 0;
    address libAdmin;
    uint public priceForMonth = 1000 gwei;


    mapping (uint => string) bookNumber;
    mapping (uint => address) rentedTo;

    //------------Admin

    function changeAdmin(address _newAdmin) public {
        require(libAdmin==msg.sender, "Only admin");
        libAdmin = _newAdmin;
        //Переносить токены со старого администратора новую
        // uint[]  memory tokens;
        // uint[]  memory amount;
        // for (uint i=0; i<amountBooks; i++){
        //     if (balanceOf(libAdmin, i)!=0){
        //         tokens[i]=i;
        //         amount[i]=1;
        //     }
        //     else{
        //         tokens[i]=i;
        //         amount[i]=0;
        //     }
        // }
        // safeBatchTransferFrom(libAdmin, _newAdmin, tokens, amount, "");
        }
    

    function withdraw() public {
        require(libAdmin==msg.sender, "Only admin");
        payable(libAdmin).transfer(address(this).balance);
    }

    //------------Book

    function createBook(string calldata _url) public {
        require(libAdmin==msg.sender, "Only admin");
        //book creation
        bookNumber[amountBooks] = _url;
        _mint(libAdmin, amountBooks, 1, "");
        amountBooks++;
    }

    function url (uint _bookID) public view returns (string memory){
        require(_bookID<amountBooks, "Not exist");
        return bookNumber[_bookID];
    }

    function rentBook(uint _bookID, uint _month) public payable{
        require(_bookID<amountBooks, "Not exist");
        require(balanceOf(libAdmin, _bookID)!=0, "Already rented");
        require(priceForMonth*_month==msg.value, "Not enough funds");
        rentedTo[_bookID] = msg.sender;
        _setApprovalForAll(libAdmin, msg.sender, true);
        safeTransferFrom(libAdmin, msg.sender, _bookID, 1, "");
        _setApprovalForAll(libAdmin, msg.sender, false);
    }

    function whereIsBook(uint _bookID) public view returns(address){
        require(_bookID<amountBooks, "Not exist");
        return rentedTo[_bookID];
    }

    function returnBook(uint _bookID) public {
        require(msg.sender == rentedTo[_bookID], "Only admin");
        safeTransferFrom( msg.sender, libAdmin, _bookID, 1, "");
        delete rentedTo[_bookID];
    }



}
