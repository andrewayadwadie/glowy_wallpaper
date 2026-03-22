# Auth API Contracts

**Feature**: 002-auth-user-profile
**Date**: 2026-03-20

## POST /auth/register

**Purpose**: Create a new user account.

**Request**:
```json
{
  "display_name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass1"
}
```

**Response 201 (Created)**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "usr_abc123",
    "display_name": "John Doe",
    "email": "john@example.com",
    "is_premium": true
  }
}
```

**Response 409 (Conflict)**: Email already in use.
```json
{
  "error": "email_already_in_use",
  "message": "Email already in use"
}
```

**Response 422 (Validation Error)**: Invalid input.
```json
{
  "error": "validation_error",
  "message": "Password must be at least 8 characters"
}
```

---

## POST /auth/login

**Purpose**: Authenticate an existing user.

**Request**:
```json
{
  "email": "john@example.com",
  "password": "SecurePass1"
}
```

**Response 200 (OK)**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "usr_abc123",
    "display_name": "John Doe",
    "email": "john@example.com",
    "is_premium": true
  }
}
```

**Response 401 (Unauthorized)**: Invalid credentials.
```json
{
  "error": "invalid_credentials",
  "message": "Invalid email or password"
}
```

---

## POST /auth/logout

**Purpose**: Invalidate the current auth token server-side.

**Headers**: `Authorization: Bearer <token>`

**Request**: Empty body.

**Response 200 (OK)**:
```json
{
  "message": "Logged out successfully"
}
```

**Response 401 (Unauthorized)**: Token already invalid — client still clears local session.

---

## GET /subscription/status

**Purpose**: Validate token and return current subscription status. Used on app launch.

**Headers**: `Authorization: Bearer <token>`

**Response 200 (OK)**:
```json
{
  "is_premium": true
}
```

**Response 401 (Unauthorized)**: Token expired or revoked — client clears token, user becomes guest.

---

## POST /subscription/unsubscribe

**Purpose**: Cancel premium subscription immediately.

**Headers**: `Authorization: Bearer <token>`

**Request**: Empty body.

**Response 200 (OK)**:
```json
{
  "is_premium": false,
  "message": "Subscription cancelled successfully"
}
```

**Response 401 (Unauthorized)**: Token invalid.

---

## Common Error Format

All error responses follow this structure:
```json
{
  "error": "error_code",
  "message": "Human-readable error message"
}
```

## Auth Header Convention

All authenticated endpoints require:
```
Authorization: Bearer <token>
```

The `AuthInterceptor` (already implemented in Phase 1) automatically attaches this header and handles 401 responses by clearing the stored token.
