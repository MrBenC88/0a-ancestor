# Client: data fetching, re-renders, rendering (C, R, D)

Profile before optimizing: React DevTools Profiler ("Highlight updates"), or the Performance panel's INP breakdown.

## C1 — use a deduping data cache

`useEffect(() => { fetch(...).then(setData) }, [])` has no dedupe, no caching, races on fast param changes and refetches on every mount. Use SWR or TanStack Query (or server-fetch and pass data down). Same key → one request shared by all components.

## C2 — share global listeners

One `scroll`/`resize`/`storage` listener per component multiplies work. Use a shared subscription (`useSyncExternalStore` over a single listener), mark listeners `{ passive: true }`, and throttle with `requestAnimationFrame`.

## R1 — derive, don't sync

```tsx
// ✗ extra render + can drift
const [fullName, setFullName] = useState("");
useEffect(() => setFullName(`${first} ${last}`), [first, last]);
// ✓
const fullName = `${first} ${last}`;
```

To reset state when a prop changes, pass a `key` instead of an effect.

## R2 — narrow subscriptions

- Move state down to the component that uses it.
- Split one big context into stable pieces (data vs actions), or use a store with selectors (`useStore(s => s.count)`).
- Pass `children` through stateful wrappers so they don't re-render with the wrapper.

## R3 — functional updates

`setItems(prev => [...prev, item])` reads fresh state and lets the callback be stable (no `items` dependency), which keeps memoized children from re-rendering.

## R4 — lazy initial state

`useState(() => parse(localStorage.getItem(k)))`, not `useState(parse(...))` — the latter runs on every render.

## R5 — transitions for non-urgent work

```tsx
const [query, setQuery] = useState("");
const deferred = useDeferredValue(query);
<SearchResults query={deferred} />   // typing stays responsive
```

Use `startTransition` for state updates that trigger heavy renders (tab switches, filters).

## R6 — memoize with evidence

`memo`, `useMemo` and `useCallback` cost memory and comparisons. Use them when the Profiler shows an expensive render, or when a value is a dependency of a memoized child or effect. (React Compiler, if enabled, handles most of this; don't hand-memoize on top.)

## D1 — long lists

Virtualize lists over a few hundred rows (TanStack Virtual, react-window). For long static sections, `content-visibility: auto` with `contain-intrinsic-size` skips off-screen layout.

## D2 — hydration mismatches

Server and first client render must match. Don't render `Date.now()`, `Math.random()`, locale-dependent formatting or `window` checks directly; render a stable placeholder and fill in after mount, or use `suppressHydrationWarning` only for known-benign text like timestamps.

## D3 — images and fonts

`next/image` with `width`/`height` (or `fill` + `sizes`) prevents CLS; `priority` only on the LCP image. `next/font` self-hosts fonts and avoids layout shift.
