# Smart Contract - Leasing Contract Example

We give here an example of a Leasing Contract that can be implemented as Smart Contract on the Ethereum Blockchain. 

The code was done as part of the course Smart Contract and Decentralized Finance (HS2021) at the University of Basel
https://cryptolectures.teachable.com/p/smart-contracts-and-decentralized-finance


Overview: 

The code has following functions: 
- constructor   (gives the boundary condition of the contract)
- signContract  (the lessor agrees to the term and signs the contract)
- sendPayment   (the lessor sends a payment)
- showMinimumBalanceRequired    (if lessor has not fullfilled the minimum Balance requirment, the contract can be terminated)
- endContract   (the contract can be terminated, if requirment are not fullfiled or the complete payment has been done)

For further details, please look into the code. 
In addition, an ipfs link can be added to the contract, where the AGB can be downloaded. Because of the unique hash of the ipfs, the document can not be altered, without changing the hash.

Example of ipfs contract: [ipfs://QmQgrsdutdqL2e6FeoiX9hJLUbvHQXmuhyV9CbmcrbaqWD](ipfs://QmQgrsdutdqL2e6FeoiX9hJLUbvHQXmuhyV9CbmcrbaqWD)
