//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract GoFundMe {
    struct Campaign {
        address owner;
        string title;
        uint256 goal;
        uint256 deadline;
        uint256 amountRaised;
        bool goalReached;
        uint256 currentMilestone;
    }

    struct Milestone {
        string description;
        uint256 fundPercent;
        uint256 votesFor;
        uint256 votesAgainst;
        bool approved;
        bool withdrawn;
        uint256 votingDeadline;
    }

    address owner;

    constructor() {
        owner = msg.sender;
    }

    uint256 public campaignCount;
    uint256 private constant VOTING_PERIOD = 7 days;

    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => Milestone[]) public milestones;
    mapping(uint256 => mapping(address => uint256)) public contributions;
    mapping(uint256 => mapping(uint256 => mapping(address => bool))) public hasVoted;

    function createCampaign(string memory _title, uint256 _goal, uint256 _deadline, uint256 _amountRaised, 
        string[] memory milestoneDescriptions, uint256[] memory milestoneFundPercents
    ) public returns (Campaign memory) {
        require(milestoneDescriptions == milestoneFundPercents, "Milestone entries wrong");
        require(milestoneDescriptions > 0, "Campaign must contain at least 1 milestone");

        campaignCount++;
        address campaignOwner = msg.sender;

        uint256 campaignId = campaignCount;

        campaigns[campaignId] = Campaign({
            owner: campaignOwner,
            title: _title,
            goal: _goal,
            deadline: block.timestamp + (_deadline * 1 days),
            amountRaised: _amountRaised,
            goalReached: false,
            currentMilestone: 0
        });

        for(uint256 i = 0;i < milestoneDescriptions.length;++i) {
            milestones[campaignId].push(Milestone({
                description: milestoneDescriptions[i],
                fundPercent: milestoneFundPercents[i],
                votesFor: 0,
                votesAgainst: 0,
                approved: false,
                withdrawn: false,
                votingDeadline
            }))
        }

        return campaigns[campaignId];
    }

    function submitMilestone(uint256 campaignId) external {
        Campaign campaign = campaigns[campaignId];
        Milestone currentMilestone = milestones[campaignId][campaign.currentMilestone];

        require(campaign.owner == msg.sender, "Only campaign owner can perform this action.");
        require(block.timestamp > currentMilestone.votingDeadline, "Deadline reached");
        require(currentMilestone.approved == false, "Milestone already approved");

        currentMilestone.votingDeadline = block.timestamp + VOTING_PERIOD;
    }

    function fund(uint256 campaignId) external payable {
        Campaign campaign = campaigns[campaignId];
        require(block.timestamp > campaign.deadline, "Campaign no longer receiving contribution");
    }
}