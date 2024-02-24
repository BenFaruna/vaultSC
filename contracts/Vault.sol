// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/// @title A simple trust fund contract
/// @notice This contract allows users to deposit funds on behalf of a beneficiary and the beneficiary can withdraw them after a certain period of time or immediately if no time is set
/// @dev All function calls are currently implemented without side effects
contract Vault {
    address public owner;

    // userTrustFund is a mapping of user address to the amount of funds they have deposited
    mapping(address => uint256) userTrustFund;

    // timeToClaimFund is a mapping of user address to the time they can claim their funds
    mapping(address => uint256) timeToClaimFund;

    /// @notice This event is emitted when a user withdraws funds from the contract
    /// @param _to The address of the beneficiary
    /// @param _value The amount of funds donated
    event FundWithdrawal(
        address indexed _to,
        uint256 _value
    );

    /// @notice This event is emitted when a user donates funds to a beneficiary
    /// @param _from The address donating the funds
    /// @param _to The address of the beneficiary
    /// @param _value The amount of funds withdrawn
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

    /// @notice This function allows a user to donate funds to a beneficiary
    /// @param _to The address of the beneficiary
    function donateTrustFund(address _to) external payable {
        uint256 _value = msg.value;

        userTrustFund[_to] = userTrustFund[_to] + _value;
        emit SavingsTopUp(msg.sender, _to, _value);
    }

    /// @notice This function allows a user to donate funds to a beneficiary and set a time for the beneficiary to claim the funds
    /// @param _to The address of the beneficiary
    /// @param _unlockTime The amount of time in seconds the beneficiary has to claim the funds
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

    /// @notice This function allows a beneficiary to withdraw funds from the contract
    /// @dev The beneficiary can only withdraw funds if the time to claim the funds has been reached
    function withdrawTrustFund() external {
        _userCanWithdraw();
        uint256 _value = userTrustFund[msg.sender];
        userTrustFund[msg.sender] = 0;
        timeToClaimFund[msg.sender] = 0;
        payable(msg.sender).transfer(_value);

        emit FundWithdrawal(msg.sender, _value);
    }

    /// @notice This function allows users to check the amount donated to a specific beneficiary
    /// @param _user The address of the beneficiary
    function getUserSavings(address _user) external view returns (uint256) {
        return userTrustFund[_user];
    }

    /// @notice This function allows the contract to check if the user can withdraw funds
    /// @dev The user can only withdraw funds if they have funds to withdraw and the time to claim the funds has been reached
    function _userCanWithdraw() private view {
        if (userTrustFund[msg.sender] == 0) {
            revert NO_FUND_TO_CLAIM();
        }

        if (timeToClaimFund[msg.sender] > block.timestamp) {
            revert FUND_CLAIM_TIME_NOT_REACHED();
        }
    }

    receive() external payable {
        revert("This contract does not accept direct payments");
    }
}
