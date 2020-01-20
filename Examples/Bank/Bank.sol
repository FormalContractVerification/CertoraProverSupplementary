contract Bank {
    mapping (address => uint256) public funds;
	uint256 public totalFunds;

    function deposit(uint256 amount) public payable {
		funds[msg.sender] += amount;
		totalFunds += amount;
    }

    function transfer(address to, uint256 amount) public {
		require(funds[msg.sender] > amount);
		funds[msg.sender] -= amount;
		funds[to] += amount;
		
    }

    function withdraw() public returns (bool success)  {
		uint256 amount = getfunds(msg.sender);
		funds[msg.sender] = 0;
		success = msg.sender.send(amount);
		totalFunds -=amount;
    }
	
	function getfunds(address account) public returns (uint256) {
		return funds[account];
	}
	
	function getTotalFunds() public returns (uint256) {
		return totalFunds;
	}

	function init_state() public {}
}