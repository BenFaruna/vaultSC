// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Vault {
    address public owner;

    mapping(address => uint256) userTrustFund;
    mapping(address => uint256) timeToClaimFund;

    event FundWithdrawal(address indexed _to, uint256 _value);
    event SavingsTopUp(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    error FUND_CLAIM_TIME_NOT_REACHED();
    error NO_FUND_TO_CLAIM();

    constructor() {
        owner = msg.sender;
    }

    function donateTrustFund(address _to) external payable {
        uint256 _value = msg.value;

        userTrustFund[_to] = userTrustFund[_to] + _value;
        emit SavingsTopUp(msg.sender, _to, _value);
    }

    function donateTrustFund(address _to, uint256 _unlockTime)
        external
        payable
    {
        require(msg.value > 0, "cannot topup with zero");
        uint256 _value = msg.value;

        userTrustFund[_to] = userTrustFund[_to] + _value;
        timeToClaimFund[_to] = block.timestamp + _unlockTime;
        emit SavingsTopUp(msg.sender, _to, _value);
    }

    function withdrawTrustFund() external {
        _userCanWithdraw();
        uint256 _value = userTrustFund[msg.sender];
        userTrustFund[msg.sender] = 0;
        timeToClaimFund[msg.sender] = 0;
        payable(msg.sender).transfer(_value);

        emit FundWithdrawal(msg.sender, _value);
    }

    function getUserSavings(address _user) external view returns (uint256) {
        return userTrustFund[_user];
    }

    function _userCanWithdraw() private view {
        if (userTrustFund[msg.sender] == 0) {
            revert NO_FUND_TO_CLAIM();
        }

        if (timeToClaimFund[msg.sender] > block.timestamp) {
            revert FUND_CLAIM_TIME_NOT_REACHED();
        }
    }
}
