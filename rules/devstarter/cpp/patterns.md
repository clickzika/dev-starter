# C++ Design Patterns

## RAII Pattern
```cpp
class FileHandle {
public:
    explicit FileHandle(const char* path) : f_(std::fopen(path, "r")) {
        if (!f_) throw std::runtime_error("Cannot open file");
    }
    ~FileHandle() { if (f_) std::fclose(f_); }
    // Delete copy; allow move
    FileHandle(const FileHandle&) = delete;
    FileHandle& operator=(const FileHandle&) = delete;
    FileHandle(FileHandle&&) noexcept = default;
    FILE* get() const { return f_; }
private:
    FILE* f_;
};
```

## Builder Pattern (for complex initialization)
```cpp
class ServerConfig {
public:
    ServerConfig& port(int p) { port_ = p; return *this; }
    ServerConfig& threads(int t) { threads_ = t; return *this; }
    Server build() const { return Server{port_, threads_}; }
private:
    int port_ = 8080;
    int threads_ = 4;
};
// Usage: auto server = ServerConfig{}.port(9090).threads(8).build();
```

## Strategy Pattern
```cpp
class Sorter {
public:
    using Strategy = std::function<void(std::vector<int>&)>;
    explicit Sorter(Strategy s) : strategy_(std::move(s)) {}
    void sort(std::vector<int>& v) { strategy_(v); }
private:
    Strategy strategy_;
};
```

## Observer (with weak_ptr to avoid leaks)
- Store observers as `std::weak_ptr<Observer>`; lock before notifying
- Use signal/slot libraries (Boost.Signals2) for complex event systems

## Template Policies
- Separate what varies (policy) from what stays (mechanism)
- Use concepts (C++20) to constrain templates: `template<std::integral T>`
