pragma solidity ^0.4.0;

import "./OwnableWithDAO.sol";

// Контракт для остановки некоторых операций
contract Stoppable is OwnableWithDAO{

    // Переменная для хранения состояния
    bool public stopped;

    // Модификатор для проверки возможности выполнения функции
    modifier stoppable {
        require(!stopped);
        _;
    }

    // Функция для установки переменной в состояние остановки
    function stop() onlyDAO {
        stopped = true;
    }

    // Функция для установки переменной в состояние работы
    function start() onlyDAO{
        stopped = false;
    }
}
