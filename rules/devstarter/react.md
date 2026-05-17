# DevStarter React Rules

Apply these rules to all React (.tsx / .jsx) files in the project.

## Components

- Functional components only — no class components in new code
- One component per file — filename matches component name (PascalCase)
- Export named, not default: `export function UserCard()` not `export default`
- Max component length: 150 lines — extract sub-components or hooks if longer
- No inline component definitions inside render — define outside or extract to file

## Props

- Always type props with TypeScript interface: `interface UserCardProps { ... }`
- No `React.FC<Props>` — use plain function signature with typed props
- Destructure props at function signature, not inside body
- No spreading unknown props onto DOM elements (`{...rest}` on `<div>`) — causes invalid HTML attributes

## Hooks

- Call hooks only at top level — never inside conditions, loops, or callbacks
- Custom hooks: prefix `use` (`useUserData`, `useDebounce`)
- No business logic in components — extract to custom hooks
- `useEffect` must have correct dependency array — use ESLint `react-hooks/exhaustive-deps`
- No `useEffect` for data fetching — use React Query / SWR / tRPC instead
- Prefer `useCallback` / `useMemo` only when profiling shows a real performance issue

## State

- Keep state as low as possible — lift only when siblings need it
- No derived state in `useState` — compute from existing state instead
- Prefer `useReducer` over multiple related `useState` calls
- No global state for server data — use React Query or SWR (server state ≠ client state)

## Performance

- Use `React.memo` only for components with expensive renders and stable props
- Keys in lists must be stable unique IDs — never array index as key
- Lazy-load routes and heavy components with `React.lazy` + `Suspense`
- No anonymous functions in JSX props that cause re-renders: extract or `useCallback`

## Styling

- Use CSS modules or Tailwind — no inline styles except truly dynamic values
- No `!important` in CSS — fix specificity instead
- No hardcoded pixel values for font sizes — use design tokens or rem

## File Structure

- Co-locate: component + styles + tests in one folder
- `index.ts` barrel only at feature boundary — not inside feature subfolders
- No importing from `../../../components` — use path aliases (`@/components`)

## Accessibility

- All interactive elements must be keyboard-accessible
- Images: meaningful `alt` text or `alt=""` for decorative images
- Form inputs: always paired with `<label>` (via `htmlFor` or wrapping)
- No `onClick` on non-interactive elements (`div`, `span`) — use `<button>` or `role`

## Testing

- Use React Testing Library — no Enzyme
- Query by accessible role/label/text — never by CSS class or component internals
- Test behavior, not implementation: `userEvent.click(button)` → assert outcome
- Mock at the network boundary (MSW) — not at the component boundary
