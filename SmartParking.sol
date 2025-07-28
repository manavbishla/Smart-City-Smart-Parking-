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

    mapping(uint => parkinggarage) public garages;
    mapping(address => uint) public carlot;
    mapping(address => uint) public carspot;

    event newparkinglot(uint indexed lotid, address indexed owner, string name, uint totalspaces);
    event carparked(address indexed car, uint indexed lotid, uint spotid, uint time);
    event carleft(address indexed car, uint indexed lotid, uint spotid, uint fee, uint timespent);

    constructor(address tokenaddress) {
        paymenttoken = parkingcoin(tokenaddress);
    }

    function registerlot(string memory lotname, uint numspaces, uint hourlyfee) external {
        require(numspaces > 0, "Parking lot must have at least one space.");
        lotcounter++;

        parkinggarage storage newgarage = garages[lotcounter];
        newgarage.owner = msg.sender;
        newgarage.garagename = lotname;
        newgarage.totalspaces = numspaces;
        newgarage.freespaces = numspaces;
        newgarage.rate = hourlyfee;

        emit newparkinglot(lotcounter, msg.sender, lotname, numspaces);
    }

    function parkcar(uint garageid, uint spaceid) external {
        parkinggarage storage currentgarage = garages[garageid];

        require(currentgarage.owner != address(0), "That parking garage doesn't exist.");
        require(spaceid > 0 && spaceid <= currentgarage.totalspaces, "Invalid space number.");
        require(!currentgarage.parkingspaces[spaceid].istaken, "This space is already taken.");
        require(carlot[msg.sender] == 0, "This car is already parked somewhere else.");

        currentgarage.parkingspaces[spaceid].istaken = true;
        currentgarage.parkingspaces[spaceid].vehicle = msg.sender;
        currentgarage.parkingspaces[spaceid].timeparked = block.timestamp;
        currentgarage.freespaces--;
        carlot[msg.sender] = garageid;
        carspot[msg.sender] = spaceid;

        emit carparked(msg.sender, garageid, spaceid, block.timestamp);
    }

    function leaveparking() external {
        require(carlot[msg.sender] != 0, "Your car isn't parked here.");

        uint garageid = carlot[msg.sender];
        uint spaceid = carspot[msg.sender];
        parkinggarage storage currentgarage = garages[garageid];
        parkingspace storage currentspace = currentgarage.parkingspaces[spaceid];

        uint timespent = block.timestamp - currentspace.timeparked;
        uint fee = (timespent * currentgarage.rate) / 3600;

        require(paymenttoken.balanceOf(msg.sender) >= fee, "You don't have enough tokens to pay.");
        require(paymenttoken.allowance(msg.sender, address(this)) >= fee, "You need to approve the payment first.");
        
        bool success = paymenttoken.transferFrom(msg.sender, currentgarage.owner, fee);
        require(success, "Payment failed!");

        currentspace.istaken = false;
        currentspace.vehicle = address(0);
        currentspace.timeparked = 0;
        currentgarage.freespaces++;
        carlot[msg.sender] = 0;
        carspot[msg.sender] = 0;

        emit carleft(msg.sender, garageid, spaceid, fee, timespent);
    }
}