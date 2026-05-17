# Perl Coding Rules

## Safety Basics
- Always `use strict; use warnings;` at the top of every script and module
- Use `use feature 'say';` instead of `print` with newline
- Enable `use utf8;` and `use open ':std', ':encoding(UTF-8)';` for Unicode-safe code
- Never use `$_` implicitly in complex contexts — name your variables

## Style
- Use `my` for all variable declarations — never rely on globals except `$0`, `@ARGV`
- Prefer `say` over `print`; use `printf` for formatted output
- Use `unless`/`until` sparingly — `if !` is usually clearer
- Indent with 4 spaces; keep lines under 100 chars

## References & Data Structures
- Use references for complex data structures (arrayrefs, hashrefs, coderefs)
- Dereference explicitly: `@{$aref}`, `%{$href}` — not `@$aref` in ambiguous contexts
- Use `Storable::dclone` for deep copying data structures
- Prefer `List::Util` (reduce, sum, max, any, all) over manual loops

## Modules
- One package per file; file path matches package name
- Use `Exporter` for explicit exports — never `@EXPORT` without intentional design
- Use `Moo` or `Moose` for OO code; avoid bless-based OO without a framework
- Use CPAN modules rather than reinventing: `Path::Tiny`, `HTTP::Tiny`, `JSON::MaybeXS`

## Testing
- Use `Test::More` or `Test2::V0` for all tests
- Name test files `t/*.t`; run with `prove -l t/`
- Test both happy path and error cases
- Use `Test::Exception` to assert exception types and messages
