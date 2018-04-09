// Указываем версию для компилятора
pragma solidity ^0.4.11;

import "./Stoppable.sol";

// Инициализация контракта
contract DAOToken is Stoppable {

    // Объявляем переменную в которой будет название токена
    string public name;
    // Объявляем переменную в которой будет символ токена
    string public symbol;
    // Объявляем переменную в которой будет число нулей токена
    uint8 public decimals;
    // цена токена
    uint256 public buyPrice;
    // Объявляем переменную в которой будет храниться общее число токенов
    uint256 public totalSupply;

    // Объявляем маппинг для хранения балансов пользователей
    mapping (address => uint256) public balanceOf;
    // Объявляем маппинг для хранения одобренных транзакций
    mapping (address => mapping (address => uint256)) public allowance;

    // Объявляем эвент для логгирования события перевода токенов
    event Transfer(address from, address to, uint256 value);
    // Объявляем эвент для логгирования события одобрения перевода токенов
    event Approval(address from, address to, uint256 value);

    event Vote(address from, int current, uint numberOfVotes);

    event Log(string _message);

    // Функция инициализации контракта
    function DAOToken(){
        // Указываем число нулей
        decimals = 0;
        // Объявляем общее число токенов, которое будет создано при инициализации
        totalSupply = 30 * (10 ** uint256(decimals));
        // 10000000 * (10^decimals)

        // "Отправляем" все токены на баланс того, кто инициализировал создание контракта токена
        balanceOf[this] = totalSupply;

        buyPrice = 0.01 ether;

        // Указываем название токена
        name = "DAOToken";
        // Указываем символ токена
        symbol = "TADAO";
    }

    // Внутренняя функция для перевода токенов
    function _transfer(address _from, address _to, uint256 _value) stoppable internal { //stoppable
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        // Проверка того, что отправителю хватает токенов для перевода
        require(balanceOf[_to] + _value >= balanceOf[_to]);

        balanceOf[_to] += _value;
        // Токены списываются у отправителя
        balanceOf[_from] -= _value;
        // Токены прибавляются получателю

        Transfer(_from, _to, _value);
        // Перевод токенов
    }

    // Функция для перевода токенов
    function transfer(address _to, uint256 _value) public {
        _transfer(this, _to, _value);
        // Вызов внутренней функции перевода
    }

    // Функция для перевода "одобренных" токенов
    function transferFrom(address _from, address _to, uint256 _value) public {
        // Проверка, что токены были выделены аккаунтом _from для аккаунта _to
        require(_value <= allowance[_from][_to]);
        allowance[_from][_to] -= _value;
        // Отправка токенов
        _transfer(_from, _to, _value);
    }

    // Функция для "одобрения" перевода токенов
    function approve(address _to, uint256 _value) public {
        allowance[msg.sender][_to] = _value;
        Approval(msg.sender, _to, _value);
        // Вызов эвента для логгирования события одобрения перевода токенов
    }

    // Функция для отправки эфиров на контракт
    function() payable {
        // Выполняем внутреннюю функцию контракта
        _buy(msg.sender, msg.value);
    }

    // Функция для отправки эфиров на контракт (вызываемая)
    function buy() payable {
        _buy(msg.sender, msg.value);
    }

    // Внутренняя функция покупки
    function _buy(address _from, uint256 _value) internal {
        // Получаем количество возможных для покупки токенов по курсу
        uint256 amount = _value * (10 ** uint256(decimals)) / buyPrice;
        // Вызываем внутреннюю функцию перевода токенов
        _transfer(this, _from, amount);
    }

    // Функция для смены названия токена
    function changeName(string _name) onlyDAO public {
        name = _name;
    }

}