---
name: gmail-persona
license: MIT
description: |
  Build a reusable knowledge base of personas from Gmail history — one file per sender or department — and use those personas to answer questions and draft emails in the right style.

  Use this skill whenever the user wants to:
  - "build personas from my Gmail"
  - "create a contact knowledge base from email"
  - "who usually contacts me about X?"
  - "draft a reply to [person/department] in their style"
  - "what writing style does [department] use?"
  - "summarize how [person] communicates"
  - "create a self-persona from my sent emails"
  - "analyze my email communication patterns"

  The skill guides the full workflow: search → index → persona files → Q&A / email drafting.
  Trigger even when only part of this workflow is mentioned.
---

# Gmail Persona Generator

Build a structured knowledge base from your Gmail history: an email index, per-sender persona files, and a self-persona from your outbox. Use the knowledge base to answer questions about contacts and to draft emails in the right style.

---

## Setup: What to Ask First

Before starting, clarify these with the user (use `AskUserQuestion` if possible, or ask conversationally):

1. **Target organization/domain** — Which emails to focus on?
   - e.g., `@company.com`, `@university.edu`, a specific department ML
   - Accept "all external email" or a specific domain

2. **Direction** — Received emails, sent emails, or both?
   - Received → understand who contacts you and how
   - Sent → build self-persona (your own writing style)
   - Both → full two-way picture (recommended)

3. **Time range** — How far back? Default: past 12 months

4. **Output folder** — Where to save the files?
   - Default: a new `Gmail Personas/` folder in the current workspace

5. **Persona depth** — Shallow (writing style + contact info) or deep (topic clusters + full history)?

---

## Phase 1 — Build the Email Index

### Search received emails

```
Gmail search query: from:<domain> after:<date>
Example: from:company.com after:2025/04/01
```

Use `gmail_search_messages` with `maxResults: 100` and page through using `nextPageToken` until all results are retrieved.

**If the result set is large (500+ emails):**
- Save raw results to a temp file first
- Use a subagent (Explore) to parse chunks and extract structured rows
- Reason: large responses exceed token limits if processed inline

**Index file format** — save to `email_index.md`:

```markdown
# Email Index: [Organization Name]

> Domain: [domain] | Period: [date range] | Count: [N] | Updated: [date]

## All Emails (date descending)

| # | Date | Subject | Sender | messageId |
|---|------|---------|--------|-----------|
| 1 | 2025-06-15 | Re: Budget approval | finance@co.com | abc123 |
...

## By Sender / Department

### [Department or Person Name]
| # | Date | Subject | messageId |
...
```

Group by sender or department when natural clusters emerge (same From address, or common subject prefixes like `[HR]`, `FW:` from a forwarding hub, etc.).

---

## Phase 2 — Build Received-Email Personas

For each major sender cluster (5+ emails, or fewer if they are important):

### Step 1: Sample emails
Use `gmail_read_message` to read 5–10 representative emails from this sender. Pick a variety: different topics, different time periods, long and short.

### Step 2: Analyze and write persona

Write a persona file `persona_[short_name].md` covering:

```markdown
# Persona: [Full Name / Department]

## Basic Info
| Field | Value |
|-------|-------|
| Name | ... |
| Role / Department | ... |
| Email address(es) | ... |
| Phone / Ext | ... |
| Typical response time | ... |

## Role in Communication Flow
[Are they a forwarding hub? Direct contact? Automated sender?]
[Who do they typically CC? What ML lists do they use?]

## Writing Style
### Greeting / Opening
[How do they open? Formal title? Casual? No greeting?]

### Body
[Sentence length, formality level, use of bullet points vs prose]
[Any distinctive phrases they always use?]

### Closing / Signature
[How do they close? What does their signature look like?]

### Tone
[Formal bureaucratic / Collegial / Terse / Warm / Automated]

## Topics They Handle
| Topic | Frequency | Notes |
|-------|-----------|-------|
| Budget submissions | monthly | Always attaches Excel template |
| ...

## Typical Request Pattern
[What action do they usually want from you? Deadline format?]

## Sample Messages
[2–3 short representative excerpts]
```

**Handling automated / system senders:**
If a sender is clearly automated (payment notifications, form confirmations), note this and focus on: trigger conditions, what information they provide, whether a reply is needed.

**Handling forwarding hubs:**
Some people forward many messages but rarely write original content. Note this role explicitly, and list what kinds of messages they forward.

---

## Phase 3 — Build Self-Persona (Sent Emails)

### Search sent emails

```
Gmail search: in:sent to:<domain> after:<date>
```

