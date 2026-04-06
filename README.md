# 熵减 (Entropy Reduction)

**A spec-driven AI programming workflow that works with any AI coding tool.**

熵减定义了一种**人与 AI 协作编程的方式**：分工明确，人只做 AI 做不了的事（业务判断、设计审核），AI 负责所有可自动化的环节（生成文档、写代码、跑测试、维护一致性）。

它不是一个 IDE 或插件——它是一组 skill 文件，可以安装到 Claude Code、OpenClaw、Cursor 等任何支持 skill/prompt 机制的 AI 编程工具中。

## 为什么需要它

AI 编程工具很强，但直接让 AI 写代码会遇到这些问题：

- **上下文漂移**：AI 忘了前面的设计决策，实现偏离需求
- **自由发挥**：没有约束时 AI 会编造 URL、猜测字段名、跳过错误处理
- **无法积累经验**：同样的错误在不同会话里反复出现
- **改动失控**：改一个接口，相关的文档、缓存、测试全部漏改

熵减用**结构约束**解决这些问题，而不是依赖 AI 的"自觉"。

## 设计哲学

- **文档是契约，不是注释**——先有设计文档，再写代码。Spec 是结构化的，有接口定义、JSON 示例、参数校验表格，人审核时不需要去读 AI 的对话理解它做了什么
- **人做判断，机器做执行**——泾渭分明。你只做三件事：提供需求、审核设计、确认结果。其余全部由 AI 完成
- **对抗熵增，而非假装它不存在**——用结构代替信任，用文件代替记忆，用分工代替全能
- **针对当前，不押注未来**——基于今天 AI 的真实能力边界设计，不假设 AI 明天就能自主完成一切。随着 AI 进化，工作流同步升级，人审核的环节会逐步减少，但"文档驱动"和"结构约束"的核心不会变

## 工作流程

```
需求描述
  ↓ /er-spec（生成技术文档）
全局约束 + 自包含 Spec 文件
  ↓ 人审核设计
  ↓ /er-dev（按 Spec 实现代码）
代码实现
  ↓ /er-test（验证测试）
测试通过 → 自动 Git 提交
```

### 对话即工作流

你不需要记住指令或操心"该走什么流程"。直接用自然语言对话：

- 说"帮我加一个用户标签功能" → 常驻规则自动识别为新需求，走 spec 流程
- 说"这个接口要加一个字段" → 自动触发改动影响判断，先检查 spec 再改代码
- 说"跑一下测试" → 自动进入 verify 阶段

当然，你也可以用精确指令（`/er-spec`、`/er-dev`、`/er-test`）直接触发。对于能力较弱的模型，推荐使用指令以获得更可靠的触发效果。

> **注意**：自动触发的可靠性取决于模型能力。Opus / Sonnet-4 级别的模型可以很好地识别意图，较弱的模型可能需要手动使用指令。

### 降低审核成本，而非增加

人审核是必须的——这是质量的唯一保证。但熵减让审核变快了：

- Spec 是结构化的，人工确认区把待决策项集中在一处，不用翻来翻去找
- 代码实现后自动对照 spec 自检，审核时只需要关注重点差异
- AI 犯的错会被记录到 learning-log，同类错误出现 2 次自动触发固化——审核问题越来越少

### 核心设计

- **Spec 自包含**：每个功能的 spec 文件包含实现所需的全部信息，不依赖对话记忆
- **阶段间人确认**：spec → dev → test，每步人确认后才进入下一步
- **学习机制**：AI 犯的错会被记录到 learning-log，同类错误出现 2 次自动触发固化到 skill 中
- **改动影响判断**：改代码前自动检查是否有 spec 约束，先改文档再改代码
- **文档一致性**：改了一处，所有引用该内容的文档自动同步

## 快速开始

### Claude Code（推荐）

