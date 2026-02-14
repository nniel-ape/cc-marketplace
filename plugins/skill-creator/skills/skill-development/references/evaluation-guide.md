# Skill Evaluation and Iteration Guide

How to evaluate, test, and iteratively improve Claude Code skills using Anthropic's recommended patterns.

## Table of Contents

- [Evaluation-Driven Development](#evaluation-driven-development)
- [Evaluation Structure](#evaluation-structure)
- [Claude A/B Iterative Development](#claude-ab-iterative-development)
- [Iterating on Existing Skills](#iterating-on-existing-skills)
- [Testing Across Models](#testing-across-models)
- [Observing Skill Navigation](#observing-skill-navigation)
- [Team Feedback](#team-feedback)

## Evaluation-Driven Development

Create evaluations BEFORE writing extensive documentation. This prevents wasted effort on content that doesn't address actual gaps.

### Process

1. **Identify gaps**: Run Claude on representative tasks WITHOUT a skill. Document specific failures — what went wrong, what knowledge was missing, what procedures were incorrect.

2. **Create evaluations**: Build at least three scenarios that test the identified gaps. Each scenario defines the input, the skill to use, and the expected behavior.

3. **Establish baseline**: Measure performance without the skill. Record how Claude handles each scenario with no skill guidance.

4. **Write minimal instructions**: Add just enough to SKILL.md to address the gaps and pass evaluations. Resist the urge to over-document.

5. **Iterate**: Execute evaluations, compare against baseline, refine. Remove content that doesn't improve evaluation results.

### Key Insight

Start minimal and add only what demonstrably improves outcomes. Many skill authors write too much upfront, then struggle to identify what's actually helping.

## Evaluation Structure

Define evaluations as structured test cases:

```json
{
  "skills": ["pdf-processing"],
  "query": "Extract all text from this PDF file and save it to output.txt",
  "files": ["test-files/document.pdf"],
  "expected_behavior": [
    "Successfully reads the PDF file using an appropriate library or tool",
    "Extracts text content from all pages without missing any",
    "Saves extracted text to output.txt in a clear, readable format"
  ]
}
```

### Evaluation Dimensions

For each evaluation, assess:

- **Correctness**: Does Claude produce the right result?
- **Process**: Does Claude follow the intended workflow?
- **Efficiency**: Does Claude avoid unnecessary steps or tool calls?
- **Edge cases**: Does Claude handle non-standard inputs gracefully?
- **Resource usage**: Does Claude reference the right bundled files?

### Minimum Evaluation Set

Create at least three evaluations covering:

1. **Happy path**: Standard, common use case
2. **Edge case**: Unusual input or boundary condition
3. **Decision point**: Scenario requiring Claude to choose between approaches

## Claude A/B Iterative Development

Work with two Claude instances: **Claude A** (skill author) and **Claude B** (skill user/tester). This separates creation from testing and prevents the author's context from masking skill gaps.

### Creating a New Skill

1. **Complete a task without a skill** — notice what information must be repeatedly provided. These repetitions signal what belongs in a skill.

2. **Identify the reusable pattern** — what knowledge, workflow, or resource would help across similar tasks?

3. **Ask Claude A to draft the skill.** Claude models understand the SKILL.md format natively — no special prompts needed. Provide the examples and patterns identified above.

4. **Review for conciseness.** Challenge Claude A: "Remove the explanation about what win rate means — Claude already knows that." Cut everything that doesn't add non-obvious value.

5. **Improve information architecture.** Ask Claude A: "Organize this so the table schema is in a separate reference file." Apply progressive disclosure.

6. **Test with Claude B** (a fresh instance with the skill loaded). Give Claude B the same tasks. Observe where it struggles — those are skill gaps.

7. **Iterate.** Return to Claude A with specific observations from Claude B. Refine and repeat.

### Why Two Instances

Claude A has full context of the skill's intent and design decisions. This makes it poor at testing — it fills in gaps from memory rather than from the skill. Claude B starts fresh and can only work with what the skill actually provides.

## Iterating on Existing Skills

Alternate between Claude A (refining) and Claude B (testing):

1. **Use the skill in real workflows.** Put it through actual tasks, not contrived examples.

2. **Observe behavior.** Note:
   - Where Claude struggles or takes too many steps
   - Where Claude succeeds effortlessly
   - Where Claude makes unexpected choices
   - Which reference files Claude reads (or misses)

3. **Return to Claude A with specifics.** Not "the skill doesn't work well" but "when asked to process a multi-page PDF, Claude skips the table extraction step."

4. **Review Claude A's suggestions.** Don't blindly accept additions — verify they address the specific gap without bloating the skill.

5. **Apply changes and test.** Always re-test after changes. Sometimes a fix for one scenario breaks another.

### Iteration Anti-Patterns

- **Adding without removing**: Each iteration should consider what to cut as well as what to add.
- **Fixing symptoms instead of root causes**: If Claude misses a step, the fix might be restructuring the workflow rather than adding bold warnings.
- **Over-documenting edge cases**: If an edge case occurs rarely, handle it with a brief note rather than a detailed section.

## Testing Across Models

Skills interact differently with different models. Test with all models the skill will be used with.

### Model Characteristics

**Claude Haiku** (fast, economical):
- Needs more explicit guidance
- Benefits from step-by-step instructions
- May miss implicit connections between sections
- Test: Does the skill provide enough detail?

**Claude Sonnet** (balanced):
- Good balance of guidance following and autonomy
- Handles moderate ambiguity well
- Test: Is the skill clear and efficient?

**Claude Opus** (powerful reasoning):
- May find over-detailed skills constraining
- Capable of making good decisions with minimal guidance
- Test: Does the skill avoid over-explaining? Does it leave room for Opus to apply its reasoning?

### Practical Approach

If the skill will be used across models:

1. Write for Sonnet as the baseline
2. Test with Haiku — add guidance where it struggles
3. Test with Opus — remove guidance that constrains rather than helps
4. Use conditional phrasing where needed: "For complex cases, consider..." rather than "Always do X"

## Observing Skill Navigation

Watch how Claude navigates the skill to identify structural issues.

### Signals to Watch For

**Unexpected exploration paths**: Claude reads files in an order that doesn't match the intended flow. The skill structure may not be intuitive — restructure or add more explicit navigation.

**Missed connections**: Claude doesn't find related content. Links between files need to be more explicit. Add cross-references.

**Overreliance on certain sections**: Claude repeatedly returns to the same section. That content may belong in SKILL.md directly rather than in a reference file.

**Ignored content**: Claude consistently skips certain sections. The content may be unnecessary (remove it) or poorly signaled (improve the section heading or reference from SKILL.md).

### Debugging Tip

Ask Claude "What skills are available?" and "Tell me about the X skill" to verify how Claude perceives the skill's purpose and scope. Compare this with the intended design.

## Team Feedback

When skills are shared across a team:

1. **Share the skill** and observe usage across different people and use cases.

2. **Ask targeted questions:**
   - Does the skill activate when expected?
   - Are the instructions clear enough?
   - What's missing?
   - What's unnecessary?
   - Are there tasks where the skill triggers but shouldn't?

3. **Incorporate feedback** with the same evaluate-then-change discipline. Don't add everything requested — evaluate whether each suggestion actually improves outcomes.

4. **Track recurring issues.** If multiple people report the same problem, it's a genuine skill gap. If only one person reports an issue, it may be a workflow difference rather than a skill problem.
