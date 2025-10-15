# 🤖 .ai Directory

**Instructions and Context for AI Agents**

---

## Purpose

This directory contains critical instructions and context that AI agents (like GitHub Copilot, Claude, ChatGPT, etc.) should read **BEFORE** making any changes to the codebase.

---

## Files

### [CORE_INSTRUCTIONS.md](./CORE_INSTRUCTIONS.md) ⭐ **READ THIS FIRST**

**Critical rules for working on Zero World:**

1. **File Organization**
   - Root directory stays CLEAN (only essential files)
   - ALL documentation goes in `docs/` (except component READMEs)
   - Archive old code, don't delete it

2. **Project Identity**
   - Mission: AI Mediator for Human Existence
   - Vision: 10B users by 2030
   - Philosophy: "Not an app. AIR."

3. **Architecture**
   - Air Interface (Flutter)
   - Universal Connector (Rust)
   - Intent Recognition (Go) - planned
   - Synthesis Engine (Python) - planned

4. **Coding Standards**
   - Language-specific guidelines
   - Git commit format
   - Testing requirements
   - Security principles

5. **Scale Targets**
   - 10B users
   - 1T requests/second
   - <100ms latency (P95)
   - 99.999% uptime

6. **Decision Framework**
   - Alignment → Scale → Security → Simplicity
   - Simple over clever
   - Secure over convenient

---

## For AI Agents

When you start working on this project:

1. **Read** [CORE_INSTRUCTIONS.md](./CORE_INSTRUCTIONS.md) first
2. **Understand** the vision in [../docs/ZERO_WORLD_MANIFESTO.md](../docs/ZERO_WORLD_MANIFESTO.md)
3. **Review** architecture in [../docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md)
4. **Follow** all rules strictly

**Key Principles:**
- Keep root directory clean
- All docs go in `docs/`
- Scale matters (10B users)
- Security first (zero-knowledge)
- Simple over clever

---

## For Humans

This directory helps AI agents work better on Zero World by:

- Establishing clear rules (clean root, docs in docs/, etc.)
- Providing context (what is Zero World, why it exists)
- Setting standards (coding, testing, deployment)
- Defining the vision (AI as Air, 10B users)

**You can update these instructions** as the project evolves. But be thoughtful - these rules guide all AI contributions.

---

## Why This Exists

As AI agents become more involved in software development, they need clear context and rules. This directory ensures:

1. **Consistency** - All agents follow same rules
2. **Quality** - Standards are enforced
3. **Alignment** - Changes match vision
4. **Organization** - Files go in right places

Without this, each agent might:
- Put docs in different places
- Use different coding styles
- Make scale-ignorant decisions
- Break architecture patterns

With this, all agents understand:
- Zero World is building "air for humanity"
- Root stays clean, docs go in docs/
- Scale to 10B users is non-negotiable
- Security and simplicity are paramount

---

## Updating Instructions

To update [CORE_INSTRUCTIONS.md](./CORE_INSTRUCTIONS.md):

1. Make the change
2. Explain why in commit message
3. Update version number
4. Announce to team

**Don't remove rules, deprecate them:**
```markdown
~~RULE #X: Old rule~~ (Deprecated: Use RULE #Y instead)
```

---

## File Structure

```
.ai/
├── README.md              ← This file (explains .ai directory)
└── CORE_INSTRUCTIONS.md   ← Critical rules (read first)
```

More files may be added as needed:
- `ARCHITECTURE_DECISIONS.md` - Major decision log
- `COMMON_PITFALLS.md` - What to avoid
- `QUICK_REFERENCE.md` - Cheat sheet
- `TESTING_GUIDE.md` - How to test properly

---

**"Clear instructions enable better collaboration - human or AI."**

🤖
