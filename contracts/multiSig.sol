/**
 * The contractName contract does this and that...
 */
 pragma solidity ^0.5.11;
 
contract MultiSigWallet {

  event Deposit(address indexed sender, uint amount, uint balance);

  event SubmitTransaction(
  	address indexed owner,
  	uint indexed txIndex,
  	address indexed to,
  	uint value,
  	bytes data);

  event ConfirmTransaction(address indexed owner, uint indexed txIndex);

  event ExecuteTransaction(address indexed owner, uint indexed txIndex);

  event RevokeTransaction(address indexed owner, uint indexed txIndex);

  address[] public owners;
  uint public numConfirmationsRequired;

  struct Transaction {
  	address to;
  	uint value;
  	bytes data;
  	bool executed;
  	mapping(address => bool) isConfirmed;
  	uint numConfirmations;
  }

  function () payable external{
  	emit Deposit(msg.sender,msg.value, address(this).balance);
  }

  function deposit() payabke external{
  	emit Deposit(msg.sender,msg.value, address(this).balance);
  }
  mapping(address => bool) isOwner;
  Transaction[] public transactions;

  constructor(address[] memory _owners, uint _numConfirmationsRequired) public {
  	require(_owners.length > 0, "owners required");
  	require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length, "invalid number of required confirmations");

  	for(uint i=0; i< _owners.length; i++) {
  		address owner = _owners[i];
  		require(owner !=  address(0), "invalid owner");
  		require(!isOwner[owner], "owner not unique");

  		isOwner[owner] = true;
  		owners.push(owner);
  	}
  	numConfirmationsRequired = _numConfirmationsRequired;
  }

  function submitTransaction(address _to, uint _value, bytes memory _data) public onlyOwner {
  	uint txIndex = transactions.length;

  	transactions.push(Transaction({
  		to:_to,
  		value:_value,
  		data:_data,
  		executed:false,
  		numConfirmations:0
  		}));

  	emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);

  }

  modifier txExists(uint _txIndex) {
  	require(_txIndex < transactions.length, "tx does not exist");
  	_;
  }

  modifier notExecuted(uint _txIndex) {
  	require(!transactions[_txIndex].executed, "tx exists and has been executed");
  	_;
  }

  modifier notConfirmed(uint _txIndex) {
  	require(!transactions[_txIndex].isConfirmed[msg.sender],"tx already confirmed");
  	_;
  }

  function confirmTransaction(uint _txIndex)  
	  public 
	  onlyOwner 
	  txExists(_txIndex) 
	  notExecuted(_txIndex)
	  notConfirmed(_txIndex)
  {
  	Transaction storage transaction = transactions[_txIndex];
  	transaction.isConfirmed[msg.sender] = true;
  	transaction.numConfirmations += 1;

  	emit ConfirmTransaction(msg.sender, _txIndex);
  }

  function executeTransaction(uint _txIndex) 
  public onlyOwner 
  txExits(_txIndex)
  notExecuted(_txIndex)
  {
  	Transaction storage transaction = transactions[_txIndex];

  	require (transaction.numConfirmations >= numConfirmationsRequired, "cannot execute transaction");
  	transaction.executed = true;
  	(bool success, ) = transaction.to.call.value(transaction.value)(transaction.data);
  	require(success,"transaction failed");

  	emit ExecuteTransaction(msg.sender, _txIndex);
  	
  }
	//exercise
  function revokeTransaction() {}
  
}
