// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/parkingcoin.sol";

contract smartparking {

    parkingcoin public paymenttoken;
    uint public lotcounter;

    struct parkingspace {
        address vehicle;
        uint timeparked;
        bool istaken;
    }

    struct parkinggarage {
        address owner;
        string garagename;
        uint rate;
        uint totalspaces;
        uint freespaces;
        mapping(uint => parkingspace) parkingspaces;
    }

   

    