```bash
# 方式1：Plugin marketplace（一键安装）
/plugin marketplace add dylon-entropy/entropy-reduction
/plugin install entropy-reduction@entropy-reduction

# 方式2：手动安装
git clone https://github.com/dylon-entropy/entropy-reduction.git
cd entropy-reduction && bash install.sh
```

### Cursor

```bash
# Plugin marketplace
/add-plugin entropy-reduction

# 或手动安装
git clone https://github.com/dylon-entropy/entropy-reduction.git ~/entropy-reduction
cat ~/entropy-reduction/platforms/cursor-rules.md >> /path/to/project/.cursorrules
```

### Codex

对 Codex 说：

```
Fetch and follow instructions from https://raw.githubusercontent.com/dylon-entropy/entropy-reduction/main/.codex/INSTALL.md
```

### Gemini CLI

```bash
gemini extensions install https://github.com/dylon-entropy/entropy-reduction
```

### OpenClaw / LobsterAI

```bash
git clone https://github.com/dylon-entropy/entropy-reduction.git
cd entropy-reduction && bash install.sh
```

安装后，在对话中输入 `/er-init` 验证是否生效。详细说明见 [INSTALL.md](INSTALL.md)。

### 升级

```bash
# Plugin 安装方式
/plugin update entropy-reduction

# Git clone 安装方式
cd ~/.claude/skills/entropy-reduction && git pull

# Gemini CLI
gemini extensions update entropy-reduction
```

Skills 更新后立刻生效。如果常驻规则有变更（如新增触发词），需要手动更新配置文件中的对应内容——CHANGELOG 会注明哪些版本涉及常驻规则变更。

## 技能清单

| 技能 | 指令 | 触发词 | 说明 |
|------|------|--------|------|
| er-spec | `/er-spec` | "生成技术文档""写 spec" | 从需求生成全局约束 + 自包含 spec |
| er-dev | `/er-dev` | "按设计实现""写代码" | 严格按 spec 实现代码 |
| er-test | `/er-test` | "验证""跑测试" | 自动生成测试并运行 |
| er-review | `/er-review` | "review""审核代码" | 对照 spec 审核代码 |
| er-handoff | `/er-handoff` | "交接""保存进度" | 生成交接文件，跨会话传递进度 |
| er-init | `/er-init` | "熵减初始化" | 从交接文件恢复工作状态 |
| er-metrics | `/er-metrics` | — | 效能分析：耗时统计 + 工作流改进建议 |
| er-git | 自动调用 | — | 分支管理 + pre-commit hook |
| er-sync | 自动调用 | — | 文档一致性同步 |
| er-learning | 自动调用 | — | 学习固化（记录 → 观察 → 固化） |

## 与其他工具的关系

| | 熵减 | Qoder | Superpowers |
|---|---|---|---|
| 形态 | 工作流 / Skill 集 | 商业 IDE 产品 | Skill 集 |
| Spec 驱动 | ✅ | ✅ | 部分 |
| 学习机制 | ✅ learning-log | ❌ | ❌ |
| 人审核控制 | ✅ 强制 | 弱 | 弱 |
| 跨平台 | ✅ | ❌ 绑定 Qoder | ✅ |
| 中文支持 | ✅ 原生 | ❌ | ❌ |

熵减不替代 AI 编程工具，它是工具之上的**方法论层**。

## 文档

- [安装指南](INSTALL.md)
- [设计哲学](docs/philosophy.md)
- [与同类方案对比](docs/comparison.md)
- [FAQ](docs/faq.md)
- [快速上手示例](examples/quickstart.md)

## 项目结构

```
entropy-reduction/
├── README.md
├── LICENSE
├── install.sh              # 手动安装脚本
├── INSTALL.md              # 详细安装指南
├── .claude-plugin/         # Claude Code plugin 适配
├── .cursor-plugin/         # Cursor plugin 适配
├── .codex/                 # Codex 安装指引
├── skills/                 # 核心 skill 文件（10 个）
├── platforms/              # 各平台常驻规则
├── docs/                   # 文档
└── examples/               # 使用示例
```

## License

MIT
