# Installing Entropy Reduction for Codex

## Prerequisites

- Git

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/dylon-entropy/entropy-reduction.git ~/.codex/entropy-reduction
   ```

2. **Create the skills symlink:**
   ```bash
   mkdir -p ~/.agents/skills
   ln -s ~/.codex/entropy-reduction/skills ~/.agents/skills/entropy-reduction
   ```

3. **Add resident rules** to `~/.codex/AGENTS.md`:
   ```bash
   cat ~/.codex/entropy-reduction/platforms/agents-rules.md >> ~/.codex/AGENTS.md
   ```

4. **Restart Codex.**

## Verify

```
/er-init
```

## Updating

```bash
cd ~/.codex/entropy-reduction && git pull
```

## Uninstalling

```bash
rm ~/.agents/skills/entropy-reduction
# Optionally: rm -rf ~/.codex/entropy-reduction
```

Remove the "熵减工作流" section from `~/.codex/AGENTS.md`.
