//SPDX-License-Identifier: MIT 

pragma solidity 0.8.30;

/**
 * @title KipuBank
 * @author Erik Borgnia
 * @notice Contrato para el TP Final del Módulo 2 del curso de EthKipu
 */
contract KipuBank{
    // Mappings que mantienen el estado de las distintas cuentas (balance, cantidad de depósitos y cantidad de extracciones)
    mapping (address user => uint256 amount) s_balances;
    mapping (address user => uint32 counter) s_deposits;
    mapping (address user => uint32 counter) s_withdrawals;
    // Que el límite por cuenta y de extracción sea a lo mucho la mitad de lo máximo que podría tener el contrato es bastante razonable.
    uint128 public immutable s_bankCap;
    uint128 public immutable s_withdrawLimit = 10000000000000;
    //10 billones (o 10 trillions) necesita 44 bits, sobra bastante pero por coherencia se lo deja uint128

    event DepositRequest(address from, uint amount);
    event Deposited(address from, uint amount);
    event ExtractionRequest(address to, uint amount);
    event Extracted(address to, uint amount);

    ///@notice error emitido cuando se intenta depositar una cantidad inválida (=0, o la cuenta superaría el bankCap)
    error DepositNotAllowed(address to, uint amount);
    ///@notice error emitido cuando se intenta extraer una cantidad inválda (<=0, >=saldo, >límite)
    error ExtractionNotAllowed(address to, uint amount);
    ///@notice error emitido cuando falla una extracción
    error ExtractionReverted(address to, uint amount, bytes errorData);

    /*
        *@notice Constructor que recibe el bankCap como parámetro
        *@param _bankCap es el máximo que podría tener el contrato en total
    */
    constructor(uint128 _banckCap) {
        s_bankCap = _banckCap;
    }

    /**
        *@notice Función para hacer un depósito
		*@notice Sólo se puede depositar un valor mayor a 0, siempre que no se supere el bankCap
    */
    function deposit() public payable {
        emit DepositRequest(msg.sender, msg.value);
        require(msg.value > 0, DepositNotAllowed(msg.sender,msg.value));
        require(msg.value+s_balances[msg.sender] <= s_bankCap, DepositNotAllowed(msg.sender,msg.value));

        s_balances[msg.sender] += msg.value;
        s_deposits[msg.sender]++;
        
        emit Deposited(msg.sender, msg.value);
    }

    /**
        *@notice Función pública para ver el balance que uno mismo tiene
    */
    function getBalance() external view returns(uint balance_) {
        balance_ = s_balances[msg.sender];
    }
    /**
        *@notice Función pública para ver la cantidad de depósitos que uno hizo
    */
    function getDeposits() external view returns(uint deposits_) {
        deposits_ = s_deposits[msg.sender];
    }
    /**
        *@notice Función pública para ver la cantidad de extracciones que uno hizo
    */
    function getWithdrawals() external view returns(uint withdrawals_) {
        withdrawals_ = s_withdrawals[msg.sender];
    }

    /**
        *@notice Función pública para ver el balance que algún usuario tiene
		*@dev Esta función garantiza que toda la información es auditable
    */
    function getBalance(address user) external view returns(uint balance_) {
        balance_ = s_balances[user];
    }
    /**
        *@notice Función pública para ver la cantidad de depósitos que algún usuario hizo
		*@dev Esta función garantiza que toda la información es auditable
    */
    function getDeposits(address user) external view returns(uint deposits_) {
        deposits_ = s_deposits[user];
    }
    /**
        *@notice Función pública para ver la cantidad de extracciones que algún usuario hizo
		*@dev Esta función garantiza que toda la información es auditable
    */
    function getWithdrawals(address user) external view returns(uint withdrawals_) {
        withdrawals_ = s_withdrawals[user];
    }

    /**
        *@notice Función para hacer un depósito
		*@dev Sólo se puede depositar un valor mayor a 0, siempre que no se supere el bankCap
        *@param amount Cantidad que se quiere extraer. Debe ser <= al balance y al límite de extracción
    */
    function withdraw(uint amount) public {
        emit ExtractionRequest(msg.sender, amount);
        require(amount > 0, ExtractionNotAllowed(msg.sender, amount));
        require(amount <= s_balances[msg.sender], ExtractionNotAllowed(msg.sender, amount));
        require(amount <= s_withdrawLimit, ExtractionNotAllowed(msg.sender, amount));
        
        transferFunds(amount);        

        s_balances[msg.sender] -= amount;
        s_withdrawals[msg.sender]++;
        
        emit Extracted(msg.sender, amount);        
    }

    /**
        *@notice Función privada que transfiere la cantidad pedida por la extracción
		*@dev Nadie puede acceder a esta función excepto ESTE contrato
        *@param amount Cantidad a transferir
    */
    function transferFunds(uint amount) private {
        (bool success, bytes memory errorData) = msg.sender.call{value: amount}("");
        require(success, ExtractionReverted(msg.sender,amount,errorData));
    }


}