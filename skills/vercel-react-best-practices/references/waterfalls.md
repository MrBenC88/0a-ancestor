# Waterfalls (W1–W5)

A waterfall is any `await` that blocks work that didn't depend on it. Each one adds a full round-trip to the critical path. They are the single biggest perf cost in server-rendered React.

## W1 — parallelize independent work

```ts
// ✗ 3 round-trips in series
const user = await getUser(id);
const orders = await getOrders(id);
const prefs = await getPrefs(id);

// ✓ 1 round-trip
const [user, orders, prefs] = await Promise.all([getUser(id), getOrders(id), getPrefs(id)]);
```

Use `Promise.allSettled` when one failure shouldn't fail the page.

## W2 — start early, await late

```ts
// ✓ the slow call starts before the branch, and is only awaited where needed
const statsP = getStats(id);
if (!(await canView(id))) return notFound();
const stats = await statsP;
```

Attach a `.catch` or await it on every path so an unused rejected promise isn't unhandled.

## W3 — no fetch-on-render chains

Parent fetches `user`, renders `<Orders userId>`, which then fetches orders: two sequential trips. Fix by fetching both in the parent with `Promise.all`, or render siblings in separate `<Suspense>` boundaries that each fetch on their own, in parallel.

## W4 — stream with Suspense

```tsx
export default function Page() {
  return (
    <>
      <Header />                       {/* renders immediately */}
      <Suspense fallback={<Skeleton />}>
        <SlowRecommendations />        {/* streams in when ready */}
      </Suspense>
    </>
  );
}
```

Put the boundary as close to the slow component as possible; one boundary around the whole page defeats streaming. `loading.tsx` is a route-level boundary.

## W5 — cheap checks first

Validate params, check auth and feature flags before kicking off expensive queries. In route handlers and Server Actions, return early on bad input.

## Finding them

- Look for consecutive `await` lines whose second call doesn't use the first result.
- Server timings / tracing: sequential spans of similar length are a waterfall.
- In the browser Network panel: requests that start only after an earlier one ends.
