# Claude Code Skill Features

Claude Code extends the Agent Skills open standard with additional features for invocation control, subagent execution, dynamic context injection, and more.

## Table of Contents

- [Frontmatter Reference](#frontmatter-reference)
- [Content Types](#content-types)
- [Invocation Control](#invocation-control)
- [Arguments and Substitutions](#arguments-and-substitutions)
- [Dynamic Context Injection](#dynamic-context-injection)
- [Subagent Execution](#subagent-execution)
- [Skill Locations and Precedence](#skill-locations-and-precedence)
- [Auto-Discovery](#auto-discovery)
- [Tool Restrictions](#tool-restrictions)
- [Restricting Skill Access](#restricting-skill-access)
- [Sharing and Distribution](#sharing-and-distribution)
- [Troubleshooting](#troubleshooting)

## Frontmatter Reference

All frontmatter fields are optional. Only `description` is recommended.

| Field | Description |
|-------|-------------|
| `name` | Display name. If omitted, uses directory name. Lowercase letters, numbers, hyphens only. Max 64 characters. |
| `description` | What the skill does and when to use it. Claude uses this for skill selection. Max 1024 characters. |
| `argument-hint` | Hint shown during autocomplete. Example: `[issue-number]` or `[filename] [format]`. |
| `disable-model-invocation` | Set `true` to prevent Claude from automatically loading. Manual `/name` invocation only. Default: `false`. |
| `user-invocable` | Set `false` to hide from `/` menu. Background knowledge only. Default: `true`. |
| `allowed-tools` | Tools Claude can use without asking permission when skill is active. |
| `model` | Model to use when skill is active. |
| `context` | Set to `fork` to run in a forked subagent context. |
| `agent` | Subagent type when `context: fork` is set. Options: built-in (`Explore`, `Plan`, `general-purpose`) or custom from `.claude/agents/`. |
| `hooks` | Hooks scoped to this skill's lifecycle. |

## Content Types

### Reference Content

Adds knowledge Claude applies to current work — conventions, patterns, style guides, domain knowledge. Runs inline alongside conversation context.

```yaml
---
name: api-conventions
description: API design patterns for this codebase
---

When writing API endpoints:
- Use RESTful naming conventions
- Return consistent error formats
- Include request validation
```

### Task Content

Step-by-step instructions for specific actions. Often invoked directly with `/skill-name`. Use `disable-model-invocation: true` to prevent automatic triggering.

```yaml
---
name: deploy
description: Deploys the application to production
context: fork
disable-model-invocation: true
---

Deploy the application:
1. Run the test suite
2. Build the application
3. Push to the deployment target
```

## Invocation Control

| Frontmatter | User can invoke | Claude can invoke | Loading behavior |
|-------------|----------------|-------------------|-----------------|
| (default) | Yes | Yes | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description NOT in context; loads when user invokes with `/name` |
| `user-invocable: false` | No | Yes | Description always in context; loads when Claude invokes |

Skill descriptions are loaded into context so Claude knows what's available, but full skill content only loads when invoked. Subagents with preloaded skills work differently: full content injected at startup.

## Arguments and Substitutions

### Available Variables

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed when invoking the skill |
| `$ARGUMENTS[N]` | Specific argument by 0-based index (e.g., `$ARGUMENTS[0]`) |
| `$N` | Shorthand for `$ARGUMENTS[N]` (e.g., `$0`, `$1`) |
| `${CLAUDE_SESSION_ID}` | Current session ID for logging or file naming |

If SKILL.md content doesn't include `$ARGUMENTS`, Claude Code appends `ARGUMENTS: <value>` to the end automatically.

### Example: Single Argument

```yaml
---
name: fix-issue
description: Fixes a GitHub issue
disable-model-invocation: true
---

Fix GitHub issue $ARGUMENTS following coding standards.

1. Read the issue description
2. Understand the requirements
3. Implement the fix
4. Write tests
5. Create a commit
```

Usage: `/fix-issue 123` replaces `$ARGUMENTS` with `123`.

### Example: Positional Arguments

```yaml
---
name: migrate-component
description: Migrates a component between frameworks
---

Migrate the $0 component from $1 to $2.
Preserve all existing behavior and tests.
```

Usage: `/migrate-component SearchBar React Vue`

### Example: Session Logging

```yaml
---
name: session-logger
description: Logs activity for this session
---

Log the following to logs/${CLAUDE_SESSION_ID}.log:

$ARGUMENTS
```

## Dynamic Context Injection

The `` !`command` `` syntax runs shell commands before skill content is sent to Claude. Command output replaces the placeholder.

```yaml
---
name: pr-summary
description: Summarizes changes in a pull request
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

## Pull request context
- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`
- Changed files: !`gh pr diff --name-only`

## Task
Summarize this pull request...
```

Each `` !`command` `` executes immediately (before Claude sees anything), output replaces the placeholder, and Claude receives the fully-rendered prompt.

## Subagent Execution

Add `context: fork` when a skill should run in isolation. The skill content becomes the prompt driving the subagent. The subagent does not have access to conversation history.

**Important:** `context: fork` only makes sense for skills with explicit task instructions. If the skill contains only guidelines without a task, the subagent receives guidelines but no actionable prompt and returns without meaningful output.

### Skill vs Subagent Comparison

| Approach | System prompt | Task | Also loads |
|----------|-------------|------|------------|
| Skill with `context: fork` | From agent type | SKILL.md content | CLAUDE.md |
| Subagent with `skills` field | Subagent's markdown body | Claude's delegation message | Preloaded skills + CLAUDE.md |

### Example: Research Skill

```yaml
---
name: deep-research
description: Researches a topic thoroughly
context: fork
agent: Explore
---

Research $ARGUMENTS thoroughly:

1. Find relevant files using Glob and Grep
2. Read and analyze the code
3. Summarize findings with specific file references
```

The `agent` field specifies the subagent configuration. Built-in options: `Explore`, `Plan`, `general-purpose`. Custom agents from `.claude/agents/` also work.

### Extended Thinking

To enable extended thinking in a skill, include the word "ultrathink" anywhere in the skill content.

## Skill Locations and Precedence

| Location | Path | Applies to |
|----------|------|-----------|
| Enterprise | See managed settings | All users in organization |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

**Precedence:** Enterprise > Personal > Project. Plugin skills use `plugin-name:skill-name` namespace and cannot conflict with other levels.

If a skill and a legacy command (`.claude/commands/`) share the same name, the skill takes precedence.

## Auto-Discovery

### Nested Directory Discovery

When editing files in subdirectories, Claude Code automatically discovers skills from nested `.claude/skills/` directories. Editing a file in `packages/frontend/` causes Claude to look for skills in `packages/frontend/.claude/skills/`. This supports monorepo setups.

### Plugin Discovery

Claude Code scans plugin `skills/` directories for subdirectories containing SKILL.md. Skill metadata (name + description) is loaded always; full content loads when triggered.

### Additional Directories

Skills in `.claude/skills/` within `--add-dir` directories are loaded automatically with live change detection — edit during a session without restarting.

## Tool Restrictions

Restrict what tools a skill can use:

```yaml
---
name: safe-reader
description: Reads files without making changes
allowed-tools: Read, Grep, Glob
---
```

## Restricting Skill Access

Three methods to control which skills Claude can use:

**1. Disable all skills:** Deny the Skill tool in `/permissions`:
```
Skill
```

**2. Allow or deny specific skills** using permission rules:
```
# Allow specific skills
Skill(commit)
Skill(review-pr *)

# Deny specific skills
Skill(deploy *)
```

Permission syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix match with any arguments.

**3. Hide individual skills** with `disable-model-invocation: true` in frontmatter.

Note: `user-invocable` controls menu visibility only, not programmatic access. Use `disable-model-invocation: true` to block automatic invocation.

## Sharing and Distribution

- **Project skills:** Commit `.claude/skills/` to version control
- **Plugins:** Create a `skills/` directory in the plugin
- **Managed:** Deploy organization-wide through managed settings

Plugin skills are distributed as part of the plugin — no separate packaging needed. Users get skills when they install the plugin.

## Skill Description Budget

Skill descriptions are loaded into context so Claude knows what's available. The budget scales dynamically at **2% of the context window**, with a fallback of **16,000 characters**.

Run `/context` to check for warnings about excluded skills.

Override with the `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable.

## Troubleshooting

### Skill Not Triggering

1. Check the description includes keywords users would naturally say
2. Verify the skill appears when asking "What skills are available?"
3. Rephrase the request to match the description more closely
4. Invoke directly with `/skill-name` to confirm it works

### Skill Triggers Too Often

1. Make the description more specific
2. Add `disable-model-invocation: true` for manual-only invocation

### Claude Doesn't See All Skills

If many skills are loaded, they may exceed the character budget. Check with `/context` for warnings. Consider:
- Making descriptions more concise
- Setting `SLASH_COMMAND_TOOL_CHAR_BUDGET` higher
- Using `disable-model-invocation: true` for infrequently needed skills

### Subagent Returns Empty

When using `context: fork`, ensure the skill contains explicit task instructions, not just guidelines. Subagents need actionable prompts.
