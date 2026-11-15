---
name: fe-best-practices
description: Use when implementing or reviewing frontend code, for conventions on component structure, accessibility, styling, state, testing and bundle budgets.
---

# fe-best-practices

Frontend conventions for implementation and review. For React/Next.js **performance** rules (waterfalls, server/client boundaries, re-renders), use `/vercel-react-best-practices` — this skill doesn't repeat them. A repo's own `AGENTS.md` overrides anything here.

## Components

- One component per file; file name = component name. Colocate its styles, tests and stories.
- Props typed explicitly; no `any`. Prefer unions over boolean flags (`variant: "primary" | "ghost"`).
- Keep components presentational where possible; data loading lives in server components, route loaders or hooks.
- Compose with `children` before adding config props. More than ~7 props is a smell.
- Use the design system's primitives before writing new ones; don't fork a component to change one style.

## Accessibility (must pass in review)

- Semantic elements first: `<button>` for actions, `<a href>` for navigation, real `<label>` for inputs, headings in order.
- Every interactive element reachable and operable by keyboard; visible focus style; no `tabIndex` > 0.
- Images: meaningful `alt`, or `alt=""` if decorative. Icon-only buttons get `aria-label`.
- Color contrast ≥ 4.5:1 for text (3:1 for large text and UI). Never convey state by color alone.
- Forms: errors tied to fields (`aria-describedby`), announced, and not cleared on re-render.
- Dialogs/menus: focus moves in on open, is trapped, returns on close; `Esc` closes.
- Respect `prefers-reduced-motion`.
- Check: axe / Lighthouse a11y on changed pages, and one keyboard-only pass.

## State

- Server state → the data layer (server components, SWR/TanStack Query). UI state → local `useState`. Shared UI state → the smallest context or store that covers its users.
- URL is state: filters, tabs, pagination belong in search params so they survive reload and share.
- No derived state stored in state (see `/vercel-react-best-practices` R1).

## Styling

- Follow the repo's system (Tailwind / CSS modules / CSS-in-JS); don't mix within a component.
- Design tokens for color, spacing, radius, type; no magic numbers.
- Mobile-first; test at 320 px width and with 200 % zoom.

## Bundle budget

- Note the "First Load JS" delta for any route you change; flag increases > 10 KB gzip in the PR.
- New dependencies need a reason in the PR description and a size check.

## Testing

- Test behavior through the UI the user sees (Testing Library queries by role/label), not implementation details.
- Each bug fix gets a test that fails before the fix.
- Visual or e2e tests (Playwright) for critical flows only; keep them deterministic (no real network, fixed time).

## Review checklist

1. A11y items above.
2. Performance: run `/vercel-react-best-practices` categories 1–3 on the diff.
3. Loading, empty and error states all handled and designed.
4. No console errors or hydration warnings.
5. Copy and i18n: no hardcoded user-facing strings if the repo uses i18n.

## Output

- **Implementing**: the code, plus one line listing which checklist items you verified and how.
- **Reviewing**: `[severity] path:line — issue. Fix: …`, most severe first, ≤ 15 items; a11y blockers are always `major` or above.
