pragma solidity ^0.4.0;

import "./ChangableToken.sol";


contract DAOBaseContract {
    // Переменная для хранения токена
    ChangableToken public token;

    // Минимальное число голосов
    uint8 public minVotes = 6;

    // Переменная для предложенного названия
    string public proposalName;

    // Переменная для хранения состояния голосования
    bool public voteActive = false;

    // Стукрутра для голосов
    struct Votes {
        int current;
        uint numberOfVotes;
    }

    // Переменная для структуры голосов
    Votes public election;

    mapping (address => bool) voted;

    event Vote(address from, int current, uint numberOfVotes);

    modifier notVote() {
        require(!voted[msg.sender]);
        _;
    }

    modifier active() {
        require(voteActive);
        _;
    }

    // Функция для предложения нового символа
    function newName(string _proposalName) public {

        // Проверяем, что голосвание не идет
        require(!voteActive);
        proposalName = _proposalName;
        voteActive = true;

        // Остановка работы токена
        token.stop();
    }

    // Функция для голосования
    function vote(bool _vote) active notVote public {
        // Логика для голосования
        if (_vote){
            election.current += int(token.balanceOf(msg.sender));
        }
        else {
            election.current -= int(token.balanceOf(msg.sender));
        }
        election.numberOfVotes += token.balanceOf(msg.sender);
        voted[msg.sender] = true;
        Vote(msg.sender, election.current, election.numberOfVotes);
    }

    function resetVoted() internal {
        // Сбрасываем все переменные для голосования
        proposalName = "";
        election.numberOfVotes = 0;
        election.current = 0;
        voteActive = false;

        // Возобновляем работу токена
        token.start();
    }
}
