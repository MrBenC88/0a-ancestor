# Server-side (S1–S6)

## S1 — fetch on the server

Server Components can `await` data directly; no client fetch, no loading spinner, no API route needed for reads. The client receives rendered HTML plus the minimal props for interactive parts.

## S2 — per-request dedupe with `React.cache`

`fetch` calls are deduped within a render automatically; ORM/SDK calls are not.

```ts
import { cache } from "react";
export const getUser = cache(async (id: string) => db.user.findUnique({ where: { id } }));
```

Now layout, page and components can all call `getUser(id)`; it runs once per request. `cache` is per request, not cross-request — for that, use the framework's data cache.

## S3 — cache deliberately

- Decide per route: static (build/ISR), or dynamic (per request). Reading `cookies()`, `headers()` or `searchParams` makes a route dynamic.
- Prefer time- or tag-based revalidation (`revalidate`, `revalidateTag`/`revalidatePath` after mutations) over opting everything out of caching.
- Cache keys must include everything that changes the result (user, locale, flags); never cache personalized data under a shared key.

## S4 — minimize serialized props

Everything passed from a Server Component to a Client Component is serialized into the HTML payload.

```tsx
// ✗ ships the whole record (and maybe sensitive fields)
<ProfileCard user={user} />
// ✓
<ProfileCard name={user.name} avatarUrl={user.avatarUrl} />
```

Never pass secrets or internal-only fields across the boundary.

## S5 — work after the response

Logging, analytics, cache warming and notifications shouldn't delay the response. Use `after()` (Next.js) or the platform's `waitUntil`. Keep it idempotent; it can fail independently.

## S6 — Server Actions are public endpoints

Every action and route handler: validate input (schema), authenticate, authorize the specific resource, then act. Don't rely on the UI having hidden the button. Rate-limit expensive actions.

## Smells in review

- `fetch(..., { cache: "no-store" })` added to fix staleness without a revalidation plan.
- Same DB query called from layout and page without `cache`.
- Server Action without an auth check.
- Large objects passed to client components.
