# DevStarter Angular Rules

Apply these rules to all Angular TypeScript/HTML files in the project.

## Components

- One component per file — selector naming: `app-[feature]-[name]` (kebab-case)
- Use `OnPush` change detection on all components — default `Default` is a performance trap
- No logic in templates — move conditions and transformations to the component class or pipes
- Keep `ngOnInit` slim — delegate to services; no data fetching directly in lifecycle hooks
- Unsubscribe from all Observables in `ngOnDestroy` — use `takeUntilDestroyed()` (.ng17+) or `DestroyRef`

## Signals (Angular 17+)

- Prefer signals over `BehaviorSubject` for local component state
- Use `computed()` for derived state — no manual subscriptions to sync state
- Use `effect()` sparingly — only for side effects that can't be expressed as computed values

## Services

- All services are `providedIn: 'root'` unless feature-scoped
- No business logic in components — delegate to injectable services
- Services own HTTP calls — components never call `HttpClient` directly
- Use `inject()` function over constructor injection in standalone components

## RxJS

- Prefer declarative streams — no imperative `subscribe()` chains for data flow
- Always complete or unsubscribe — no memory leaks from open subscriptions
- Use `async` pipe in templates — auto-unsubscribes on component destroy
- Avoid nested `subscribe()` — use `switchMap`, `mergeMap`, `concatMap` instead
- Handle errors in the stream — use `catchError` not try/catch around `subscribe`

## Routing

- Use lazy loading for all feature modules / standalone routes
- Route guards return `Observable<boolean>` or `CanActivateFn` (functional guards, ng15+)
- No router navigation logic in components — extract to services or route events

## Forms

- Prefer Reactive Forms over Template-driven for complex forms
- Use typed forms (`FormControl<string>`, `FormGroup<...>`) — no untyped `FormControl`
- Validate at the form control level — not in `ngSubmit` handler
- Show validation errors only after field is touched (`dirty || touched` check)

## HTTP

- All HTTP calls go through a dedicated service — never raw `HttpClient` in components
- Use interceptors for auth headers, error handling, and loading states
- Handle errors with `catchError` — surface user-friendly messages, log originals
- Use `HttpParams` for query strings — no string concatenation

## Templates

- No complex expressions in `{{ }}` — use pipes or component properties
- Use `trackBy` on all `*ngFor` / `@for` directives
- No `any` type in template bindings
- Use `@if` / `@for` / `@switch` (ng17+ control flow) over `*ngIf` / `*ngFor` directives in new code

## Modules / Standalone

- New components: use `standalone: true` — no NgModule boilerplate for new code
- Shared UI: `SharedModule` or standalone component imports — no re-declaring components across modules

## Testing

- Use `TestBed` for component tests; plain class instantiation for service unit tests
- Mock HTTP with `HttpClientTestingModule` + `HttpTestingController`
- Use `fakeAsync` + `tick()` for timer-based logic
- Test public API — not private methods or internal state
- One `describe` per component/service — nested `describe` for logical groups
