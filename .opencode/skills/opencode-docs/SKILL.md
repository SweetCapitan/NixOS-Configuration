---
name: opencode-docs
description: Search and read opencode documentation from the repo
license: MIT
compatibility: opencode
---

## What I do

- Search opencode documentation for specific topics
- Read documentation files from the opencode repo
- Answer questions about opencode features and configuration

## When to use me

Use this when you need to:
- Look up opencode documentation
- Find information about opencode features
- Check configuration options or CLI commands

## How to use me

### First time setup

If docs aren't available locally, clone the opencode repo:
```bash
git clone --depth 1 https://github.com/anomalyco/opencode.git ~/.opencode-docs
```

The docs are located at: `~/.opencode-docs/packages/web/src/content/docs/`

### Available documentation

Main docs (English):
- `agents.mdx` - Agent system documentation
- `cli.mdx` - Command line interface
- `commands.mdx` - Available commands
- `config.mdx` - Configuration guide
- `custom-tools.mdx` - Custom tools
- `formatters.mdx` - Code formatters
- `github.mdx` - GitHub integration
- `gitlab.mdx` - GitLab integration
- `keybinds.mdx` - Keyboard shortcuts
- `lsp.mdx` - Language Server Protocol
- `mcp-servers.mdx` - MCP servers
- `models.mdx` - Model providers
- `modes.mdx` - OpenCode modes (build/plan)
- `permissions.mdx` - Permission system
- `plugins.mdx` - Plugins
- `providers.mdx` - API providers
- `rules.mdx` - OpenCode rules
- `sdk.mdx` - Software Development Kit
- `server.mdx` - Server mode
- `skills.mdx` - Skill system
- `tools.mdx` - Available tools
- `troubleshooting.mdx` - Troubleshooting
- `tui.mdx` - Terminal UI
- `config.mdx` - Configuration reference

### Search docs

Use grep to search for specific topics:
```bash
grep -r "keyword" ~/.opencode-docs/packages/web/src/content/docs/
```

### Read a specific doc

Use the read tool to read a specific file:
```
~/.opencode-docs/packages/web/src/content/docs/<doc-name>.mdx
```

## Tips

- Strip .mdx extension when referring to docs
- Many docs have code examples
- Check index.mdx for an overview
