// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "Players.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Quest is Ownable, ReentrancyGuard {
    Players public immutable nftCollection;

    uint256 constant SECONDS_IN_HOUR = 3600;

    struct Staker {
        /**
         * @dev The array of Token Ids staked by the user.
         */
        uint256[] stakedTokenIds;
        /**
         * @dev The time of the last update of the rewards.
         */
        uint256 timeOfLastUpdate;
        /**
         * @dev The amount of ERC20 Reward Tokens that have not been claimed by the user.
         */
        uint256 unclaimedRewards;
    }

    struct PlayerQuesting {
        uint256 id;
        bool isQuesting;
        uint256 time;
        uint256 questType;
        address owner;
    }

    mapping(address => Staker) public stakers;
    mapping(uint256 => PlayerQuesting) public questingPlayers;

    mapping(uint256 => address) public stakerAddress;
    address[] public stakersArray;
    mapping(address => uint256) public stakerToArrayIndex;
    mapping(uint256 => uint256) public tokenIdToArrayIndex;

    uint256 private rewardsPerHour = 100000;

    constructor(Players _nftCollection) {
        nftCollection = _nftCollection;
    }

    function quest(uint256 _tokenId, uint8 _questType) external  {
        require(nftCollection.ownerOf(_tokenId) == msg.sender, "Can't stake tokens you don't own!");
        checkLevel(_tokenId, _questType);
        PlayerQuesting storage playerQuest = questingPlayers[_tokenId];
        playerQuest.id = _tokenId;
        playerQuest.isQuesting = true;
        playerQuest.time = block.timestamp;
        playerQuest.owner = msg.sender;
        playerQuest.questType = _questType;
        nftCollection.transferFrom(msg.sender, address(this), _tokenId);
    }

    function checkLevel(uint256 _tokenId, uint8 _questType) internal view {
        if (_questType == 12) {
            uint256 fishingLevel = nftCollection.getFishingLevel(_tokenId);
            require (fishingLevel > 20);
        }
        if (_questType == 13) {
            uint256 fishingLevel = nftCollection.getFishingLevel(_tokenId);
            require (fishingLevel > 40);
        }
    }

    function withdraw(uint256[] calldata _tokenIds) external nonReentrant {
        uint256 lenToWithdraw = _tokenIds.length;
        for (uint256 i; i < lenToWithdraw; ++i) {
            PlayerQuesting storage playerQuest = questingPlayers[_tokenIds[i]];
            require(questingPlayers[_tokenIds[i]].owner == msg.sender);

            nftCollection.rewards(_tokenIds[i],playerQuest.time, playerQuest.owner, playerQuest.questType);

            playerQuest.isQuesting = false;

            nftCollection.transferFrom(address(this), msg.sender, _tokenIds[i]);
        }
    }

    // function claimRewards() external {
    //     Staker storage staker = stakers[msg.sender];

    //     uint256 rewards = calculateRewards(msg.sender) + staker.unclaimedRewards;
    //     require(rewards > 0, "You have no rewards to claim");

    //     staker.timeOfLastUpdate = block.timestamp;
    //     staker.unclaimedRewards = 0;

    //    // rewardsToken.safeTransfer(msg.sender, rewards);
    // }

    function setRewardsPerHour(uint256 _newValue) public onlyOwner {
        address[] memory _stakers = stakersArray;

        uint256 len = _stakers.length;
        for (uint256 i; i < len; ++i) {
            updateRewards(_stakers[i]);
        }

        rewardsPerHour = _newValue;
    }

    function userStakeInfo(address _user)
        public
        view
        returns (uint256[] memory _stakedTokenIds, uint256 _availableRewards)
    {
        return (stakers[_user].stakedTokenIds, availableRewards(_user));
    }


    function availableRewards(address _user) internal view returns (uint256 _rewards) {
        Staker memory staker = stakers[_user];

        if (staker.stakedTokenIds.length == 0) {
            return staker.unclaimedRewards;
        }

        _rewards = staker.unclaimedRewards + calculateRewards(_user);
    }

    function calculateRewards(address _staker) internal view returns (uint256 _rewards) {
        Staker memory staker = stakers[_staker];
        return (
            ((((block.timestamp - staker.timeOfLastUpdate) * staker.stakedTokenIds.length)) * rewardsPerHour)
                / SECONDS_IN_HOUR
        );
    }

    function updateRewards(address _staker) internal {
        Staker storage staker = stakers[_staker];

        staker.unclaimedRewards += calculateRewards(_staker);
        staker.timeOfLastUpdate = block.timestamp;
    }


}