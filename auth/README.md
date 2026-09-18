# Optional auth headers

Implement auth headers for HTTP endpoint POST notifications/SMS.

## Types
- None (current)
- Bearer token
- API key (custom header)
- Basic auth (user+password)

## Storage
EncryptedDataStore / Android Keystore
- bearer token
- API key + header name
- user+password

## HTTP client
Add headers to POST:
- Bearer: Authorization: Bearer <token>
- API key: <Header-Name>: <API-Key>
- Basic: Authorization: Basic <base64(user:password)>

## UI
Auth section in endpoint configuration:
- Dropdown/SegmentedButton: None | Bearer | API key | Basic
- Dynamic fields:
  - Bearer: Token
  - API key: Header name + API key
  - Basic: User + Password
- Eye icon to toggle visibility
- Basic validation

## Compatibility
Maintain backward compatibility: no auth config = None.

## Error handling
401/403 -> "Authentication failed - check credentials"

## Tests
- Auth works
- 401/403 handling
- Retry/backoff

## Deliverables
- Dart code: models/settings, UI, HTTP logic
- Optional Kotlin adjustments (storage)
- README/AUTH.md examples for ntfy self-hosted

