# Bundle size (B1–B5)

Every KB of client JS is downloaded, parsed and executed before the page is interactive, on the user's slowest device. Measure first: `ANALYZE=true next build` with `@next/bundle-analyzer`, or the build output's "First Load JS".

## B1 — avoid barrel imports

```ts
// ✗ may pull the whole library or every re-export in the folder
import { debounce } from "lodash";
import { Button } from "@/components";

// ✓
import debounce from "lodash/debounce";
import { Button } from "@/components/button";
```

Next.js can optimize some packages via `experimental.optimizePackageImports`; prefer direct imports anyway for your own code.

## B2 — split heavy components

```tsx
import dynamic from "next/dynamic";
const Chart = dynamic(() => import("./chart"), { ssr: false, loading: () => <ChartSkeleton /> });
```

Candidates: rich-text editors, charts, maps, syntax highlighters, PDF viewers, admin-only panels, modals opened on click.

## B3 — client boundaries at the leaves

`"use client"` marks a boundary: the file **and everything it imports** ships to the browser. Keep pages and layouts as Server Components; make the interactive bit (a button, a form) the client component and pass server-rendered content as `children`.

```tsx
// server component
<Accordion>{/* client: toggles open state */}
  <ProductDetails product={p} />   {/* stays server-rendered */}
</Accordion>
```

## B4 — defer third-party scripts

Analytics, chat widgets, A/B tools: `next/script` with `strategy="lazyOnload"` or load on first interaction. Audit them; they are often the largest scripts on the page.

## B5 — preload on intent

`<Link>` prefetches visible routes in production. For chunks behind interaction, start the import on `onMouseEnter`/`onFocus` (`() => import("./heavy")`) so it's ready by the click.

## Smells in review

- New dependency > ~20 KB gzip for a small feature (check bundlephobia / pkg-size).
- `"use client"` added to a page or layout.
- `moment`, full `lodash`, icon packs imported wholesale.
- Large JSON or constants imported into a client component.
