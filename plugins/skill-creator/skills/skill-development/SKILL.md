---
name: skill-development
description: Creates and improves Claude Code skills following official best practices. Use when the user asks to "create a skill", "write a new skill", "improve a skill", "add a skill to a plugin", or needs guidance on skill structure, naming, descriptions, progressive disclosure, or evaluation.
---

# Skill Development Guide

Creates effective skills for Claude Code. Skills are filesystem-based packages that provide Claude with specialized knowledge, workflows, and tools on demand.

## Core Principles

### Conciseness is Key

The context window is a shared resource. Claude is already smart — only add what it doesn't have. Challenge every piece of content:
- "Does Claude really need this explanation?"
- "Can I assume Claude knows this?"
- "Does this paragraph justify its token cost?"

### Progressive Disclosure

Skills use three loading levels to manage context efficiently:

| Level | When Loaded | Budget | Content |
|-------|------------|--------|---------|
| Metadata | Always (~100 tokens) | name + description | Discovery info for skill selection |
| SKILL.md body | When triggered | Under 5k tokens | Procedures, workflows, quick references |
| Resources | As needed | Effectively unlimited | Scripts, references, assets, examples |

SKILL.md acts as a table of contents pointing Claude to detailed materials. **Keep SKILL.md body under 500 lines.** Move detailed content to separate files.

### Degrees of Freedom

Match instruction specificity to task fragility:

- **High freedom** (text instructions): Multiple approaches valid, decisions depend on context. Example: code review guidelines.
- **Medium freedom** (pseudocode/parameterized): Preferred pattern exists, some variation acceptable. Example: report generation with format options.
- **Low freedom** (exact scripts): Operations are fragile and error-prone, consistency critical. Example: database migrations.

Analogy: narrow bridge with cliffs (low freedom) vs. open field (high freedom).

## Skill Anatomy

Every skill is a directory with a required SKILL.md and optional bundled resources:

```
skill-name/
├── SKILL.md           # Required: frontmatter + instructions
├── references/        # Docs loaded into context as needed
├── examples/          # Working code examples
├── scripts/           # Executable utilities
└── assets/            # Output files (templates, images, fonts)
```

### SKILL.md Structure

```yaml
---
name: processing-pdfs
description: Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---

# Processing PDFs

[Instructions, workflows, references to bundled resources]
```

### Naming Conventions

**Recommended: gerund form** (verb + -ing):
- `processing-pdfs`, `analyzing-spreadsheets`, `managing-databases`, `testing-code`

**Acceptable alternatives:**
- Noun phrases: `pdf-processing`, `spreadsheet-analysis`
- Action-oriented: `process-pdfs`, `analyze-spreadsheets`

**Avoid:** vague names (`helper`, `utils`), overly generic (`documents`, `data`), reserved words (`anthropic-*`, `claude-*`)

**Field constraints:**
- `name`: max 64 characters, lowercase letters/numbers/hyphens only, no XML tags
- `description`: max 1024 characters, non-empty, no XML tags

### Writing Effective Descriptions

The description is the most critical field — Claude uses it to select the right skill from potentially 100+ available skills.

**Always write in third person.** The description is injected into the system prompt.

**Include both what the skill does AND specific triggers:**

```yaml
# Good
description: Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.

description: Generates descriptive commit messages by analyzing git diffs. Use when the user asks for help writing commit messages or reviewing staged changes.

# Bad
description: Helps with documents          # Too vague
description: Use this to process PDFs      # Wrong person (second person)
description: Provides PDF guidance          # No triggers
```

### Bundled Resources

