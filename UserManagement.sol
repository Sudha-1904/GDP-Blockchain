// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserManagement {
    struct User {
        string username;
        string bio;
        address wallet;
        bool isActive;
        uint256 role; // 0 = user, 1 = moderator, 2 = admin
    }

    mapping(address => User) public users;
    mapping(address => address[]) public followers;
    mapping(address => address[]) public following;

    event UserRegistered(address indexed user, string username);
    event UserUpdated(address indexed user, string bio);
    event UserDeactivated(address indexed user);
    event RoleUpdated(address indexed user, uint256 role);

    modifier onlyActiveUser() {
        require(users[msg.sender].isActive, "User is not active");
        _;
    }

    function register(string memory _username, string memory _bio) public {
        require(bytes(users[msg.sender].username).length == 0, "User already registered");

        users[msg.sender] = User({
            username: _username,
            bio: _bio,
            wallet: msg.sender,
            isActive: true,
            role: 0 // default role is user
        });

        emit UserRegistered(msg.sender, _username);
    }

    function updateProfile(string memory _bio) public onlyActiveUser {
        users[msg.sender].bio = _bio;
        emit UserUpdated(msg.sender, _bio);
    }

    function deactivateAccount() public onlyActiveUser {
        users[msg.sender].isActive = false;
        emit UserDeactivated(msg.sender);
    }

    function updateRole(address _user, uint256 _role) public onlyActiveUser {
        require(users[_user].isActive, "User not found");
        users[_user].role = _role;
        emit RoleUpdated(_user, _role);
    }

    function getUser(address _user) public view returns (User memory) {
        return users[_user];
    }
}
