// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Lib is ERC1155 {
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
    }

    function withdraw() public {
        require(libAdmin==msg.sender, "Only admin");
        payable(libAdmin).transfer(address(this).balance);
    }

    //------------Book

    function createBook(string calldata _metadata) public {
        require(libAdmin==msg.sender, "Only admin");
        //book creation
        _mint(libAdmin, amountBooks, 1, "");
        bookNumber[amountBooks] = _metadata;
        amountBooks++;

    }

    function bookInfo(uint _bookID) public view returns ( string memory){
        require(_bookID<amountBooks, "Not exist");
        return bookNumber[_bookID];
    }

    function rentBook(uint _bookID, uint _month) public payable{
        require(_bookID<amountBooks, "Not exist");
        require(priceForMonth*_month==msg.value, "Not enough funds");
        require(balanceOf(libAdmin, _bookID)!=0, "Already rented");
         _setApprovalForAll(libAdmin, msg.sender, true);
        safeTransferFrom(libAdmin, msg.sender, _bookID, 1, "");
         _setApprovalForAll(libAdmin, msg.sender, false);
        rentedTo[_bookID] = msg.sender;
    }

    function whereIsBook(uint _bookID) public view returns(address){
        require(_bookID<amountBooks, "Not exist");
        return rentedTo[_bookID];
    }

    function returnBook(uint _bookID) public {
        require(msg.sender ==rentedTo[_bookID], "Only admin");
        safeTransferFrom(msg.sender, libAdmin, _bookID, 1, "");
        delete rentedTo[_bookID];
    }

}
