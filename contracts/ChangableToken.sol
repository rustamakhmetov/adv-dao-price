pragma solidity ^0.4.0;

// Интерфейс токена
interface ChangableToken {
    function stop();
    function start();
    function changePrice(uint256 price);
    function balanceOf(address user) returns (uint256);
}
