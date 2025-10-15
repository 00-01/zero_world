# 🤖 CORE INSTRUCTIONS FOR AI AGENTS

**READ THIS FIRST BEFORE MAKING ANY CHANGES**

---

## 🎯 PROJECT IDENTITY

**Project Name:** Zero World  
**Mission:** The AI Mediator for Human Existence  
**Vision:** By 2030, 100% of digital traffic flows through Zero World  
**Philosophy:** Not an app. AIR for humanity.

---

## 📂 CRITICAL FILE ORGANIZATION RULES

### ✅ ROOT DIRECTORY MUST BE CLEAN

**RULE #1: Root directory is for ESSENTIAL files only**

**Allowed in root:**
- `README.md` (project overview)
- `.gitignore`
- `LICENSE`
- `docker-compose.yml`
- `.env.example`
- Build/deployment scripts (`.sh`, `Dockerfile` at root level)
- Configuration files for tools (`.prettierrc`, `tsconfig.json`, etc.)

**FORBIDDEN in root:**
- ❌ ANY documentation files (except `README.md`)
- ❌ Architecture documents
- ❌ Implementation guides
- ❌ Roadmaps
- ❌ Philosophy documents
- ❌ Testing guides
- ❌ Any `.md` files except `README.md`

### ✅ ALL DOCUMENTATION GOES IN docs/

**RULE #2: docs/ is the ONLY place for documentation**

**Structure:**
```
docs/
├── README.md                      ← Master documentation index
├── ZERO_WORLD_MANIFESTO.md        ← Complete vision
├── ARCHITECTURE.md                ← Technical design
├── guides/                        ← Setup & configuration
├── testing/                       ← Testing documentation
├── deployment/                    ← Deployment guides
└── legal/                         ← Legal documents
```