Read 20–30 sent emails to get a representative sample. Try to include:
- Short replies (1–2 sentences)
- Longer explanatory messages
- Messages to different recipients
- Different topics (requests, submissions, confirmations)

### Analyze your own style

Write `persona_self.md` covering:

```markdown
# Self-Persona: [Your Name]

## Identity
| Field | Value |
|-------|-------|
| Name | ... |
| Email | ... |
| Role | ... |

## Core Style Rules

### Opening
[How do you address recipients? e.g., "LastName + さま" / "Hi [First]," / "Dear [Name],"]

### Body
[Typical length? One-sentence or multi-paragraph?]
[Do you use bullet points? Numbered lists?]
[How formal are you — "will do" vs "I would be happy to"?]

### Closing / Signature
[What closing phrase do you use? e.g., "Thanks," / "Best,"]
[What does your signature look like?]

## Phrases You Often Use
| Situation | Phrase |
|-----------|--------|
| Submitting a document | "Here is the [X]." |
| Confirming | "Got it." / "Understood." |
| ...

## Phrases You Avoid
[List formulaic openings or closings you don't use]

## Signature Variants
[List all signature variants you use and when]

## Typical Patterns

### Pattern A: [Name, e.g. "Quick Submission"]
\```
[Example template]
\```

### Pattern B: ...

## Habits / Timing
[Send times, whether you reply same-day, use of forwarded addresses, etc.]
```

---

## Phase 4 — Index File

Create or update a master index `PERSONAS_INDEX.md`:

```markdown
# Persona Knowledge Base — [Organization Name]

> Built from [N] received emails and [M] sent emails.
> Domain: [domain] | Period: [date range] | Updated: [date]

## Self-Persona
| File | Description |
|------|-------------|
| [persona_self.md] | Your own writing style and habits |

## Contact Personas
| File | Person / Department | Main Topics | Key Contact |
|------|---------------------|-------------|-------------|
| [persona_finance.md] | Finance Dept | Expense reports, budget | finance@co.com |
| ...

## Email Index
- [email_index.md] — All [N] received emails

## Key Contacts Quick Reference
| Person | Email | Phone | Department |
|--------|-------|-------|------------|
| ...
```

---

## Phase 5 — Q&A Mode

When the user asks a question like "Who handles parking permits?" or "What does HR usually send in April?":

1. Scan `email_index.md` for relevant subject lines or senders
2. Use `gmail_read_message` to retrieve the 2–5 most relevant full emails
3. Synthesize an answer citing the email subjects / senders / dates
4. If you find a relevant persona file, summarize the contact's role and style

---

## Phase 6 — Email Drafting Mode

When the user asks to draft or reply to an email:

1. **Identify the recipient** — find the matching persona file
2. **Identify the sender style** — read `persona_self.md`
3. **Draft** following the self-persona rules exactly:
   - Use their typical greeting format
   - Match their typical message length and formality
   - Use their preferred closing and signature variant
4. **Adapt to recipient** — if the recipient is known to be very formal (HR, legal), stay within self-persona style but don't be jarring

Always produce the complete draft. Don't say "you might want to write..." — write it.

---

## Naming Conventions

| File | Content |
|------|---------|
| `email_index.md` | Master index of all received emails |
| `persona_self.md` | Self-persona from sent emails |
| `persona_[shortname].md` | Per-sender/department persona |
| `PERSONAS_INDEX.md` | Master index linking all files |

Use short lowercase names without spaces: `persona_hr.md`, `persona_finance.md`, `persona_john_smith.md`.

---

## Tips for Large Email Corpora

- **Token limit:** Gmail search results can be thousands of lines. Always save raw results to a temp file and parse via subagent if the message count exceeds ~100.
- **Pagination:** Always check for `nextPageToken` and loop until exhausted.
- **Prioritization:** If there are 50+ senders, build personas only for senders with 5+ emails OR those the user explicitly mentions. Create a "minor contacts" section in the index for the rest.
- **Deduplication:** Thread replies often repeat content. When reading emails for analysis, prefer the latest message in a thread.
- **Language:** Match the language of the emails. If emails are in Japanese, write persona files in Japanese. If mixed, use the dominant language.

---

## Quick-Start Checklist

- [ ] Ask user for domain, direction, time range, output folder
- [ ] Search + paginate Gmail → save raw results
- [ ] Parse results → create `email_index.md`
- [ ] Identify top senders/departments (5+ emails each)
- [ ] For each: read sample emails → write `persona_[name].md`
- [ ] Search sent emails → read 20–30 → write `persona_self.md`
- [ ] Create `PERSONAS_INDEX.md`
- [ ] Test: answer one Q&A query; draft one sample email
