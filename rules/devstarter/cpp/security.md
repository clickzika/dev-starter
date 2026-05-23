# C++ Security Rules

## Buffer Safety
- Never use `strcpy`, `sprintf`, `gets` — use `strncpy`, `snprintf`, `fgets` or std::string
- Bounds-check all array/vector accesses in security-sensitive code; use `.at()` (throws) over `[]`
- Check `std::string::size()` before `substr` / slicing
- Use AddressSanitizer (`-fsanitize=address`) in debug builds to catch buffer overflows

## Integer Safety
- Check for overflow before arithmetic on untrusted input: `a + b` overflows if `a > INT_MAX - b`
- Use `std::numeric_limits<T>::max()` for bounds checks
- Avoid signed/unsigned comparison warnings — they hide bugs (`-Wsign-compare`)
- Use fixed-size types (`uint32_t`, `int64_t`) for network/file formats

## Undefined Behavior
- Enable `-fsanitize=undefined` in CI — catches signed overflow, null deref, alignment issues
- Never read uninitialized variables — always initialize at declaration
- No pointer arithmetic past array bounds — even if you "know" it's safe
- No strict aliasing violations — use `std::memcpy` or `std::bit_cast<>` for type punning

## Secrets & Credentials
- Clear sensitive buffers explicitly: `std::fill(buf.begin(), buf.end(), 0)` — compiler may optimize out `memset`; use `OPENSSL_cleanse` or `explicit_bzero` for guaranteed clearing
- Never log passwords, tokens, or keys

## Third-Party Dependencies
- Audit C libraries for known CVEs before including
- Link against system libraries dynamically where distro patches propagate automatically
- Use address-space layout randomization (ASLR) and position-independent executables (`-fPIE -pie`)
