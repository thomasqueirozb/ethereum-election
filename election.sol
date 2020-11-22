pragma solidity ^0.4.4;

contract Election {
    struct Candidate {
        address candidateId;
        string name;
    }

    Candidate[] public all_candidates_arr;
    address public owner;

    mapping(address => uint) private vote_count;
    mapping(address => bool) private all_candidates;
    mapping(address => address) private vote;
    mapping(address => bool) private valid_voter;

    uint public start_time;
    uint public end_time;

    constructor(
        uint _start_time,
        uint _end_time,
        address[] _valid_voter,
        Candidate[] _all_candidates
    ) public {
        for(uint i = 0; i < _all_candidates.length; i++) {
            vote_count[_all_candidates[i]] = 0;
        }

        for(uint i = 0; i < _valid_voter.length; i++) {
            valid_voter[_valid_voter[i]] = true;
        }

        for(uint i = 0; i < all_candidates.length; i++) {
            all_candidates[_all_candidates[i].candidateId] = true;
        }

        all_candidates_arr = _all_candidates;

        owner = msg.sender;
        start_time = _start_time;
        end_time = _end_time;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function hasntVoted(address[] voters) public view returns (address[]) {
        require(
            msg.sender == owner,
            "Only election owner can search for who hasn't voted."
        );
        address[] non_voters;

        for(uint i = 0; i < voters.length; i++) {
            if (vote[voters[i]] == 0) {
                non_voters.push(voters[i]);
            }
        }

        return non_voters;
    }

    function getCandidates() public view returns (Candidate[]) {
        return all_candidates_arr;
    }

    function castVote(address candidate) public {
        require(block.timestamp >= start_time &&
                block.timestamp <= end_time, "Cannot cast vote at this time.");
        require(hasVoted(msg.sender), "You already voted.");
        require(isValidVoter(msg.sender), "You are not a valid voter.");
        require(all_candidates[candidate], "This candidate does not exist in this election.");



        vote_count[candidate] += 1;
        vote[msg.sender] = candidate;
    }

    function getVote() public view returns (bool) {
        return vote[msg.sender];
    }

    function canVote(address voter) public returns (bool) {
        return (valid_voter[voter] && vote[voter] == 0);
    }


    function isValidVoter(address voter) public returns (bool) {
        return valid_voter[voter];
    }

    function hasVoted(address voter) public returns (bool) {
        return vote[voter] != 0;
    }

    function getCandidateVotes(address candidate) public view returns (uint) {
        require(block.timestamp > end_time, "Cannot get votes before end of election");
        return vote_count[candidate];
    }

}

