//SPDX-License-Identifier: MIT 

pragma solidity 0.8.30;

//EJEMPLO DE BANCO MAL HECHO, NO HACER DE ESTA FORMA!!
contract KipuBank{
    mapping (address => uint256) balances;

    event DepositRequest(address from, uint amount);
    event Deposited(address from, uint amount);
    event ExtractionRequest(address to, uint amount);
    event Extracted(address to, uint amount);

    function deposit() public payable {
        emit DepositRequest(msg.sender, msg.value);
        require(msg.value > 0, "No podes depositar 0");

        balances[msg.sender] += msg.value;
        
        emit Deposited(msg.sender, msg.value);
    }

    function extract(uint amount) public {
        emit ExtractionRequest(msg.sender, amount);
        require(amount > 0, "No podes extraer 0");
        require(amount <= balances[msg.sender], "Saldo insuficiente");
        

        balances[msg.sender] -= amount;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Extraccion fallida.");
        
        emit Extracted(msg.sender, amount);        
    }

    function getBalance() external view returns(uint balance_) {
        balance_ = balances[msg.sender];
    }


}