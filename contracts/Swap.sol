// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
// import "@OpenZeppelin/contracts/token/ERC20/IERC20.sol";
import "./TokenA.sol";
import "./TokenB.sol";

contract Swap {
   
    uint256 public xchange;

    TokenA public tokenA;
    TokenB public tokenB;

    constructor(
        address _tokenA,
        address _tokenB,
        uint256 _xchange
    ) {
        tokenA = TokenA(_tokenA);
        tokenB = TokenB(_tokenB);
        xchange = _xchange;
    }

    modifier payFee(uint256 _amount, address token) {
    uint256 total = _amount * xchange;
    uint256 fee = (total * 1) / 100; 
    uint256 amountToTransfer = total - fee;
    _;

    require(
        IERC20(token).transfer(address(this), fee),
        "Fee transfer failed"
    );
    require(
        IERC20(token).transfer(msg.sender, amountToTransfer),
        "Token transfer failed"
    );
}

    function swap(address token, uint256 _amount) public payFee( _amount, token) {
        require(_amount > 0, "Amount must be greater than zero");
        if (token == address(tokenA)) {
            _swapTokenA(_amount);
        } else if (token == address(tokenB)) {
            _swapTokenB(_amount);
        } else {
            revert("Invalid sender");
        }
    }

    function _swapTokenA(uint256 _amount) public {
        require(
            IERC20(tokenA).balanceOf(msg.sender) >= _amount,
            "Not enough TokenA balance"
        );
        require(
            IERC20(tokenA).allowance(msg.sender, address(this)) >= _amount,
            "Not enough allowance for TokenA"
        );
      

        require(
            IERC20(tokenA).transferFrom(msg.sender, address(this), _amount),
            "TokenA transfer failed"
        );
        require(
            IERC20(tokenB).transfer(msg.sender, xchange * _amount),
            "TokenB transfer failed"
        );
    }

    function _swapTokenB(uint256 _amount) public {
        require(
            IERC20(tokenB).balanceOf(msg.sender) >= _amount,
            "Not enough TokenB balance"
        );
        require(
            IERC20(tokenB).allowance(msg.sender, address(this)) >= _amount,
            "Not enough allowance for TokenB"
        );

        require(
            IERC20(tokenB).transferFrom(msg.sender, address(this), _amount),
            "TokenB transfer failed"
        );
        require(
            IERC20(tokenA).transfer(msg.sender, _amount / xchange),
            "TokenA transfer failed"
        );
    }
}