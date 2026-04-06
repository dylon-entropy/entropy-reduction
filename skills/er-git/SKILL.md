---
name: er-git
description: Git 分支管理工具。两个时机：写代码前检测分支（时机A），测试通过后提交（时机B）。由核心阶段调用。
---

# Git 工作流工具

> 统一管理工作流中的所有 Git 操作。各阶段不直接执行 git 命令，通过本工具调用。

## 时机A：写代码前检测分支

**调用方**：er-dev 前置步骤
**目的**：确保在正确分支上，此时无代码改动，切换无成本

### 执行流程
1. 从对应需求目录的 `全局约束.md`「Git 分支」章节读取目标分支名
2. `git branch --show-current` 获取当前分支
3. 当前 == 目标 → 输出 `✅ 当前已在分支 {分支名}`
4. 当前 != 目标 → 检查工作区：
   - `git status --porcelain` 输出为空 → `git checkout {目标分支}` → 输出 `🔀 已切换到 {目标分支}`
   - 输出非空 → **暂停**：
     ```
     ⚠️ 需要切换到 {目标分支}，但有未提交改动：
     {files}
     请处理后说"继续"。
     ```

## 时机B：测试通过后提交

**调用方**：er-test 全部通过后
**目的**：校验分支 + commit + push，原子执行

### 执行流程

**作为一个完整的 shell 脚本一次性执行**（禁止拆分为多条独立命令）：

```bash
#!/bin/bash
set -e

EXPECTED_BRANCH="{从全局约束读取}"
COMMIT_MSG="feat({功能序号-功能名}): {一句话描述}"

# 分支校验
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$EXPECTED_BRANCH" ]; then
    echo "❌ 分支不匹配，中止提交"
    echo "   当前: $CURRENT_BRANCH"
    echo "   预期: $EXPECTED_BRANCH"
    exit 1
fi

# 提交并推送
git add -A
if git diff --cached --quiet; then
    echo "没有改动需要提交"
    exit 0
fi
git commit -m "$COMMIT_MSG"
git push origin "$EXPECTED_BRANCH"
```

**关键约束**：
- 禁止拆分执行：分支校验和 commit 是原子操作
- commit message：功能序号和名称从 spec 文件名提取

**异常处理**：
- 分支不匹配 → 输出警告，等用户确认
- push 失败 → 输出完整错误，提示手动处理

## 创建分支（er-spec 阶段1调用）

1. 从全局约束「Git 分支」章节读取分支名
2. `git branch --list {分支名}` 检查是否存在
   - 已存在 → 检查工作区干净后 `git checkout {分支名}`
   - 不存在 → 检查工作区干净后：
     ```bash
     git checkout master
     git pull origin master
     git checkout -b {分支名}
     ```
3. 输出 `✅ 已切换到分支 {分支名}`

## Pre-commit Hook（底线防御）

安装到 `.git/hooks/pre-commit`，基于 `workflow/progress.md` 拦截 er-dev 阶段的 commit：

```bash
#!/bin/bash
STATE_FILE=$(find doc -name "progress.md" -path "*/workflow/*" 2>/dev/null | head -1)
if [ -n "$STATE_FILE" ]; then
    STAGE=$(grep "当前阶段:" "$STATE_FILE" | awk '{print $2}')
    if [ "$STAGE" = "er-dev" ] || [ "$STAGE" = "er-spec" ]; then
        echo "❌ 当前阶段为 $STAGE，禁止 commit"
        echo "   测试通过后自动提交"
        exit 1
    fi
fi
```
