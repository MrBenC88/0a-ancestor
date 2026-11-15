---
name: vercel-react-best-practices
description: Use when writing, reviewing or refactoring React or Next.js code for performance (data fetching, server/client components, bundle size, re-renders), applying rules ranked by impact.
---

# vercel-react-best-practices

Performance rules for React and Next.js (App Router), ordered by impact. Fix higher categories first: one removed waterfall beats fifty `useMemo`s. Load only the reference file for the category you're working on.

## How to use

- **Implementing**: skim the rule list for the categories your change touches; open the reference only when a rule applies.
- **Reviewing**: check categories 1 → 7 in order; report the rule ID (e.g. `W2`) with each finding.
- **Measuring**: claim a perf win only with evidence — bundle analyzer output, a React Profiler trace, Web Vitals (LCP, INP, CLS) or server timings.

## 1. Eliminate waterfalls — critical · `references/waterfalls.md`

- **W1** Start independent fetches together (`Promise.all`), never `await` them one after another.
- **W2** Start promises early, `await` late: kick off work before branching logic that may not need it.
- **W3** Don't fetch in a parent and then again in a child after render; hoist or co-locate with parallel `Suspense`.
- **W4** Stream slow parts behind `<Suspense>` so the shell and fast data render first.
- **W5** Check cheap conditions (auth, flags, params) before expensive awaits; return early.

## 2. Bundle size — critical · `references/bundle.md`

- **B1** Import from the module path, not a barrel file (`lodash/debounce`, not `lodash`; avoid re-export `index.ts` hubs).
- **B2** `next/dynamic` / `React.lazy` for heavy, below-the-fold or interaction-only components (editors, charts, maps).
- **B3** Keep `"use client"` at the leaves; a client boundary pulls its whole import tree into the browser bundle.
- **B4** Load third-party scripts after hydration or on interaction (`next/script` `lazyOnload`/`afterInteractive`).
- **B5** Preload on intent (hover/focus) for routes or chunks the user is about to need.

## 3. Server-side — high · `references/server.md`

- **S1** Fetch in Server Components; send data, not fetch logic, to the client.
- **S2** Dedupe per request with `React.cache()` for non-`fetch` data access (ORM, SDK calls).
- **S3** Cache deliberately: decide static vs dynamic per route; use tagged revalidation instead of `no-store` everywhere.
- **S4** Pass only the fields the client needs across the server→client boundary; every prop is serialized into the HTML.
- **S5** Do non-blocking work (logging, analytics, cache warm) after the response with `after()` / `waitUntil`.
- **S6** Authenticate and authorize inside every Server Action and route handler; they're public endpoints.

## 4. Client data fetching — medium-high · `references/client.md`

- **C1** Use a request-deduping cache (SWR / TanStack Query) instead of `useEffect` + `fetch`.
- **C2** One passive, shared listener for global events (scroll, resize, storage), not one per component.

## 5. Re-renders — medium · `references/client.md`

- **R1** Derive values during render; don't mirror props/state into state with an effect.
- **R2** Read state where it's used; subscribe to the narrowest slice (selectors, split contexts).
- **R3** Functional `setState(prev => …)` for updates from callbacks; keeps callbacks stable.
- **R4** Lazy initial state for expensive defaults: `useState(() => compute())`.
- **R5** `useTransition` / `useDeferredValue` for non-urgent updates (filters, search results).
- **R6** Memoize only what profiling shows is expensive, or what is passed to memoized children.

## 6. Rendering — medium · `references/client.md`

- **D1** Virtualize long lists; `content-visibility: auto` for long, off-screen sections.
- **D2** Avoid hydration mismatches (dates, `Math.random`, `window` in render); gate client-only values.
- **D3** Use `next/image` with explicit size and `priority` only for the LCP image; `next/font` for fonts.

## 7. JavaScript hot paths — low-medium

- **J1** Build a `Map`/`Set` once for repeated lookups instead of `array.find` in a loop.
- **J2** Hoist RegExp, `Intl` formatters and constant objects out of render and loops.
- **J3** Batch DOM reads and writes; don't interleave layout reads with style writes.

## Output

- **Implementing**: the code, plus one line per rule applied (`Applied W1, B3`).
- **Reviewing**: findings as `[impact] RULE path:line — issue. Fix: …`, ordered by category, ≤ 15 items, each with the concrete cost (extra round-trip, KB shipped, re-renders per keystroke).

Rules distilled from Vercel's public React/Next.js performance guidance; rewritten in our own words.
