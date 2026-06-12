# Contract: AnchoredAdaptiveBanner (widget)

`lib/core/ads/widgets/anchored_adaptive_banner.dart` — `StatefulWidget`. Replaces `BannerAdWidget`.

Self-contained anchored adaptive banner for the Home bottom slot. Owns its own `BannerAd` lifecycle.

## API

```dart
class AnchoredAdaptiveBanner extends StatefulWidget {
  const AnchoredAdaptiveBanner({super.key});
}
```

Embedded as `Scaffold.bottomNavigationBar` on Home (premium ⇒ not embedded / collapses).

## Behavioral contract

| State | Render |
|---|---|
| premium (`SubscriptionPremium`) | `SizedBox.shrink()` (no slot) |
| resolving size / loading | reserved slot `AppDimens.bannerSlotFallbackHeight` (no jump) |
| loaded | slot sized to resolved `AdSize.height`, hosts `AdWidget` |
| load failed (after 1 retry) | `SizedBox.shrink()` (collapse, FR-012) |

Lifecycle:
- `initState` → resolve `AdSize.getAnchoredAdaptiveBannerAdSize(portrait, screenWidthTrunc)`, build `BannerAd`, `load()`.
- one retry on failure, then collapse.
- `dispose()` → `_bannerAd?.dispose()` (FR-013, Principle VI).
- never overlaps grid: lives in `bottomNavigationBar`, grid is body (FR-011, SC-004).

Constraints: no inlined colors/sizes — fallback height from `AppDimens`; premium check via `BlocBuilder<SubscriptionCubit>`.

## Tests (widget)
- premium ⇒ shrink.
- load failure ⇒ shrink (no grey box).
- (manual/integration) loaded ⇒ slot matches adaptive height; grid not covered.
