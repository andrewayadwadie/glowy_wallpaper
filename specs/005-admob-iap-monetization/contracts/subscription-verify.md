# Contract: Subscription Verification API

**Direction**: Client → Backend
**Protocol**: REST over HTTPS

## POST /subscription/verify

Validates a platform purchase receipt and returns the verified subscription status.

### Request

```
POST /api/v1/subscription/verify
Content-Type: application/json
Authorization: Bearer {token}
```

**Body**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `platform` | string | yes | `android` or `ios` |
| `productId` | string | yes | Store product identifier (e.g., `premium_monthly`) |
| `purchaseToken` | string | yes | Google Play purchase token or Apple transaction ID |
| `receiptData` | string | no | Apple receipt data (base64); omit for Android |

### Response — Success (200)

```json
{
  "success": true,
  "data": {
    "status": "premium",
    "productId": "premium_monthly",
    "expiryDate": "2026-04-24T00:00:00.000Z",
    "autoRenewing": true
  },
  "message": "Subscription verified"
}
```

### Response — Invalid Receipt (400)

```json
{
  "success": false,
  "data": null,
  "message": "Invalid purchase token"
}
```

### Response — Expired Subscription (200)

```json
{
  "success": true,
  "data": {
    "status": "free",
    "productId": "premium_monthly",
    "expiryDate": "2026-03-01T00:00:00.000Z",
    "autoRenewing": false
  },
  "message": "Subscription expired"
}
```

### Client Behavior

| Scenario | Action |
|----------|--------|
| 200 + `status: premium` | Grant premium, cache as `verified`, store `expiryDate` |
| 200 + `status: free` | Revert to free tier, clear cached subscription |
| 400 | Mark receipt as `unverified`, keep free tier |
| 5xx / timeout / network error | Grant premium optimistically, cache as `pending`, re-verify on next cold start |

---

## GET /subscription/status

Checks current subscription status for the authenticated user. Called on cold start.

### Request

```
GET /api/v1/subscription/status
Authorization: Bearer {token}
```

### Response (200)

```json
{
  "success": true,
  "data": {
    "status": "premium",
    "productId": "premium_yearly",
    "expiryDate": "2027-03-24T00:00:00.000Z",
    "autoRenewing": true
  },
  "message": "Subscription status retrieved"
}
```

### Client Behavior

| Scenario | Action |
|----------|--------|
| 200 + `status: premium` | Update cache, set `SubscriptionCubit` to premium |
| 200 + `status: free` | Clear cache, set `SubscriptionCubit` to guest |
| Network error | Fall back to cached premium flag (7-day TTL) |
