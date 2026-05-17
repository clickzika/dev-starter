# C++ Testing Rules

## Framework
- Use GoogleTest (gtest/gmock) for most projects; Catch2 as alternative
- Test files: `test_*.cpp` or `*_test.cpp` in `tests/` directory
- Build with CMake: `enable_testing()` + `add_test()`

## Unit Tests
```cpp
#include <gtest/gtest.h>

TEST(UserServiceTest, ReturnsNullWhenNotFound) {
    MockUserRepo repo;
    EXPECT_CALL(repo, FindById("123")).WillOnce(Return(nullptr));
    UserService svc{&repo};
    EXPECT_EQ(svc.GetUser("123"), nullptr);
}
```

## What to Test
- Public API methods — not private/protected
- Edge cases: empty input, null pointers, boundary values, integer overflow
- Error paths: what happens when a dependency fails
- Thread safety: concurrent access patterns for shared state

## Mocking
- Use GoogleMock `MOCK_METHOD` for interface mocking
- Prefer interface injection over global state for testability
- Mock external I/O (filesystem, network, time) — test with real data structures

## Sanitizers in Tests
Run test suite with sanitizers enabled:
```cmake
target_compile_options(tests PRIVATE -fsanitize=address,undefined)
target_link_options(tests PRIVATE -fsanitize=address,undefined)
```

## Performance Tests
- Use Google Benchmark for micro-benchmarks
- Benchmark before and after optimizations — never optimize without measurement
- Run benchmarks on the same hardware under the same conditions
