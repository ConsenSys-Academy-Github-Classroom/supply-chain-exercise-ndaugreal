// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;
//pragma experimental ABIEncoderV2;

contract SupplyChain {

  // <owner>
  address public owner; 

  // <skuCount>
  uint public skuCount;

  // <items mapping>
  mapping(uint => Item) public items;
  // Item[] public items;

  // <enum State: ForSale, Sold, Shipped, Received>
  enum State {
    ForSale,
    Sold,
    Shipped,
    Received
  }

  // <struct Item: name, sku, price, state, seller, and buyer>
  struct Item {
    //State state;
    string name;
    uint sku;
    uint price;
    State state;
    address payable seller;
    address payable buyer;
  }
  


  /* 
   * Events
   */

  // <LogForSale event: sku arg>

  event LogForSale(uint indexed sku);
  // event LogForSale(uint sku);

  // <LogSold event: sku arg>
  event LogSold(uint indexed sku);

  // <LogShipped event: sku arg>
  event LogShipped(uint indexed sku);

  // <LogReceived event: sku arg>
  event LogReceived(uint indexed sku);


  /* 
   * Modifiers
   */

  // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract

  // <modifier: isOwner

  modifier isOwner () {
    require (msg.sender == owner);
    _;
  }

  modifier verifyCaller (address _address) { 
    require (msg.sender == _address); 
    _;
  }

  modifier paidEnough(uint _price) { 
    require(msg.value >= _price); 
    _;
  }

  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
  }

  // For each of the following modifiers, use what you learned about modifiers
  // to give them functionality. For example, the forSale modifier should
  // require that the item with the given sku has the state ForSale. Note that
  // the uninitialized Item.State is 0, which is also the index of the ForSale
  // value, so checking that Item.State == ForSale is not sufficient to check
  // that an Item is for sale. Hint: What item properties will be non-zero when
  // an Item has been added?

  modifier forSale(uint _sku) {
    //const item = items[_sku];
    require(items[_sku].seller!= address(0) && items[_sku].state == State.ForSale);
    _;
  }

  modifier sold(uint _sku) {
    require(items[_sku].state == State.Sold);
    _;
  }

  modifier shipped(uint _sku) {
    require(items[_sku].state == State.Shipped);
    _;
  }

  modifier received(uint _sku) {
    require(items[_sku].state == State.Received);
    _;
  }
  

  constructor() public {
    // 1. Set the owner to the transaction sender
    owner = msg.sender;

    // 2. Initialize the sku count to 0. Question, is this necessary?
    skuCount = 0;
  }

  function addItem(string memory _name, uint _price) public returns (bool) {
    // 1. Create a new item and put in array

    items[skuCount] = Item({
      name: _name,
      sku: skuCount,
      price: _price,
      state: State.ForSale, 
      seller: msg.sender,
      buyer: address(0)
      //seller: payable(msg.sender),
      //buyer: payable(address(0))
    });

    // 3. Emit the appropriate event
    emit LogForSale(skuCount);

    // 2. Increment the skuCount by one
    skuCount += 1;
    //skuCount = skuCount + 1;

    // 4. return true
    return true;

    // hint:
    // items[skuCount] = Item({
    //  name: _name, 
    //  sku: skuCount, 
    //  price: _price, 
    //  state: State.ForSale, 
    //  seller: msg.sender, 
    //  buyer: address(0)
    //});
    //
    //skuCount = skuCount + 1;
    // emit LogForSale(skuCount);
    // return true;
  }

  // Implement this buyItem function. 
  // 1. it should be payable in order to receive refunds
  function buyItem(uint sku) public payable 
  // 5. this function should use 3 modifiers to check 
  //    - if the item is for sale, 
  //    - if the buyer paid enough, 
  //    - check the value after the function is called to make 
  //      sure the buyer is refunded any excess ether sent. 
       forSale(sku)
       paidEnough(items[sku].price)
       checkValue(sku)
  {
  // 2. this should transfer money to the seller, 
    items[sku].seller.transfer(items[sku].price);
  // 3. set the buyer as the person who called this transaction, 
    items[sku].buyer = msg.sender;
  // 4. set the state to Sold. 
    items[sku].state = State.Sold;
  // 6. call the event associated with this function!
    emit LogSold(sku);
  }

  function shipItem(uint sku) public 
  // 1. Add modifiers to check:
  //    - the item is sold already 
  //    - the person calling this function is the seller. 
          sold(sku) 
          verifyCaller(items[sku].seller)
  {
    // 2. Change the state of the item to shipped. 
    items[sku].state = State.Shipped;
    // 3. call the event associated with this function!
    emit LogShipped(sku);

  }


  function receiveItem(uint sku) public 
  // 1. Add modifiers to check 
  //    - the item is shipped already 
  //    - the person calling this function is the buyer. 
          shipped(sku)
          verifyCaller(items[sku].buyer)
  {
    // 2. change the state of the item to received. 
    items[sku].state = State.Received;
  // 3. call the event associated with this function!
    emit LogReceived(sku);

  }

  // uncomment the following code block. it is needed to run tests
  function fetchItem(uint _sku) public view 
     returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) 
   { 
     name = items[_sku].name; 
     sku = items[_sku].sku; 
     price = items[_sku].price; 
     state = uint(items[_sku].state); 
     seller = items[_sku].seller; 
     buyer = items[_sku].buyer; 
     return (name, sku, price, state, seller, buyer); 
   } 
}
