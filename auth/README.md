# Auth Headers Implementation

Implement optional HTTP auth headers for endpoint POST notifications/SMS.

Types: None, Bearer, API key, Basic auth.

Secure storage: EncryptedDataStore / Android Keystore.

UI: Settings screen with dynamic fields and eye icons.

Backward compatible with existing 'None' auth.

Tests: Retry/backoff, 401/403 handling, secure storage.