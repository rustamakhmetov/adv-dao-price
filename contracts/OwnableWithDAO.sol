// Указываем версию для компилятора
pragma solidity ^0.4.11;

// Контракт для установки прав
contract OwnableWithDAO{

    // Переменная для хранения владельца контракта
    address public owner;

    // Переменная для хранения адреса DAO
    address public daoContract;

    // Конструктор, который при создании инициализирует переменную с владельцем
    function OwnableWithDAO() {
        owner = msg.sender;
    }

    // Модификатор для защиты от вызовов не создалетя контракта
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }


    // Модификатор для защиты от вызовов не со стороны DAO
    modifier onlyDAO(){
        require(msg.sender == daoContract);
        _;
    }

    // Функция для замены владельца
    function transferOwnership(address newOwner) onlyOwner public{
        require(newOwner != address(0));
        owner = newOwner;
    }

    // Функция для установки / замены контракта DAO
    function setDAOContract(address newDAO) onlyOwner public {
        daoContract = newDAO;
    }
}