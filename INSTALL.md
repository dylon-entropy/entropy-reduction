# 安装指南

## 一键安装（推荐）

```bash
git clone https://github.com/dylon-entropy/entropy-reduction.git
cd entropy-reduction
bash install.sh
```

脚本会自动检测平台，将 skill 文件复制到 `~/.claude/skills/` 目录。

## 手动安装

### 第一步：复制 Skills

将 `skills/` 下的所有目录复制到你的 skills 目录：

```bash
cp -r skills/* ~/.claude/skills/
```

| 平台 | Skills 目录 |
|------|------------|
| Claude Code | `~/.claude/skills/` |
| OpenClaw / LobsterAI | `~/.claude/skills/` |
| Cursor | 通过 `.cursorrules` 引用（见下方） |

### 第二步：添加常驻规则（必须）

Skills 只包含各阶段的执行逻辑。要让工作流被**正确触发**，还需要将常驻规则追加到你的项目配置文件中。

**不添加常驻规则，工作流无法自动触发。**

| 平台 | 配置文件 | 规则源文件 |
|------|---------|-----------|
| Claude Code | 项目根目录 `CLAUDE.md` | `platforms/claude-rules.md` |
| OpenClaw / LobsterAI | 项目根目录 `AGENTS.md` | `platforms/agents-rules.md` |
| Cursor | 项目根目录 `.cursorrules` | `platforms/cursor-rules.md` |

操作示例（Claude Code）：

```bash
cat platforms/claude-rules.md >> /path/to/your/project/CLAUDE.md
```

### 第三步：验证

在 AI 对话中输入：

```
/er-init
```

AI 应该能识别并加载 er-init skill，输出初始化结果。如果没有反应，检查：
1. skill 文件是否在正确目录
2. 常驻规则是否已追加到配置文件
3. 配置文件是否被当前 AI 工具加载

## Gemini CLI

```bash
gemini extensions install https://github.com/dylon-entropy/entropy-reduction
```

安装后同样需要将常驻规则添加到 Gemini 的配置中。

## 更新

```bash
# Plugin 方式（Claude Code / Cursor）
/plugin update entropy-reduction

# Git clone 方式
cd entropy-reduction
git pull
bash install.sh

# Gemini CLI
gemini extensions update entropy-reduction
```

已有的 skill 文件会自动备份后覆盖。Skills 更新后立刻生效。如果常驻规则有变更，CHANGELOG 会注明。

## 卸载

删除 skills 目录下的相关文件：

```bash
rm -rf ~/.claude/skills/er-{spec,dev,test,review,handoff,init,metrics,git,sync,learning}
```

然后从项目配置文件中移除"熵减工作流"章节。

## Cursor 特殊说明

Cursor 不使用 `~/.claude/skills/` 目录。需要：

1. 将 skill 文件放在项目内或固定路径
2. 在 `.cursorrules` 中通过路径引用

```bash
# 将 skills 复制到项目内
cp -r skills/ /path/to/project/.entropy-reduction/

# 追加规则（规则中的 skill 路径需要改为项目内路径）
cat platforms/cursor-rules.md >> /path/to/project/.cursorrules
```

然后修改 `.cursorrules` 中 skill 路径为 `.entropy-reduction/` 前缀。

## 常见问题

**Q: 安装后 AI 不响应 `/er-init`？**
A: 确认常驻规则已添加到正确的配置文件。不同平台的配置文件不同。

**Q: 多个项目共用一套 skills 吗？**
A: Skills 安装在 `~/.claude/skills/`，全局生效，所有项目共用。常驻规则只需要在你使用的 AI 工具中配置一次（比如 Claude Code 的全局 CLAUDE.md 或 OpenClaw 的 AGENTS.md），不是每个代码项目都要重新配置。

**Q: 和已有的 skills 冲突怎么办？**
A: 熵减的 skill 都以 `er-` 开头，与其他 skill 不会冲突。安装脚本会自动备份已有的同名目录。

**Q: learning-log 文件会被覆盖吗？**
A: 更新时会备份。但建议定期将有价值的 learning-log 条目固化到 skill 中，而不是依赖 log 文件。
