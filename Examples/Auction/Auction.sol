contract Auction {
/***
	Implementation of a reverse auction where bidders offer to take decreasing prize amounts for a fixed payment. The bidder who has offered to take the lowest prize value is the winner. The auction terminates after a fixed amount of time, or if no one submits a new winning bid for one hour. Upon termination, the system mints an amount of tokens equal to the winning bid’s prize value, and transfers it to the winner.
****/


	//inling  code of Token so everthing is in one file
	address public owner ;
	modifier authorized { require(msg.sender == owner); _; }
    mapping (address => uint) balances;
    uint public totalSupply;
	
	function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

	function safeSub(uint256 x, uint256 y) internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }
 
	function mint(address who, uint amount) private  {
	 balances[who] = safeAdd(balances[who],amount);
     totalSupply = safeAdd(totalSupply,amount);
	}
  
	function transferTo(address _to, uint256 _value) public returns (bool success) {
      if (balances[msg.sender] >= _value  && _value > 0) {
        balances[_to] = safeAdd(balances[_to],_value);
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        return true;
      } else {
        return false;
      }
    }
    
    function balanceOf(address _owner) public view returns (uint) {
        return balances[_owner];
    }


	//     auction starts here

	struct AuctionStrcut {
		uint prize; // the prize decreasing by every bid
		uint payment; // the payment to be payed by the last winner
		address winner; //the current winner
		uint bid_expiry; 	
		uint end_time; 
	}
	
	mapping (uint => AuctionStrcut) auctions;
	
	function getAuction(uint id) public returns (uint,uint,address,uint,uint) {
		return (auctions[id].prize,auctions[id].payment,auctions[id].winner,auctions[id].bid_expiry,auctions[id].end_time);
	}
		
	function newAuction(uint id, uint payment) public authorized {
		require(auctions[id].end_time == 0); //check id in not occupied
		auctions[id] = AuctionStrcut(2**256-1,payment,owner,0,now+1 days);
                // arguments: prize, payment, winner, bid_expiry, end_time
	}
    
	function bid(uint id, uint b) public {
		require(b<auctions[id].prize); // prize can only decrease
		// new winner pays by repaying last winner
		transferTo(auctions[id].winner,auctions[id].payment);

		// update new winner with new prize
		auctions[id].prize = b;
		 auctions[id].winner = msg.sender;
		 auctions[id].bid_expiry = now + 1 hours;
	}
  
	function close(uint id)  public {
		require(auctions[id].bid_expiry != 0
         && (auctions[id].bid_expiry < now || auctions[id].end_time < now));
		mint(auctions[id].winner, auctions[id].prize);
		delete auctions[id];
	}
  
}

