# CLAUDE.md

Read this first every session. It encodes decisions you should not relitigate.

## Project

**Fits** — iOS app where users build outfits from a real digital closet and get feedback from friends. 36-hour hackathon project. See `PRD.md` for product spec, `ARCHITECTURE.md` for technical design, `TASKS.md` for milestone ordering.

## Sacred constraint

The 90-second demo loop is sacred. Read the demo script in `PRD.md` and never lose sight of it. Anything that doesn't serve that demo is P2 and should not be built.

The demo loop:
**Tag a real shirt → cutout appears → in closet → build a fit → publish → friend swipes right → friend taps "Steal this fit" → all items in their wishlist.**

If you find yourself doing work that doesn't make one of those steps work or look better, stop and ask.

## Stack (locked, do not change without asking)

- **iOS 17.0+ minimum** (VisionKit foreground mask requires 17)
- **SwiftUI only** — no UIKit unless wrapping a system feature SwiftUI doesn't expose (e.g., `PHPickerViewController` if `PhotosPicker` doesn't suffice)
- Swift 5.9+, async/await everywhere, no completion handlers
- `@Observable` macro (iOS 17), not `ObservableObject`
- **Supabase** via `supabase-swift` (Swift Package Manager)
- **No third-party background-removal API** — VisionKit replaces it
- **No additional dependencies without checking with the human first**

## File organization

```
Fits/
├── App/                 — FitsApp, RootView, TabBar
├── Features/            — One folder per tab: Feed, Find, Tag, Closet, Profile
├── Services/            — SupabaseService, AuthService, ImageUploadService
├── Models/              — Codable structs only, zero business logic
└── DesignSystem/        — Color+Fits, Font+Fits, shared components
```

Each feature folder owns its views and view model. Don't share view models across features.

## Code conventions

- View models are `@Observable final class`, named with `Model` suffix (`FeedModel`, `ClosetModel`)
- Services are singletons via `.shared` for the hackathon — yes, I know
- Use `.task { ... }` view modifier for async work tied to view lifecycle, not bare `Task { ... }` in `onAppear`
- `AsyncImage` always has a placeholder — never blank gaps in scrolling lists
- All Codable structs need explicit `CodingKeys` for snake_case ↔ camelCase
- Configure `JSONDecoder` with `.iso8601` date strategy (with fractional second support — see ARCHITECTURE.md)
- Use design tokens (`FitsTheme.primary`, `Font.fitsBody`) — never hardcode colors or fonts in views
- Spring animations: `.spring(response: 0.3, dampingFraction: 0.75)` is the house default

## Things that will bite you (re-read every session)

1. **RLS policies are the silent killer.** If a Supabase query returns empty unexpectedly, check policies before anything else. Always.
2. **PhotosPicker on simulator** — the simulator's Photos library is empty by default. Drag images in via Finder before testing Tag.
3. **Date decoding** — Supabase returns ISO8601 with fractional seconds. The default `.iso8601` strategy doesn't handle fractional seconds; use the custom decoder in `ARCHITECTURE.md`.
4. **VisionKit `@available(iOS 17, *)`** — even though we target 17, the API still requires the availability attribute on every call site.
5. **Supabase Swift SDK signatures shift across minor versions.** Don't trust autocomplete blindly; verify against the installed version's README.
6. **AsyncImage doesn't cache.** Fine for the demo, but if scrolling stutters, that's why.
7. **Optimistic UI is non-negotiable.** Never block the user on a network round-trip. See ARCHITECTURE.md "Optimistic UI patterns".
8. **Cutout can fail** (no detected subject). The Tag flow must continue with the raw image. Never error out the user.

## What to always do

- Add a SwiftUI `#Preview` for every view you create — preview-driven dev is 10× the build/run loop
- Wrap Supabase calls in `do/catch` with a `print` on failure (we'll lose the print logs but at least we'll see them in dev)
- Commit after every working milestone
- When in doubt about scope, ask — don't add screens or tabs unilaterally

## What to never do

- **Don't add tabs.** The 4-tab + center-Tag-button structure is final.
- **Don't refactor file structure mid-build.**
- **Don't introduce screens not in the PRD without asking.**
- **Don't write tests during the hackathon.** The demo is the test.
- **Don't fight RLS by disabling it.** Fix the policy.
- **Don't make the demo flow depend on network round-trips that can fail or stall.** Optimistic UI.

## Secrets

Create `Fits/Secrets.swift` (gitignored) with:

```swift
enum Secrets {
    static let supabaseURL = "https://YOUR-PROJECT.supabase.co"
    static let supabaseAnonKey = "YOUR_ANON_KEY"
}
```

Add `Secrets.swift` to `.gitignore` before first commit.

## How to run

- Open `Fits.xcodeproj` in Xcode 15+
- Pick iPhone 15 Pro simulator (or a real iOS 17+ device — preferred for VisionKit testing)
- ⌘R

## Debug order when stuck

When something doesn't work, check in this order:

1. Is the user authenticated? (`SupabaseService.shared.currentUserId` non-nil?)
2. Is RLS allowing the query? Inspect in Supabase dashboard's SQL editor as the auth user.
3. Is date decoding failing silently? Print the raw response.
4. Is the SDK signature different from what's in this repo? Check the installed version.
5. Is iOS 17 actually being targeted? Check Project → Deployment Info.

## Working with the human

- The human has the whiteboard sketch (`IMG_0578.jpg`) — refer to it when in doubt about layout intent.
- Push back if a request would compromise the demo loop. Be opinionated.
- If you're about to spend more than 30 minutes on something, sanity-check with the human first.
