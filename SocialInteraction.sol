// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./UserManagement.sol";

contract SocialInteraction is UserManagement {
    struct Post {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
        bool exists;
    }

    struct Comment {
        uint256 postId;
        address commenter;
        string content;
        uint256 timestamp;
    }

    mapping(uint256 => Post) public posts;
    mapping(uint256 => Comment[]) public comments;
    mapping(address => mapping(uint256 => bool)) public likes; // user -> postId -> liked
    uint256 public postCount;

    event PostCreated(uint256 indexed postId, address indexed author, string content);
    event CommentAdded(uint256 indexed postId, address indexed commenter, string content);
    event PostLiked(uint256 indexed postId, address indexed user);

    modifier onlyPostExists(uint256 _postId) {
        require(posts[_postId].exists, "Post does not exist");
        _;
    }

    function createPost(string memory _content) public onlyActiveUser {
        postCount++;
        posts[postCount] = Post({
            id: postCount,
            author: msg.sender,
            content: _content,
            timestamp: block.timestamp,
            likes: 0,
            exists: true
        });

        emit PostCreated(postCount, msg.sender, _content);
    }

    function addComment(uint256 _postId, string memory _content) public onlyActiveUser onlyPostExists(_postId) {
        comments[_postId].push(Comment({
            postId: _postId,
            commenter: msg.sender,
            content: _content,
            timestamp: block.timestamp
        }));

        emit CommentAdded(_postId, msg.sender, _content);
    }

    function likePost(uint256 _postId) public onlyActiveUser onlyPostExists(_postId) {
        require(!likes[msg.sender][_postId], "Already liked this post");

        likes[msg.sender][_postId] = true;
        posts[_postId].likes++;

        emit PostLiked(_postId, msg.sender);
    }

    function getPost(uint256 _postId) public view onlyPostExists(_postId) returns (Post memory) {
        return posts[_postId];
    }

    function getComments(uint256 _postId) public view onlyPostExists(_postId) returns (Comment[] memory) {
        return comments[_postId];
    }
}
