pragma solidity ^0.4.11;

import "./ChangableToken.sol";
import "./DAOBaseContract.sol";

// Контракт ДАО
contract DAOPriceContract is DAOBaseContract {

    // Функция инициализации ( принимает адрес токена)
    function DAONameContract(ChangableToken _token){
        token = _token;
    }

    // Функция для смены имени токена
    function changePrice() active public {

        // Проверяем, что было достаточное количество голосов
        require(election.numberOfVotes >= minVotes);

        // Логика для смены символа
        if (election.current > 0) {
            token.changePrice(proposalPrice);
        }

        resetVoted();
    }
}