**scripts/**: Executable code for tasks requiring deterministic reliability or repeated execution. Token-efficient — can run without loading into context.

**references/**: Documentation loaded into context as needed. Keeps SKILL.md lean. For large files (>10k words), include search patterns in SKILL.md. Keep references **one level deep** from SKILL.md — avoid chains like SKILL.md -> advanced.md -> details.md.

**examples/**: Working, runnable code and configuration files users can copy and adapt.

**assets/**: Files used in output (templates, images, fonts) — not loaded into context.

**Avoid duplication**: Information lives in either SKILL.md or references, not both.

## Skill Creation Process

Follow these steps in order. Skip only when clearly inapplicable.

### Step 1: Understand with Concrete Examples

Clarify how the skill will be used before writing anything. Ask targeted questions:

- "What functionality should the skill support?"
- "Give examples of how this skill would be used."
- "What would a user say that should trigger this skill?"

Avoid overwhelming with too many questions at once. Skip when usage patterns are already clearly understood.

### Step 2: Plan Reusable Contents

Analyze each concrete example to identify reusable resources:

1. Consider how to execute the task from scratch
2. Identify what scripts, references, and assets help when doing it repeatedly

**Examples:**

| Skill | Observation | Resource |
|-------|------------|----------|
| `pdf-editor` | Rotating a PDF requires rewriting the same code | `scripts/rotate_pdf.py` |
| `frontend-builder` | Webapps need the same boilerplate | `assets/hello-world/` template |
| `big-query` | Querying requires rediscovering schemas | `references/schema.md` |

### Step 3: Create Skill Structure

Create the directory with only the subdirectories actually needed:

```bash
# For a plugin skill
mkdir -p plugin-name/skills/skill-name/references
touch plugin-name/skills/skill-name/SKILL.md

# For a personal/project skill
mkdir -p .claude/skills/skill-name
touch .claude/skills/skill-name/SKILL.md
```

### Step 4: Write the Skill

The skill is authored for another Claude instance to use. Focus on information that is beneficial and non-obvious. Consider what procedural knowledge, domain details, or reusable assets help another Claude execute tasks effectively.

#### Write Resources First

Start with the reusable resources identified in Step 2: scripts, references, and assets. This step may require user input (e.g., brand assets, API documentation, schemas).

#### Write SKILL.md

**Writing style:** Use **imperative/infinitive form** throughout. Objective, instructional language.

```markdown
# Good (imperative)
Parse the frontmatter using sed.
Validate values before use.
To create a hook, define the event type.

# Bad (second person)
You should parse the frontmatter.
You need to validate values.
You can create a hook by defining the event type.
```

**Content structure — answer these questions:**
1. What is the purpose of the skill? (2-3 sentences)
2. When should the skill be used? (reflected in frontmatter description)
3. How should Claude use the skill? (reference all bundled resources)

**Reference resources explicitly:**
```markdown
## Additional Resources

- **`references/patterns.md`** — Common patterns and detailed examples
- **`references/advanced.md`** — Advanced techniques and edge cases
- **`examples/basic-setup.sh`** — Working starter example
```

**For reference files over 100 lines**, include a table of contents at the top so Claude can see the full scope even with partial reads.

### Step 5: Validate, Test, Iterate

#### Validation Checklist

**Structure:**
- [ ] SKILL.md exists with valid YAML frontmatter
- [ ] `name` field: lowercase, hyphens, max 64 chars (gerund form preferred)
- [ ] `description` field: non-empty, max 1024 chars, third person
- [ ] Description includes specific trigger phrases and contexts
- [ ] SKILL.md body under 500 lines
- [ ] All referenced files exist
- [ ] References are one level deep from SKILL.md

**Content:**
- [ ] Body uses imperative/infinitive form, not second person
- [ ] Only includes what Claude doesn't already know
- [ ] Detailed content moved to references/
- [ ] Examples are complete and working
- [ ] Scripts are executable with explicit error handling
- [ ] No time-sensitive information (or clearly marked as deprecated)
- [ ] Consistent terminology throughout
- [ ] No "voodoo constants" — all magic values justified

**Progressive Disclosure:**
- [ ] Core concepts and workflows in SKILL.md
- [ ] Detailed docs in references/
- [ ] Working code in examples/
- [ ] Utilities in scripts/
- [ ] SKILL.md references these resources clearly

#### Testing

**Test trigger accuracy:** Ask questions that should activate the skill. Verify it loads on expected queries.

**Test with multiple models if applicable:**
- **Haiku** (fast): Does the skill provide enough guidance?
- **Sonnet** (balanced): Is the skill clear and efficient?
- **Opus** (powerful): Does the skill avoid over-explaining?

**Test the skill on real tasks.** Observe where Claude struggles, succeeds, or makes unexpected choices.

#### Iterate

After testing, improve based on observations:

1. Use the skill on real tasks
2. Observe behavior — struggles, inefficiencies, unexpected paths
3. Identify specific improvements to SKILL.md or resources
4. Implement changes, retest

**Common improvements:**
- Strengthen trigger phrases in description
- Move bloated sections from SKILL.md to references/
- Add missing examples or scripts
- Clarify ambiguous instructions
- Make references more explicit (Claude may miss implicit connections)

## Common Mistakes

### Weak Trigger Description

```yaml
# Bad: vague, no triggers, not third person
description: Provides guidance for working with hooks.

# Good: third person, specific phrases, concrete scenarios
description: Creates and configures Claude Code hooks for tool interception and automation. Use when the user asks to "create a hook", "add a PreToolUse hook", "validate tool use", or mentions hook events.
```

### Bloated SKILL.md

```
# Bad: 8,000 words in one file
skill-name/
└── SKILL.md  (everything crammed in)

# Good: progressive disclosure
skill-name/
├── SKILL.md           (400 lines — core essentials)
└── references/
    ├── patterns.md    (detailed patterns)
    └── advanced.md    (advanced techniques)
```

### Second Person Writing

```markdown
# Bad
You should start by reading the configuration file.
You need to validate the input.

# Good
Start by reading the configuration file.
Validate the input before processing.
```

### Missing Resource References

SKILL.md must explicitly reference all bundled resources. Claude does not automatically know they exist.

### Offering Too Many Options

```markdown
# Bad
Use pypdf, or pdfplumber, or PyMuPDF, or pdf2image, or...

# Good
Use pdfplumber for text extraction. For scanned PDFs requiring OCR, use pdf2image with pytesseract.
```

## Additional Resources

For detailed guidance beyond this overview, consult:

- **`references/best-practices.md`** — Comprehensive best practices: progressive disclosure patterns, content guidelines, workflow design, anti-patterns, writing style examples, utility script guidance
- **`references/claude-code-features.md`** — Claude Code-specific skill features: full frontmatter reference, subagent execution, dynamic context injection, arguments, invocation control, skill locations, troubleshooting
- **`references/evaluation-guide.md`** — Evaluation and iteration: evaluation-driven development, Claude A/B testing pattern, iterating on existing skills, testing across models
- **`references/skill-creator-original.md`** — Historical reference from the original skill-creator (includes init_skill.py and packaging workflows)
