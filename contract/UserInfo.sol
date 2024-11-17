// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/security/Pausable.sol";

contract User is Pausable, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    struct UserInfo {
        bytes32 accountHash; // 账号哈希
        bytes32 passwordHash; // 密码哈希
        uint256 timestamp; // 时间戳
        uint256 userId; // 用户ID
        string username; // 用户名称
    }

    UserInfo[] private users;
    uint256 private userCount;
    mapping(bytes32 => uint256) private accountHashToUser; //根据id查找users索引

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        registerUser(0, 0, "null");
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @dev 注册新用户
     */
    function registerUser(
        bytes32 _accountHash,
        bytes32 _passwordHash,
        string memory _username
    ) public onlyRole(ADMIN_ROLE) returns (uint256) {
        userCount++; // 增加用户计数
        users.push(
            UserInfo({
                accountHash: _accountHash,
                passwordHash: _passwordHash,
                timestamp: block.timestamp,
                userId: userCount,
                username: _username
            })
        );

        accountHashToUser[_accountHash] = userCount;
        return userCount; // 返回新用户的用户ID
    }

    /**
     * @dev 修改UserInfo
     */
    function updateUser(
        bytes32 _accountHash,
        bytes32 _newPasswordHash,
        string memory _newUsername
    ) private onlyRole(ADMIN_ROLE) {
        uint256 index = accountHashToUser[_accountHash];
        require(index > 0 && index <= userCount, "User ID is invalid");

        UserInfo storage user = users[index]; // 获取用户
        user.passwordHash = _newPasswordHash;
        user.username = _newUsername;
    }

    /**
     * @dev 修改密码
     */
    function updatePassword(
        bytes32 _accountHash,
        bytes32 _oldPasswordHash,
        bytes32 _newPasswordHash
    ) public onlyRole(ADMIN_ROLE) returns (bool) {
        uint256 index = accountHashToUser[_accountHash];
        require(index > 0 && index <= userCount, "User ID is invalid");
        UserInfo storage user = users[index];
        if (user.passwordHash == _oldPasswordHash) {
            user.passwordHash = _newPasswordHash;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev 修改用户名
     */
    function updateUsername(
        bytes32 _accountHash,
        bytes32 _passwordHash,
        string memory _newUsername
    ) public onlyRole(ADMIN_ROLE) returns (bool) {
        uint256 index = accountHashToUser[_accountHash];
        require(index > 0 && index <= userCount, "User ID is invalid");
        UserInfo storage user = users[index];
        if (user.passwordHash == _passwordHash) {
            user.username = _newUsername;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev   根据userId查询UserInfo
     */
    function getUserById(uint256 _userId)
        public
        view
        whenNotPaused
        returns (UserInfo memory)
    {
        require(_userId > 0 && _userId <= userCount, "User ID is invalid");
        return users[_userId - 1]; // 返回用户信息
    }

    /**
     * @dev 根据accountHash查询UserInfo
     */
    function getUserByAccountHash(bytes32 _accountHash)
        public
        view
        whenNotPaused
        returns (UserInfo memory)
    {
        // for (uint256 i = 0; i < users.length; i++) {
        //     if (users[i].accountHash == _accountHash) {
        //         return users[i]; // 找到用户并返回
        //     }
        // }
        uint256 index = accountHashToUser[_accountHash];
        require(index > 0 && index <= userCount, "User  is invalid");
        UserInfo storage user = users[index];
        return user;
    }

    /**
     * @dev 根据username查询UserInfo
     */
    function getUserByUsername(string memory _username)
        public
        view
        whenNotPaused
        returns (UserInfo memory)
    {
        for (uint256 i = 0; i < users.length; i++) {
            if (
                keccak256(abi.encodePacked(users[i].username)) ==
                keccak256(abi.encodePacked(_username))
            ) {
                return users[i]; // 找到用户并返回
            }
        }
        revert("User not found");
    }

    /**
     * @dev 查询用户总数量
     */
    function getTotalUsers() public view whenNotPaused returns (uint256) {
        return userCount; // 返回用户总数
    }
}
