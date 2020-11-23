// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

// /// Returns address from bytes32
// function b2a(bytes32 b) pure returns (address) {
//     return address(uint160(uint256(b)));
// }

// /// Returns bytes32 from an address
// function a2b(address a) returns (bytes32) {
//     return bytes32(uint256(addr));
// }

contract Election {
    struct Voter {
        bool valid;
        address candidate;
    }

    struct Candidate {
        string name;
        bool exists;
        uint votes;
    }

    struct CandidateOverview {
        string name;
        address id;
    }

    CandidateOverview[] public candidates_arr;
    address public owner;

    mapping(address => Voter) private voters;
    mapping(address => Candidate) private candidates;

    uint public start_time;
    uint public end_time;

    constructor(
        uint _start_time,
        uint _end_time,
        address[] memory valid_voters,
        address[] memory candidates_addr,
        string[] memory candidates_name
    ) {
        for(uint i = 0; i < valid_voters.length; i++) {
            voters[valid_voters[i]].valid = true;
        }

        for(uint i = 0; i < candidates_addr.length; i++) {
            candidates[candidates_addr[i]].name = candidates_name[i];
            candidates[candidates_addr[i]].exists = true;
            candidates_arr.push(CandidateOverview({
                name: candidates_name[i],
                id: candidates_addr[i]
            }));
        }

        owner = msg.sender;
        start_time = _start_time;
        end_time = _end_time;
    }

    function hasVoted(address voter) public view returns (bool) {
        require(
            msg.sender == owner,
            "Only election owner can search for who has voted."
        );
        require(block.timestamp > end_time, "You can only see who hasn't voted after the election.");


        return voters[voter].candidate != address(0);
    }

    function getCandidates() public view returns (CandidateOverview[] memory) {
        return candidates_arr;
    }

    function castVote(address candidate) public {
        require(block.timestamp >= start_time &&
                block.timestamp <= end_time, "Cannot cast vote at this time.");
        require(voters[msg.sender].candidate == address(0), "You already voted.");
        require(voters[msg.sender].valid, "You are not a valid voter.");
        require(candidates[candidate].exists, "This candidate does not exist in this election.");

        candidates[candidate].votes += 1;
        voters[msg.sender].candidate = candidate;
    }

    function getVote() public view returns (address) {
        return voters[msg.sender].candidate;
    }

    function getCandidateVotes(address candidate) public view returns (uint) {
        require(block.timestamp > end_time, "Cannot get votes before end of election.");
        return candidates[candidate].votes;
    }

}

