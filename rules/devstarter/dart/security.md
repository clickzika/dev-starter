# Dart Security Rules

## Secrets & Storage
- Never hardcode API keys or tokens in Dart source — use `flutter_dotenv` or environment injection at build time
- Sensitive data at rest: use `flutter_secure_storage` (uses Keychain/Keystore), not SharedPreferences
- Avoid logging sensitive values: `print(user.token)` is a security risk in production

## Network
- Use HTTPS only — disable HTTP cleartext in `AndroidManifest.xml` and `Info.plist`
- Certificate pinning for high-security apps: use `http_certificate_pinning` or custom `HttpClient`
- Validate SSL: never set `badCertificateCallback: (_, __, ___) => true` in production

## Input Validation
- Validate all user input before processing — do not trust form data without sanitization
- Use `Uri.parse()` for URLs then validate scheme before loading — prevent open redirect
- Sanitize HTML content before rendering in `webview_flutter`

## Authentication
- Store auth tokens in `flutter_secure_storage`, never in SharedPreferences (unencrypted)
- Implement token refresh — short-lived access tokens (15m), refresh tokens in secure storage
- Biometric auth: use `local_auth` package; always have a fallback PIN

## Platform Channels
- Validate all data received from platform channels — treat as untrusted input
- Do not expose sensitive methods via MethodChannel to JavaScript in WebView
