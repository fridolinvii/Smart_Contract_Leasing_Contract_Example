//SPDX-License-Identifier: MIT

/*  
    Date: November 2021
    Authors: Carlo Seppi, Andrey Shmelev, Lindijan Alijoski
    Github: https://github.com/fridolinvii/Smart_Contract_Leasing_Contract_Example
    
    DISCLAIMER OF LIABILITY: The authors assumes or undertakes NO LIABILITY for any loss or damage suffered as a result of the use, 
                             misuse or reliance on the information and content on this website and the code.
*/

pragma solidity ^0.8.10;

contract LeasingAgreement {
    
    // Lessee can pay with multiple address
    address public immutable recipient; // The account receiving the payments (lessor)   
    
    string public currentOwner;  // Current owner (lessor)
    string public newOwner;  // New owner (lessee)
    string public oldOwner;  // after owner transfer, that previous owner is still known

    uint public leasingTotalCost;  // Total leasing amount   
    uint public singlePayment; // Amount paid by sender (once)
    uint public recurringPayment; // Amount paid by sender (monthly)

    uint public createdTimestamp; // Agreement Created Time with Date (created, when contract is signed)
    
    string public VehicleIdentificationNumber; // Unique identification of the vehicle
    string public contractInPdf; // Give a unique link to ipfs site, where the AGB can be downloaded (open in Brave Browser)

    uint public minimumBalanceRequired; //show minimum Balance required
    // Time between payments is set in function showMinimumBalanceRequired()
     
    uint public accumulatedPayment; // how much is already paid    
    bool public isContractSigned;   // has the lessee already signed the contract
    bool public contractTerminated; // is the smart contract still active
    string public comment; // This is a comment, which can be change, e.g. why the contract ended

    // Set value: e.g. 1e18 in ETH, 1e15 is in finney, 1e9 in Gwei, 1e0 in Wei
    uint constant value = 1e15;  // in the example we use finney


    // This gives Boundary condition for the contract 
    constructor (address _recipient, string memory _currentOwner, string memory _VehicleIdentificationNumber, uint _leasingTotalCost, uint _singlePayment, uint _recurringPayment, string memory _contractInPdf)
        {
        // This Parametrs can be set during constructor (more flexibel duriong deployment)
        recipient = _recipient;
        currentOwner = _currentOwner;
        leasingTotalCost = _leasingTotalCost * value ;     // for simplification we use finney (1e15)
        singlePayment = _singlePayment * value;
        recurringPayment = _recurringPayment * value;
        VehicleIdentificationNumber = _VehicleIdentificationNumber;
        contractInPdf = _contractInPdf;        
        
        


         /* // Here fix parameter in contract (its simpler to deploy like this the contract)
        constructor () { //address _recipient, string memory _currentOwner, string memory _VehicleIdentificationNumber, uint _leasingTotalCost, uint _singlePayment, uint _recurringPayment, string memory _contractInPdf){    
        recipient = 0x000e4d3d97A8Edd4873763a9Fc83E2ff69DBfA30; //_recipient;
        currentOwner = 'Kestenholz'; //_currentOwner;
        leasingTotalCost = 10 * value; //_leasingTotalCost;    10 finney
        singlePayment = 1 * value; //_singlePayment;
        recurringPayment = 1 * value; //_recurringPayment;
        VehicleIdentificationNumber = "WPO ZZZ 91 ZDS 102 886"; //_VehicleIdentificationNumber;
        contractInPdf = "ipfs://QmQgrsdutdqL2e6FeoiX9hJLUbvHQXmuhyV9CbmcrbaqWD"; //_contractInPdf;
        */
        




        // Fixed Parameters
        //timeBetweenPayment = 1 minutes; // This should be months in leasing contract
        isContractSigned = false;
        contractTerminated = false;
    }



    // sign contract with first payment
    function signContract(string memory _newOwner) public payable{
        require(!contractTerminated, "Contract is terminated");
        require(!isContractSigned, "Contract is already signed");
        require(msg.value>=singlePayment, "Insuficient Funds");
        require(msg.value<=leasingTotalCost, "Payment surpasses leasing cost.");
        

        accumulatedPayment += msg.value;    // add minimum of the singlePayment to accumulatedPayment
        isContractSigned = true;            // Both side agree to the contract
        newOwner = _newOwner;               // Give Name of new Owner
        /* 
           Remark: - the person who signs the contract, does not have to pay.
                   - multiple addresses can pay 
                   - no refund is possible
        */

        createdTimestamp = block.timestamp; // create tinestamp for recurringPayment 
    }


    // send Payment
    function sendPayment() public payable {
        require(!contractTerminated, "Contract is terminated"); // can not do payment if contract is terminated
        require(isContractSigned, "Contract is not signed");    // can not do payment if contract is not signed
        require(accumulatedPayment+msg.value<=leasingTotalCost,"Accumulated payment would surpasses total leasing cost."); 
        accumulatedPayment += msg.value  ; // add payment to accumulatedPayment
    }
    
    // Check how much needs to be paid
    function showMinimumBalanceRequired() public {
        require(!contractTerminated, "Contract is terminated");
        require(isContractSigned, "Contract is not signed");

        uint numberOfTimeSteps; // how many recurennt Payment have already passed
        /* Remark: - timestamp is in [s]. not optimal, since time of blocks can varry. 
                   - However, for months should be fine.        */
        numberOfTimeSteps = (block.timestamp-createdTimestamp); // number of [s] passed
        numberOfTimeSteps = numberOfTimeSteps / 60;             // convert here to minute
        minimumBalanceRequired =  singlePayment+numberOfTimeSteps*recurringPayment; // give lower boundry of the payment, which should have been done
        if (minimumBalanceRequired>leasingTotalCost){   // ensure, that minimumBalanceRequired does not surpasses leasingTotalCost
            minimumBalanceRequired = leasingTotalCost;
        }
        
    }
    
    
    // if leasing Cost is paid, transfer ownership and withdraw money
    function endContract() external {

        require(!contractTerminated, "Contract is already terminated");
        
        if (isContractSigned){
            // if minimumBalanceRequired surpasses accumulatedPayment, it is possible to end contract
            showMinimumBalanceRequired();
        }
        
        // Note: Everyone can currently end contract function 
        if (!isContractSigned) { 
            // when nobody signs the contract, the contract can be terminated
            comment = "Contract was not signed and terminated";
            contractTerminated = true;
        } else if (leasingTotalCost==accumulatedPayment){ 
            // Contract is signed and leasing cost is paid: transfer owner and withdraw payment
            oldOwner = currentOwner;
            currentOwner = newOwner;
            contractTerminated = true;
            payable(recipient).transfer(accumulatedPayment); // payment of the accumulatedPayment to seller
            comment = "Contract succesfully executed";
        } else if (minimumBalanceRequired>accumulatedPayment){ 
            /*  - current Payment is not sufficent (lower the minimumBalanceRequired) 
                - cancel contract, no owner transfer, withdraw payment to lessor    */
            contractTerminated = true;
            payable(recipient).transfer(accumulatedPayment);
            comment = "Contract terminted: Leasing condition were not fullfiled.";            
        } else {
            comment = "Condition to end contract are not met.";
        }   
    }
}
