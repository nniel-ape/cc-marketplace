# Skill Authoring Best Practices

Comprehensive best practices for creating effective Claude Code skills, sourced from Anthropic's official skill authoring guidance.

## Table of Contents

- [Conciseness Deep-Dive](#conciseness-deep-dive)
- [Degrees of Freedom](#degrees-of-freedom)
- [Progressive Disclosure Patterns](#progressive-disclosure-patterns)
- [Reference File Guidelines](#reference-file-guidelines)
- [Common Skill Patterns](#common-skill-patterns)
- [Content Guidelines](#content-guidelines)
- [Workflows and Feedback Loops](#workflows-and-feedback-loops)
- [Writing Style](#writing-style)
- [Anti-Patterns](#anti-patterns)
- [Utility Scripts](#utility-scripts)
- [MCP Tool References](#mcp-tool-references)

## Conciseness Deep-Dive

The context window is a shared resource. At startup, only metadata (~100 tokens per skill) is pre-loaded. Claude reads SKILL.md only when triggered, and references only as needed. But once loaded, every token competes with conversation history.

**Default assumption:** Claude is already very smart. Only add context Claude doesn't already have.

**Good example (~50 tokens):**
```markdown
## Extract PDF text

Use pdfplumber for text extraction:

    import pdfplumber
    with pdfplumber.open("file.pdf") as pdf:
        text = pdf.pages[0].extract_text()
```

**Bad example (~150 tokens):**
```markdown
## Extract PDF text

PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need to
use a library...
```

The bad example wastes tokens explaining what a PDF is — Claude already knows.

## Degrees of Freedom

Match instruction specificity to how fragile and variable the task is.

### High Freedom (Text-Based Instructions)

Use when multiple approaches are valid and decisions depend on context.

```markdown
## Code review process

1. Analyze the code structure and organization
2. Check for potential bugs or edge cases
3. Suggest improvements for readability and maintainability
4. Verify adherence to project conventions
```

### Medium Freedom (Pseudocode or Parameterized Scripts)

Use when a preferred pattern exists but some variation is acceptable.

```python
def generate_report(data, format="markdown", include_charts=True):
    # Process data
    # Generate output in specified format
    # Optionally include visualizations
```

### Low Freedom (Exact Scripts, Few/No Parameters)

Use when operations are fragile, consistency is critical, or a specific sequence must be followed.

```bash
python scripts/migrate.py --verify --backup
```
Do not modify the command or add additional flags.

**Analogy:** Think of Claude navigating a path:
- **Narrow bridge with cliffs on both sides** — one safe way forward. Provide exact instructions. Example: database migrations.
- **Open field with no hazards** — many paths work. Give general direction. Example: code reviews.

## Progressive Disclosure Patterns

SKILL.md serves as an overview pointing Claude to detailed materials, like a table of contents.

### Pattern 1: High-Level Guide with References

SKILL.md provides a quick start. Detailed docs in separate files loaded only when needed.

```
skill-name/
├── SKILL.md            # Quick start + section links
├── references/
│   ├── forms.md        # Loaded when working with forms
│   ├── reference.md    # Loaded for API details
│   └── examples.md     # Loaded when examples needed
```

### Pattern 2: Domain-Specific Organization

Organize by domain to avoid loading irrelevant context.

```
skill-name/
├── SKILL.md
├── references/
│   ├── finance.md      # Loaded for finance tasks
│   ├── sales.md        # Loaded for sales tasks
│   └── marketing.md    # Loaded for marketing tasks
```

### Pattern 3: Conditional Details

SKILL.md has basic content for common cases. Advanced content in separate files for specific features.

```markdown
## Basic Usage

[Common instructions here]

## Advanced Features

For advanced configuration, see `references/advanced.md`.
```

## Reference File Guidelines

### Keep References One Level Deep

Claude may partially read files when they're referenced from other referenced files (using `head -100` for preview). Deeply nested references degrade discovery.

```
# Bad: too deep
SKILL.md -> advanced.md -> details.md -> specifics.md

# Good: flat, one level from SKILL.md
SKILL.md -> advanced.md
SKILL.md -> reference.md
SKILL.md -> examples.md
```

### Structure Longer Files with a Table of Contents

For reference files longer than 100 lines, include a table of contents at the top so Claude can see the full scope even with a partial read.

```markdown
# API Reference

## Table of Contents
- [Authentication](#authentication)
- [Endpoints](#endpoints)
- [Error Handling](#error-handling)
- [Rate Limits](#rate-limits)

## Authentication
...
```

### Avoid Duplication

Information lives in either SKILL.md or reference files, not both. Prefer reference files for detailed content — keeps SKILL.md lean while making information discoverable.

## Common Skill Patterns

### Template Pattern

For strict requirements:
```markdown
ALWAYS use this exact template structure:
[template here]
```

For flexible guidance:
```markdown
Here is a sensible default format, but use your best judgment:
[template here]
```

### Examples Pattern

Provide input/output pairs just like regular prompting:

```markdown
## Commit Message Examples

**Input:** `git diff` showing renamed variable across 3 files
**Output:** `Rename userID to userId for consistency`

**Input:** `git diff` showing new error handling in API client
**Output:** `Add retry logic with exponential backoff to API client`
```

### Conditional Workflow Pattern

Guide Claude through decision points with branching logic:

```markdown
## Document Processing

Determine the operation type:

**Creating a new document:**
1. Select template from `assets/templates/`
2. Fill in required fields
3. Validate against schema

**Editing an existing document:**
1. Read the current document
2. Identify sections to modify
3. Preserve formatting and metadata
```

If conditional workflows become large, push them into separate reference files and tell Claude to read the appropriate one.

## Content Guidelines

### Avoid Time-Sensitive Information

```markdown
# Bad
If you're doing this before August 2025, use the old API.

# Good (use a collapsible/clearly marked section)
## Deprecated Patterns
> These patterns are deprecated. Use the current patterns above instead.
```

### Use Consistent Terminology

Choose one term and use it throughout the skill:

```
# Good: consistent
Always "API endpoint"
Always "field" (not "property", "attribute", "key")
Always "extract" (not "parse", "pull", "get")

# Bad: inconsistent
"API endpoint" / "URL" / "API route" / "path"
```

## Workflows and Feedback Loops

### Checklist Pattern for Complex Tasks

Break complex operations into sequential steps with a checklist Claude can track:

```markdown
## Deployment Checklist

- [ ] Run test suite and verify all pass
- [ ] Build the application
- [ ] Validate build output
- [ ] Deploy to staging
- [ ] Run smoke tests
- [ ] Deploy to production
```

### Plan-Validate-Execute Pattern

For batch operations, destructive changes, or high-stakes operations:

1. **Plan**: Create a structured plan of actions
2. **Validate**: Run a validation script against the plan
3. **Execute**: Only proceed if validation passes

```markdown
## Batch File Rename

1. Generate rename plan as JSON: `scripts/plan_renames.py`
2. Validate the plan: `scripts/validate_plan.py plan.json`
3. Execute only if validation passes: `scripts/execute_renames.py plan.json`
```

Make validation scripts verbose with specific error messages.

### Feedback Loop Pattern

Run a check, fix errors, repeat:

```markdown
## Style Compliance

1. Run `scripts/check_style.py` on the document
2. Review reported issues
3. Fix each issue
4. Re-run check
5. Repeat until all issues pass
```

## Writing Style

### Imperative/Infinitive Form

Write verb-first instructions, not second person:

```markdown
# Good (imperative)
Parse the frontmatter using sed.
Extract fields with grep.
Validate values before use.
To create a hook, define the event type.
Configure the MCP server with authentication.

# Bad (second person)
You should parse the frontmatter.
You need to extract fields.
You can validate values.
You should create a hook by defining the event type.
```

### Third Person in Descriptions

The frontmatter description must use third person:

```yaml
# Good
description: Processes Excel files and generates reports. Use when analyzing spreadsheets or .xlsx files.

# Bad
description: I can help you process Excel files.
description: Use this to process Excel files.
description: You can use this to process Excel files.
```

### Be Direct in Descriptions

Use the pattern: "Does X. Use when Y."

```yaml
# Good: direct, specific
description: Extracts text from PDFs. Use when working with PDF files or document extraction.

# Bad: wordy preamble
description: This skill should be used when the user wants to extract text from PDFs and needs help with document processing workflows.
```

## Anti-Patterns

### Windows-Style Paths

Always use forward slashes:
```
# Good
scripts/helper.py
references/patterns.md

# Bad
scripts\helper.py
references\patterns.md
```

### Too Many Options

```markdown
# Bad
Use pypdf, or pdfplumber, or PyMuPDF, or pdf2image, or camelot...

# Good
Use pdfplumber for text extraction. For scanned PDFs requiring OCR, use pdf2image with pytesseract.
```

### Assuming Tools Are Installed

Be explicit about dependencies and installation steps rather than assuming availability.

### Voodoo Constants

Configuration parameters must be justified — avoid unexplained magic numbers:

```python
# Good: justified
REQUEST_TIMEOUT = 30   # HTTP requests typically complete within 30 seconds
MAX_RETRIES = 3        # Three retries balances reliability vs speed

# Bad: unexplained
TIMEOUT = 47   # Why 47?
RETRIES = 5    # Why 5?
```

### Over-Explaining Common Knowledge

Don't explain what JSON is, how HTTP works, or what a function does. Claude knows this. Focus on domain-specific knowledge and non-obvious procedures.

## Utility Scripts

### Solve, Don't Punt

Handle error conditions in scripts rather than letting Claude figure it out:

```python
# Good: explicit error handling with fallbacks
def read_config(path):
    try:
        return json.loads(open(path).read())
    except FileNotFoundError:
        return create_default_config(path)
    except PermissionError:
        return DEFAULT_CONFIG

# Bad: just fail
def read_config(path):
    return json.loads(open(path).read())
```

### Self-Documenting Constants

Use named constants with comments explaining the rationale, not just the value.

### Script Execution vs Reading

Make clear whether Claude should execute a script or read it as reference:

```markdown
# Execute (most common)
Run `scripts/analyze_form.py` to extract fields.

# Read as reference
See `scripts/analyze_form.py` for the field extraction algorithm.
```

### Verifiable Intermediate Outputs

For critical operations, create intermediate outputs that can be validated before proceeding. This is the plan-validate-execute pattern applied to scripts.

## MCP Tool References

Always use fully qualified tool names when referencing MCP tools:

```markdown
# Good
Use `BigQuery:bigquery_schema` to inspect table structure.
Create issues with `GitHub:create_issue`.

# Bad
Use the bigquery schema tool.
Create a GitHub issue.
```

The format is `ServerName:tool_name`.
