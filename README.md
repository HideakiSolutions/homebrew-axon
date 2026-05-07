# homebrew-axon

Homebrew tap for [axon](https://github.com/HideakiSolutions/axon) — context engine for AI coding agents.

## Install

```bash
brew tap HideakiSolutions/axon
brew install axon
```

After installation, configure a project to use axon with Claude Code:

```bash
axon-setup /path/to/your-project
```

## What it provides

- `axon` — the main CLI binary (index, serve, capsule, skeleton, status)
- `axon-setup` — project setup script that wires Claude Code hooks for the axon workflow

## Usage

```bash
# Index a project
axon index /path/to/your-project

# Start MCP server
axon serve

# Get a context capsule
axon capsule "how does the indexer work"
```

## Requirements

- macOS Apple Silicon (arm64) or Linux x86-64
- [Claude Code](https://claude.ai/code) for MCP integration

## License

MIT — see [axon/LICENSE](https://github.com/HideakiSolutions/axon/blob/main/LICENSE)
