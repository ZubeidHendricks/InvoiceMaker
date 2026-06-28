# InvoiceMaker

Generated from niche `invoice-maker` (Finance, tier A, score 76).

**Utility:** Create/send invoices and estimates
**Primary ASO keyword:** `invoice maker`
**Also target:** `invoice generator`, `estimate maker`, `billing`, `receipt maker`
**Paywall hook:** Unlimited invoices, logo/branding, PDF, tracking

> Freelancer/trades pay readily. No API cost. Strong B2B intent.

## Build it

```bash
brew install xcodegen        # once
cd InvoiceMaker
xcodegen generate
open InvoiceMaker.xcodeproj
```

The app runs immediately on a MockPurchaseProvider (real paywall UI, fake
purchases). To go live:

1. Replace `revenueCatKey` in `Sources/App.swift` with your RevenueCat key.
2. In App Store Connect create products `invoice-maker_yearly` and `invoice-maker_weekly`,
   map them into a RevenueCat offering, entitlement id `premium`.
3. Build the real feature in `Sources/ContentView.swift`.
4. **Guideline 4.3:** make the function, UI, screenshots and keywords genuinely
   distinct from any sibling app. Re-niche, never reskin.

Bundle id: `com.zubeid.invoicemaker`

## Ship to TestFlight

This app ships with a Fastlane lane + GitHub Actions workflow. One-time account
setup (API key, signing) is documented in the kit's `Tools/appgen/DEPLOYMENT.md`.
Once your GitHub secrets are set, trigger the **TestFlight** workflow (or push a
`v*` tag), or run locally:

```bash
bundle install
bundle exec fastlane beta
```
