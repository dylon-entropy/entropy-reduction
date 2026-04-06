#!/bin/bash
set -e

# 熵减工作流安装脚本
# 支持 Claude Code / OpenClaw / LobsterAI

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"

echo "⚡ 熵减工作流安装"
echo "========================"
echo ""

# 检测平台
detect_platform() {
    if command -v claude &>/dev/null; then
        echo "claude-code"
    elif [ -d "$HOME/Library/Application Support/LobsterAI" ]; then
        echo "openclaw"
    else
        echo "generic"
    fi
}

PLATFORM=$(detect_platform)
echo "检测到平台: $PLATFORM"
echo "Skills 目录: $SKILLS_DIR"
echo ""

# 创建 skills 目录
mkdir -p "$SKILLS_DIR"

# 复制所有 skill 目录
SKILL_DIRS=(
    "er-spec"
    "er-dev"
    "er-test"
    "er-review"
    "er-handoff"
    "er-init"
    "er-metrics"
    "er-git"
    "er-sync"
    "er-learning"
)

echo "安装 Skills..."
for dir in "${SKILL_DIRS[@]}"; do
    src="$SCRIPT_DIR/skills/$dir"
    dst="$SKILLS_DIR/$dir"
    if [ -d "$src" ]; then
        # 如果目标已存在，备份
        if [ -d "$dst" ]; then
            backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
            echo "  备份已有: $dir → $(basename $backup)"
            mv "$dst" "$backup"
        fi
        cp -r "$src" "$dst"
        echo "  ✅ $dir"
    else
        echo "  ⚠️  跳过 $dir（源目录不存在）"
    fi
done

echo ""
echo "========================"
echo "✅ Skills 安装完成"
echo ""
echo "⚠️  还需要一步：添加常驻规则"
echo ""
echo "将以下文件的内容追加到你的项目配置中："
echo ""

case "$PLATFORM" in
    claude-code)
        echo "  Claude Code → 项目根目录的 CLAUDE.md"
        echo ""
        echo "  cat $SCRIPT_DIR/platforms/claude-rules.md >> /path/to/project/CLAUDE.md"
        ;;
    openclaw)
        echo "  OpenClaw/LobsterAI → AGENTS.md"
        echo ""
        echo "  cat $SCRIPT_DIR/platforms/agents-rules.md >> /path/to/project/AGENTS.md"
        ;;
    *)
        echo "  Claude Code   → CLAUDE.md"
        echo "  OpenClaw      → AGENTS.md"
        echo "  Cursor        → .cursorrules"
        echo ""
        echo "  对应的规则文件在 $SCRIPT_DIR/platforms/ 目录下"
        ;;
esac

echo ""
echo "添加后，在对话中输入 /er-init 验证安装是否成功。"
echo ""
echo "详细说明见: $SCRIPT_DIR/INSTALL.md"
