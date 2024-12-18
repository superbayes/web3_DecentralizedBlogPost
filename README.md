# web3_DecentralizedBlogPost

## 背景
### 搭建一个去中心化的内容网站,有何好处?
* 数据所有权：用户完全拥有自己的内容，避免了平台对内容的控制和审查。

* 隐私保护：用户信息和活动在区块链上加密，防止数据泄露和滥用。

* 去中心化：没有单一控制者，降低了因平台政策变化而导致内容丢失的风险。

* 透明性：所有交易和内容发布记录在区块链上，确保信息的可追溯性和透明度。

* 收入模型：博客作者可以直接从读者获得收入，例如通过加密货币打赏，而不是依赖广告收入。

* 反审查：内容无法被随意删除或屏蔽，提高了言论自由。

* 低成本：区块链技术可能降低了运营和维护成本。

* 全球可访问性：区块链的去中心化特性使得平台在全球范围内可用，不受地域限制。

## 架构
![1](https://github.com/superbayes/web3_DecentralizedBlogPost/blob/main/others/chrome_YEV9btYRBv.jpg)

## 技术
* 将所有的博客内容(文字,图片,视频)保存到IPFS上
* 将所有的博客元数据保存到区块链中
* 在contract/下,有两个合约,`userinfo.sol`,将所有用户的数据永久性的保存到链上; `bloginfo.sol`,将所有用户文章的原数据永久保存到链上,一旦上链,永远不会被篡改.
* 可以结合对称加密AES和非对称加密ecdsa,确保用户信息不会被泄露.
![1](https://github.com/superbayes/web3_DecentralizedBlogPost/blob/main/others/%E5%8E%BB%E4%B8%AD%E5%BF%83%E5%8D%9A%E5%AE%A2%E6%9E%B6%E6%9E%84.png)
