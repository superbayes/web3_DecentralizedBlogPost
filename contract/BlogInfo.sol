// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/security/Pausable.sol";

contract Blog is Pausable, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    struct Comment {
        uint256 userId; // 用户ID
        string content; // 评论内容 IPFS CID
    }

    struct BlogPost {
        uint256 userId; // 用户ID
        uint256 blogPostId;
        uint256 timestamp; // 发布时间戳
        uint256 likeCount; // 点赞数量
        string ipfsCid_text; // 博客内容的IPFS CID
        string[] comments; // 评论CID列表
        string[] ipfsCid_image; // 博客图像的IPFS CID
        string[] ipfsCid_video; // 博客视频的IPFS CID
    }

    BlogPost[] private blogPostList;
    uint256 public blogPostCount;
    mapping(uint256 => uint256[]) private userIdToblogPosts; //输入id查找所有的博客

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        createBlogPost(0,"0");
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }
	
    /**
     * @dev 创建新的BlogPost
     */
    function createBlogPost(uint256 userId, string memory ipfsCidText)
        public
        onlyRole(ADMIN_ROLE)
    {
        blogPostCount++;
        BlogPost memory newPost = BlogPost({
            userId: userId,
            blogPostId: blogPostCount,
            timestamp: block.timestamp,
            likeCount: 0,
            ipfsCid_text: ipfsCidText,
            comments: new string[](0),
            ipfsCid_image: new string[](0),
            ipfsCid_video: new string[](0)
        });
        blogPostList.push(newPost);
        userIdToblogPosts[userId].push(blogPostCount);
    }

    /**
     * @dev 更新BlogPost的likeCount
     */
    function updateLikeCount(uint256 userId, uint256 blogPostId)
        public
        onlyRole(ADMIN_ROLE)
    {
        require(
            blogPostId > 0 && blogPostId <= blogPostCount,
            "Invalid blogPostId"
        );
        require(blogPostList[blogPostId - 1].userId == userId, "Access denied");
        blogPostList[blogPostId - 1].likeCount++;
    }

    /**
     * @dev 更新BlogPost的ipfsCid_text
     */
    function updateBlogPostText(
        uint256 userId,
        uint256 blogPostId,
        string memory newIpfsCidText
    ) public onlyRole(ADMIN_ROLE) {
        require(
            blogPostId > 0 && blogPostId <= blogPostCount,
            "Invalid blogPostId"
        );
        require(blogPostList[blogPostId - 1].userId == userId, "Access denied");
        blogPostList[blogPostId - 1].ipfsCid_text = newIpfsCidText;
    }

    /**
     * @dev 添加新的评论
     */
    function addComment(uint256 blogPostId, string memory content)
        public
        onlyRole(ADMIN_ROLE)
    {
        require(
            blogPostId > 0 && blogPostId <= blogPostCount,
            "Invalid blogPostId"
        );
        blogPostList[blogPostId - 1].comments.push(content);
    }

    /**
     * @dev 添加新的ipfsCid_image
     */
    function addImageCid(uint256 blogPostId, string memory imageIpfsCid)
        public
        onlyRole(ADMIN_ROLE)
    {
        require(
            blogPostId > 0 && blogPostId <= blogPostCount,
            "Invalid blogPostId"
        );
        blogPostList[blogPostId - 1].ipfsCid_image.push(imageIpfsCid);
    }

    /**
     * @dev 添加新的ipfsCid_video
     */
    function addVideoCid(uint256 blogPostId, string memory videoIpfsCid)
        public
        onlyRole(ADMIN_ROLE)
    {
        require(
            blogPostId > 0 && blogPostId <= blogPostCount,
            "Invalid blogPostId"
        );
        blogPostList[blogPostId - 1].ipfsCid_video.push(videoIpfsCid);
    }

    /**
     * @dev 查询BlogPost
     */
    function getBlogPost(uint256 blogPostId)
        public
        whenNotPaused
        view
        returns (BlogPost memory)
    {
        require(
            blogPostId > 0 && blogPostId <= blogPostCount,
            "Invalid blogPostId"
        );
        return blogPostList[blogPostId - 1];
    }

    /**
     * @dev 查询用户的BlogPost列表
     */
    function getUserBlogPosts(uint256 userId)
        public
        whenNotPaused
        view
        returns (BlogPost[] memory)
    {
        uint256[] memory indexs = userIdToblogPosts[userId];
        BlogPost[] memory bp_List = new BlogPost[](indexs.length);
        for (uint256 i = 0; i < indexs.length; i++) {
            uint256 idx = indexs[i] - 1;
            bp_List[i] = blogPostList[idx];
        }
        return bp_List;
    }

    /**
     * @dev 查询BlogPost的总数量
     */
    function getBlogPostCount() public whenNotPaused view returns (uint256) {
        return blogPostCount;
    }
}

