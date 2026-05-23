# DevStarter Java Rules

Apply these rules to all Java files in the project.

## Null Safety

- Never return `null` from a public method — use `Optional<T>` for nullable results
- Never pass `null` as an argument — use `Optional` or method overloading
- Annotate parameters with `@NonNull` / `@Nullable` (JSR-305 or Lombok)
- Use `Objects.requireNonNull()` at constructor/method entry for required parameters

## Classes and Design

- One top-level class per file — class name must match filename
- Prefer composition over inheritance — extend only when `is-a` is semantically true
- Mark classes `final` if not designed for extension
- No utility classes with only `static` methods — prefer static factory methods on the type they create, or a module-level helper with a private constructor

## Spring (if used)

- Inject dependencies via constructor — no `@Autowired` on fields
- Use `@Value("${prop}")` or `@ConfigurationProperties` — never hardcode config
- Validate request bodies with `@Valid` + Bean Validation annotations — not manual null checks
- Keep controllers thin — delegate to service layer; no business logic in `@RestController`
- Return `ResponseEntity<T>` from controllers for explicit status control

## Error Handling

- Never catch `Exception` or `Throwable` unless re-throwing or wrapping
- Catch the most specific exception type possible
- Log exception details before swallowing or wrapping — include stack trace
- Use custom checked exceptions for recoverable domain errors; unchecked for programmer errors

## Collections

- Prefer `List.of()`, `Set.of()`, `Map.of()` for immutable collections
- Use streams for transformation — prefer method references over lambdas where readable
- Never modify a collection while iterating it — use `Iterator.remove()` or collect to new list

## Naming

- Classes: UpperCamelCase; methods/variables: lowerCamelCase; constants: SCREAMING_SNAKE_CASE
- Boolean variables/methods: prefix `is`, `has`, `can`, `should` (`isActive`, `hasPermission`)
- No abbreviations in public APIs — full words only (`calculateTotal` not `calcTot`)

## Testing

- Use JUnit 5 (`@Test`, `@BeforeEach`, `@AfterEach`)
- Use AssertJ for assertions — no `assertEquals` from JUnit directly
- Use Mockito for mocking — `@Mock` + `@InjectMocks` or `@ExtendWith(MockitoExtension.class)`
- Test method names: `methodName_scenario_expectedBehavior()` pattern
- One logical assertion per test — keep tests focused
