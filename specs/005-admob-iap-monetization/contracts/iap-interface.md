# Contract: In-App Purchase Interface

**Direction**: Internal (presentation layer → IAP data source → in_app_purchase plugin → platform store)
**Pattern**: Clean Architecture data source wrapping platform SDK

## PremiumRepository Contract (Domain Layer)

```
getProducts() → Future<Either<Failure, List<PremiumProductEntity>>>
  Fetches available subscription products (monthly + yearly) from the platform store.
  Returns typed product list with localized prices.

purchasePremium(PremiumProductEntity product) → Future<Either<Failure, SubscriptionEntity>>
  Initiates native purchase flow for the selected product.
  Listens for purchase completion.
  Verifies receipt server-side via POST /subscription/verify.
  Returns updated subscription entity.

restorePurchases() → Future<Either<Failure, SubscriptionEntity>>
  Triggers platform restore flow.
  Re-verifies each restored transaction server-side.
  Returns subscription entity if active subscription found.

getSubscriptionStatus() → Future<Either<Failure, SubscriptionEntity>>
  Checks current status via GET /subscription/status.
  Updates local cache.

getCachedSubscription() → Future<Either<Failure, SubscriptionEntity>>
  Returns locally cached subscription state from Hive.
  Checks 7-day TTL.
```

## Purchase Flow Sequence

```
User taps "Subscribe Now"
  │
  ├─► PremiumCubit.purchase(product)
  │     ├─► IAPDataSource.buySubscription(productId)
  │     │     └─► InAppPurchase.instance.buyNonConsumable(purchaseParam)
  │     │           └─► Platform payment sheet shown
  │     │
  │     ├─► [Purchase stream emits PurchaseDetails]
  │     │     ├─► status == purchased
  │     │     │     ├─► PremiumRemoteSource.verifyReceipt(token, platform)
  │     │     │     │     ├─► Success → cache as verified, emit premium
  │     │     │     │     └─► Error → cache as pending, emit premium (optimistic)
  │     │     │     └─► InAppPurchase.instance.completePurchase(details)
  │     │     │
  │     │     ├─► status == pending
  │     │     │     └─► Emit pending state, do not grant premium
  │     │     │
  │     │     └─► status == error
  │     │           └─► Emit error, remain on free tier
  │     │
  │     └─► Update SubscriptionCubit → premium / guest
  │
  └─► AdHelper reacts to SubscriptionCubit change → hides all ads
```

## Restore Flow Sequence

```
User taps "Restore Purchase"
  │
  ├─► PremiumCubit.restore()
  │     ├─► InAppPurchase.instance.restorePurchases()
  │     ├─► [Purchase stream emits restored PurchaseDetails]
  │     │     ├─► For each restored purchase:
  │     │     │     ├─► Verify receipt server-side
  │     │     │     └─► If verified + active → cache, emit premium
  │     │     └─► If no restorable purchases → emit "no subscription found"
  │     └─► Update SubscriptionCubit
  │
  └─► AdHelper reacts → hides all ads (if premium restored)
```

## Error States

| Error | User-Facing Message | Recovery |
|-------|---------------------|----------|
| Store unavailable | "Store unavailable. Please try again later." | Retry button |
| Purchase cancelled by user | No message (silent dismiss) | Return to Get Premium |
| Payment declined | "Payment was declined. Please try another payment method." | Retry button |
| Verification server error | Silent (optimistic grant) | Re-verify on next cold start |
| No products found | "Subscription options are temporarily unavailable." | Retry button |
| Restore — no active subscription | "No active subscription found for this account." | Dismiss |