**If you create documentation, it MUST go in docs/**

### ✅ Component READMEs Stay With Components

**RULE #3: Component-specific documentation stays with the component**

**Examples:**
- `frontend/zero_world/README.md` ✅
- `services/universal-connector/README.md` ✅
- `services/intent-recognition/README.md` ✅

These are NOT moved to docs/ because they're component-specific.

---

## 🏗️ PROJECT ARCHITECTURE

### Core Components

1. **Air Interface** (`frontend/zero_world/`)
   - Flutter app (mobile, desktop, web, AR/VR)
   - Hotkey: Cmd+Space / Ctrl+Space
   - Breathing animations
   - Natural language input

2. **Universal Connector** (`services/universal-connector/`)
   - Rust service
   - Orchestrates parallel queries to 1M+ services
   - Two-tier caching (Moka + Redis)
   - Adapter pattern for service integrations

3. **Intent Recognition** (`services/intent-recognition/`) - *Planned*
   - Go service
   - Natural language understanding
   - Entity extraction
   - Query optimization

4. **Synthesis Engine** (`services/synthesis-engine/`) - *Planned*
   - Python service
   - Multi-source aggregation
   - Result ranking
   - Natural language generation

### Archive Policy

**RULE #4: Don't delete old code, archive it**

- Old/obsolete code goes in `archive/YYYY-MM-DD_description/`
- Example: `archive/2025-10-15_old_python_backend/`
- Never just delete - future reference might be needed

---

## 💻 CODING STANDARDS

### Language-Specific Guidelines

**Rust:**
- Use `cargo fmt` before committing
- Run `cargo clippy` and fix warnings
- Async with Tokio
- Error handling with `Result<T, E>`
- No `unwrap()` in production code

**Flutter/Dart:**
- Use `dart format` before committing
- Follow Flutter style guide
- Use Provider for state management
- Null safety enabled

**Go:**
- Use `gofmt` before committing
- Follow standard Go project layout
- Error handling, not exceptions
- Use context for cancellation

**Python:**
- Use `black` for formatting
- Type hints everywhere
- Follow PEP 8
- Use `async/await` for I/O

### Git Commit Standards

**Format:**
```
🎯 TYPE: Brief description

Detailed explanation:
• Change 1
• Change 2
• Change 3

Impact: What this enables
Files: X files changed
```

**Types:**
- 🌬️ PARADIGM SHIFT (major vision/architecture changes)
- 📚 DOCS (documentation only)
- ✨ FEATURE (new functionality)
- 🐛 FIX (bug fixes)
- ♻️ REFACTOR (code restructuring)
- 🎨 STYLE (formatting, no code change)
- 🧪 TEST (adding/fixing tests)
- 🔧 CONFIG (configuration changes)

---

## 📦 DEPENDENCY MANAGEMENT

### Keep Dependencies Minimal

**RULE #5: Only add dependencies when absolutely necessary**

Before adding a dependency, ask:
1. Can we write this ourselves in <100 lines?
2. Is this dependency actively maintained?
3. Does it have security vulnerabilities?
4. Will it still work in 5 years?

### Version Pinning

- Pin exact versions in production
- Use ranges in development
- Document why each dependency exists

---

## 🔒 SECURITY PRINCIPLES

### Zero-Knowledge Architecture

**RULE #6: Zero World never stores user data**

- Mediation only, no storage
- Stateless services where possible
- User credentials encrypted on-device
- OAuth tokens pass-through only

### API Keys & Secrets

**RULE #7: Never commit secrets**

- Use `.env` files (gitignored)
- Use environment variables
- Use secret management services in production
- Rotate keys regularly

---

## 📊 SCALE & PERFORMANCE

### Target Metrics

**Phase 5 (2030) Targets:**
- **Users:** 10 billion (all humanity)
- **Traffic:** 1 trillion requests/second
- **Latency:** <100ms (P95 global)
- **Uptime:** 99.999%+ (survival-critical)
- **Adapters:** 1M+ services

### Performance Rules

**RULE #8: Optimize for scale from day one**

- Horizontal scaling only (stateless)
- Cache aggressively (3-tier: client, region, global)
- Async/parallel everything
- Monitor latency at every layer
- Fail fast, degrade gracefully

---

## 🧪 TESTING REQUIREMENTS

### Test Coverage

**RULE #9: All production code must have tests**

- Unit tests: >80% coverage
- Integration tests: Critical paths
- Load tests: Before every deploy
- Chaos tests: Monthly

### Test Organization

```
tests/
├── unit/           ← Fast, isolated tests
├── integration/    ← Multi-component tests
├── load/           ← Performance tests
└── e2e/            ← End-to-end tests
```

---

## 🚀 DEPLOYMENT

### Environment Progression

**RULE #10: Changes flow through environments**

1. **Local** → Developer testing
2. **Staging** → Integration testing
3. **Canary** → 5% production traffic
4. **Production** → Full rollout

**No direct production deploys. Ever.**

### Rollback Plan

**RULE #11: Every deploy must be rollback-ready**

- Blue-green deployments
- Feature flags for new features
- Database migrations are reversible
- Automated rollback on error spike

---

## 📝 DOCUMENTATION REQUIREMENTS

### When to Document

**RULE #12: Document decisions, not code**

**Document:**
- Why we chose this approach
- What alternatives were considered
- What the tradeoffs are
- How to extend/modify it

**Don't document:**
- What the code does (code should be self-explanatory)
- Obvious things
- Implementation details (use comments in code)

### Documentation Update

**RULE #13: Update docs when you change behavior**

- If you change an API, update API docs
- If you add a feature, update README
- If you change architecture, update ARCHITECTURE.md
- If you change vision, update MANIFESTO.md

---

## 🤝 CODE REVIEW

### Before Submitting

**RULE #14: Self-review before requesting review**

Checklist:
- [ ] Code runs locally
- [ ] Tests pass
- [ ] Linter passes
- [ ] Documentation updated
- [ ] No console.log/print statements
- [ ] No commented-out code
- [ ] Git commit message follows format

### Review Focus

- Architecture fit (does it match our vision?)
- Performance implications (will it scale?)
- Security concerns (any vulnerabilities?)
- Maintainability (can others understand it?)

---

## 🔄 CONTINUOUS IMPROVEMENT

### Weekly

- Review performance metrics
- Check error rates
- Update documentation
- Refactor one ugly thing

### Monthly

- Architecture review (still on track?)
- Dependency updates
- Security audit
- Load testing

### Quarterly

- Vision alignment (still building "air"?)
- Scale assessment (ready for 10x growth?)
- Team retrospective
- Major refactoring if needed

---

## ⚠️ WHAT NOT TO DO

### Absolute Prohibitions

**NEVER:**
1. ❌ Commit secrets/API keys
2. ❌ Deploy to production without staging test
3. ❌ Store user data without explicit consent
4. ❌ Use `any` in TypeScript or Rust
5. ❌ Ignore compiler warnings
6. ❌ Copy-paste code (extract to function)
7. ❌ Optimize before measuring
8. ❌ Break backward compatibility without migration
9. ❌ Add documentation to root directory
10. ❌ Write synchronous code for I/O

---

## 🎯 DECISION FRAMEWORK

### When Making Technical Decisions

Ask these questions in order:

1. **Alignment:** Does this align with "AI as Air" vision?
2. **Scale:** Will this work at 10B users?
3. **Security:** Are there security implications?
4. **Simplicity:** Is this the simplest solution?
5. **Maintainability:** Can future developers understand this?
6. **Performance:** What's the latency/throughput impact?
7. **Cost:** What's the infrastructure cost at scale?

If unsure, choose:
- Simple over clever
- Fast over feature-rich
- Scalable over optimized
- Secure over convenient

---

## 📚 REQUIRED READING

Before contributing to Zero World, read:

1. **[docs/ZERO_WORLD_MANIFESTO.md](../docs/ZERO_WORLD_MANIFESTO.md)** - The complete vision
2. **[docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md)** - Technical design
3. **This file** - Core instructions

Then read component-specific READMEs for areas you're working on.

---

## 🌬️ THE PHILOSOPHY

Remember why we're building this:

> **"This is not an app. This is AIR.**
> 
> Without air, humans cannot survive.  
> Without Zero World, humans cannot function in the digital age."

Every line of code you write is building essential infrastructure for humanity.

**Make it:**
- **Invisible** (no friction)
- **Effortless** (no learning curve)
- **Instant** (<100ms)
- **Universal** (works for everyone)
- **Essential** (can't live without it)

---

## 🚨 WHEN IN DOUBT

If you're unsure about anything:

1. Check this document first
2. Read the relevant documentation in docs/
3. Look at existing code for patterns
4. Ask before making major changes

**When multiple approaches are possible, choose the one that:**
- Scales better
- Is simpler to understand
- Has fewer dependencies
- Is easier to test
- Aligns with the vision

---

## 📋 CHECKLIST FOR AI AGENTS

Before making changes, verify:

- [ ] I've read this document
- [ ] I understand the "AI as Air" vision
- [ ] My changes align with the architecture
- [ ] Documentation will go in docs/ (not root)
- [ ] Root directory will stay clean
- [ ] I'm following the coding standards
- [ ] I'm considering scale implications
- [ ] I have a rollback plan
- [ ] Tests will be written/updated
- [ ] Documentation will be updated

---

## 🔄 UPDATING THESE INSTRUCTIONS

**RULE #15: Core instructions evolve**

This document can be updated, but:
- Changes require explicit discussion
- New rules must have clear rationale
- Don't remove rules, deprecate them
- Update version number and date

**Current Version:** 1.0  
**Last Updated:** October 15, 2025  
**Next Review:** January 15, 2026

---

**"Every line of code is a breath of air for humanity."**

🌬️
