# Yekermo — UI Guardrails

## Purpose

This document defines non-negotiable UI rules for Yekermo.
All contributors (human or AI) must follow these rules to preserve visual trust, calmness, and brand consistency.

**This is not a design playground. This is a production system.**

---

## Core Principles

- **Calm over clever**
- **Space over decoration**
- **Hierarchy over color**
- **Restraint over expression**

If a change makes the UI louder, it is wrong.

---

## Color System

### Brand colors

- **Primary anchor:** `#5B0E14`
- **Primary canvas:** `#F1E194`

### Usage rules

**#5B0E14**

- App bar background
- Active navigation states
- Selected filter pills
- Primary CTA (max one per screen)

**Must NOT be used for:**

- Card backgrounds
- Large content areas
- Text-heavy surfaces

**#F1E194**

- App background
- Section breathing space
- Contrast behind white cards

### Supporting colors

Neutral tones are mandatory:

- Off-white / cream for cards
- Soft charcoal for primary text
- Muted brown-gray for metadata

Brand colors must appear less frequently than neutrals.

---

## Spacing & Rhythm

- Vertical spacing is increased globally (+10–12% vs default Material)
- Horizontal spacing stays conservative
- **No divider lines between sections**

### Section structure

```
Section title
→ 12–16px gap
Content
→ 24–32px gap before next section
```

Separation is achieved only through space.

---

## Typography

Hierarchy is created using weight and opacity, not size jumps.

- **App title:** SemiBold
- **Section headers:** Medium
- **Primary content:** Medium
- **Metadata:** Regular at 60–70% opacity

**Rules:**

- Metadata is never bold
- Section headers must feel calm, not dominant

---

## Cards

All cards must:

- Share the same corner radius
- Use soft elevation (no borders)
- Contain generous internal padding
- Feel like they float

### Images

- Rounded to match card radius
- Warm, real, tactile photography
- No stock-photo harsh lighting

**Priority:**

- Nearby kitchens (image-forward)
- Your usual (smaller but photographic)
- Never show gray placeholders after data exists

---

## Header & Navigation

### Header

- Left-aligned title
- Notification icon in soft circular container
- No bottom divider

### Bottom navigation

- Inactive icons are muted neutrals
- Active icon + label use brand color
- Navigation must never compete with content

---

## Search Behavior

Search must feel **exploratory, not empty**.

**Rules:**

- Default state shows curated kitchens
- No instructional empty states ("Start typing…")
- Filters are pill-style
- Selected pill uses brand color

---

## Copy Tone

- Calm, warm, grounded
- No hype, no emojis, no urgency
- Short descriptive phrases preferred

---

## Prohibited

- New colors without approval
- Decorative animations
- Borders instead of spacing
- Inconsistent radius or spacing
- Marketing copy

---

## Definition of Done

A screen is complete only if:

- It reads calmly at a glance
- Scrolling feels slow even when fast
- Brand colors feel intentional
- Content feels curated

---

## Screen-specific Cursor Prompts (plug & play)

Paste one of these before asking Cursor to work on a screen.

### Home Screen Prompt

```
Implement the Home screen using Yekermo UI Guardrails.
Prioritize calm vertical rhythm, generous spacing, and image-forward restaurant cards.
Header must feel resting, not dividing.
"Your usual" should feel emotionally sticky, not transactional.
Use brand colors sparingly; rely on neutrals for content surfaces.
If any element feels busy or loud, simplify it.
```

### Search Screen Prompt

```
Implement the Search screen following Yekermo UI Guardrails.
Default state must show curated Ethiopian kitchens — no empty or instructional states.
Filters are pill-style and calm.
Search should feel like browsing with intent, not a task.
Avoid borders, dividers, or strong contrasts.
```

### Restaurant Screen Prompt

```
Implement the Restaurant screen per Yekermo UI Guardrails.
Prioritize food imagery and spacing over UI chrome.
Menu sections must feel slow and readable.
CTAs must be restrained (max one primary per screen).
The screen should feel established and trustworthy, not promotional.
```
