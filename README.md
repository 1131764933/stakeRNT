# StakePool - 质押池合约

基于 Foundry 的质押挖矿合约项目，包含安全修复。

## 📖 项目概述

这是一个 RNT 质押挖矿合约，支持：
- 质押 RNT 代币
- 解除质押
- 领取 esRNT 奖励
- 锁仓机制

## 📁 项目结构

```
stakeRNT/
├── src/
│   ├── StakePool.sol         # 原始版本 (有安全漏洞)
│   ├── StakePoolFixed.sol   # 生产安全版本 ⭐
│   ├── RNT.sol              # RNT 代币
│   ├── esRNT.sol           # esRNT 托管代币
│   └── Counter.sol
└── lib/                      # 依赖库
```

## 🔐 安全修复记录 (7步法 - Modify/Refactor)

### 原始版本的安全问题

```solidity
// ❌ 原始版本有 5 个安全问题：

// 问题1: updateReward 初始检查有漏洞
function updateReward(address account) internal {
    if (stakeInfo.lastUpdateTime > 0) {  // 第一次 = 0，不计算！
        // 不会计算奖励
    }
    stakeInfo.lastUpdateTime = block.timestamp;
}

// 问题2: 锁定期计算错误
uint256 unlocked = (lock.amount * (block.timestamp - lock.lockTime)) / 30 days;
// 应该用 min(时间, 30天)，不是直接除

// 问题3: 无重入保护

// 问题4: rewardRate 可改无限制

// 问题5: 无 Emergency
```

### 问题列表

| # | 问题 | 严重程度 | 描述 |
|---|------|---------|------|
| 1 | updateReward 初始逻辑 | 🔴 高 | 第一次质押不计算奖励 |
| 2 | 锁定期计算错误 | 🟡 中 | 超过 30 天后计算错误 |
| 3 | 无重入保护 | 🔴 高 | 可能被重入攻击 |
| 4 | rewardRate 无限制 | 🟡 中 | 可以设为无限大 |
| 5 | 无 Emergency | 🟢 低 | 缺少紧急功能 |

### 修复方案

```solidity
// ✅ 修复后的版本：

// 1. 修复 updateReward 逻辑
function _updateReward(address account) internal {
    StakeInfo storage info = stakes[account];
    
    // 修复：使用 lastUpdateTime == 0 判断第一次
    if (info.lastUpdateTime > 0) {
        uint256 timeStaked = block.timestamp - info.lastUpdateTime;
        uint256 reward = (timeStaked * info.staked * rewardRate) / 1 days;
        info.unclaimed += reward;
    }
    
    info.lastUpdateTime = block.timestamp;
}

// 2. 添加重入保护
function stake(uint256 amount) external nonReentrant { ... }

// 3. 添加 rewardRate 上限
uint256 public constant MAX_REWARD_RATE = 100 ether;

// 4. 修复锁定期计算
uint256 unlockedPeriods = timePassed / LOCK_PERIOD;
if (unlockedPeriods > 1) unlockedPeriods = 1;
uint256 unlockedAmount = (lockInfo.amount * unlockedPeriods * LOCK_PERIOD) / LOCK_PERIOD;

// 5. 添加 Emergency
function emergencyWithdraw(uint256 amount) external onlyOwner { ... }
```

### 修复对比

| 修复项 | 原始版本 | 修复版本 |
|--------|----------|----------|
| 初始逻辑 | ❌ 第一次不计 | ✅ 正确处理 |
| 锁定期计算 | ❌ 溢出风险 | ✅ 正确 min |
| 重入保护 | ❌ 无 | ✅ ReentrancyGuard |
| rewardRate | ❌ 无限制 | ✅ 有上限 |
| Emergency | ❌ 无 | ✅ 有 |

## 🛠 技术栈

- **语言**: Solidity 0.8.25
- **框架**: Foundry
- **库**: OpenZeppelin Contracts

## 🚀 快速开始

### 安装依赖

```bash
forge install
```

### 编译

```bash
forge build
```

### 测试

```bash
forge test
```

## 📜 核心功能

### 1. 质押

```solidity
function stake(uint256 amount) external nonReentrant;
```

### 2. 解除质押

```solidity
function unstake(uint256 amount) external nonReentrant;
```

### 3. 领取奖励

```solidity
function claim() external nonReentrant;
```

### 4. 锁仓

```solidity
function lock(uint256 amount) external nonReentrant;
```

### 5. 解锁

```solidity
function unlock(uint256 lockId) external nonReentrant;
```

## 🔒 安全特性

- ✅ 重入保护 (ReentrancyGuard)
- ✅ 正确的奖励计算逻辑
- ✅ 锁定期正确计算
- ✅ 奖励率上限
- ✅ 紧急提取功能
- ✅ Checks-Effects-Interactions

## 📝 学习记录

本项目使用 **7步工程学习法**：

1. **Run** - 运行项目，编译通过
2. **Map** - 理解项目结构
3. **Trace** - 追踪数据流
4. **Modify** - 发现 5 个安全问题
5. **Rebuild** - 重写核心逻辑
6. **Refactor** - 生产级优化 + 安全修复
7. **Teach** - 输出文档

## 📄 License

MIT
