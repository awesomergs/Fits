# Fits — Tasks

Hour-blocked milestones with acceptance criteria. P0 = demo-critical, P1 = nice to have, P2 = do not build.

Always work top-to-bottom. Don't skip ahead even if a later task seems more interesting — the dependency order matters.

---

## Block 1: Foundation (Hours 0–3)

### 1.1 [P0] Xcode project setup
- Create `Fits.xcodeproj`, SwiftUI App lifecycle, iOS 17.0 minimum deployment target
- Add `.gitignore` (standard Swift template + `Secrets.swift`)
- Initialize git repo, first commit

### 1.2 [P0] Supabase project
- Create project in Supabase dashboard
- Run the schema SQL from `ARCHITECTURE.md` in the SQL editor
- Create `clothing` and `avatars` storage buckets, both public
- Add storage policies: authenticated INSERT, public SELECT
- **Verify** RLS is enabled on all 5 tables (Authentication → Policies)

### 1.3 [P0] Add dependencies
- File → Add Package Dependencies → `supabase-swift` (lock to a specific minor version)
- Build, confirm it compiles

### 1.4 [P0] Secrets + service singleton
- Create `Secrets.swift` (gitignored) with `supabaseURL` and `supabaseAnonKey`
- Implement `SupabaseService.shared` per ARCHITECTURE.md skeleton
- Implement `Color+Fits.swift` and `Font+Fits.swift` design tokens

### 1.5 [P0] Auth flow
- Implement Apple Sign In OR magic link in `AuthService`
- `RootView` shows sign-in if `currentUserId == nil`, otherwise `TabBar`
- After first sign-in, prompt for `username` and `handle` → insert `profiles` row

### 1.6 [P0] Tab bar
- 5 tabs: Feed, Find, Tag, Closet, Profile (Tag is center)
- Each tab is a stub view with placeholder text and tab icon (SF Symbols)
- Use `FitsTheme.primary` as the tab tint color

**Block 1 acceptance:** Sign in works. You see all 5 tabs. Switching between them shows their stubs.

---

## Block 2: Tag flow — the magic moment (Hours 3–8)

### 2.1 [P0] Background removal service
- Implement `BackgroundRemovalService.cutout(from:)` exactly as in ARCHITECTURE.md
- Critically: graceful fallback to raw image on failure — never throw to caller

### 2.2 [P0] TagView UI
- Big "+" placeholder when no image picked
- `PhotosPicker(selection:matching: .images)` integration
- After pick: show cutout (or raw) at full width
- Category `Picker` (menu style) with all `ItemCategory` cases
- Wishlist `Toggle`
- Save button (disabled until cutout/raw image is loaded)

### 2.3 [P0] Save action with optimistic insert
- On save: convert image to PNG `Data`
- Upload to `clothing` bucket via `uploadItemImage(_:)`
- Insert `clothing_items` row with returned URL
- Reset TagView to empty state, show success toast

### 2.4 [P0] Verify end-to-end
- Pick photo from simulator's library (drag images in via Finder first if empty)
- Cutout displays in <500ms
- Tap save → row appears in Supabase dashboard's `clothing_items` table
- Image accessible at the public URL

**Block 2 acceptance:** A new clothing item end-to-end: pick → cutout → save → DB row + storage object.

---

## Block 3: Closet (Hours 8–14)

### 3.1 [P0] ClosetModel
- `@Observable final class ClosetModel`
- `var items: [ClothingItem]`, grouped getter `var byCategory: [ItemCategory: [ClothingItem]]`
- `func load() async` calls `myItems()`

### 3.2 [P0] ClosetView main screen
- Top: `OccasionDropdown` menu (Streetwear, Work, Gala, Casual, Date Night) — drives builder occasion
- Body: scrollable list of category sections, each with horizontal `SlotCarousel`
- Wishlist styling on cards: dashed cherry-blossom border + bookmark icon (see ARCHITECTURE.md "Wishlist visual rule")

### 3.3 [P0] SlotCarousel
- Title + horizontal `ScrollView`
- Each `ItemCard` shows the image with selection state styling (100% opacity selected, 45% otherwise, 1.05× scale on selected)
- Tap to select; selection bound to parent's `picks: [ItemCategory: ClothingItem]`

### 3.4 [P0] OutfitBuilderView (modal or pushed view)
- Same slot-carousel layout but in "build" mode where every category needs a selection
- Sticky bottom Publish button
- On Publish: build `Outfit`, insert via `publishOutfit(_:)`, dismiss

### 3.5 [P0] Verify
- Add 4 items via Tag (one per category)
- Open Closet, see them grouped
- Build an outfit, publish, verify row in `outfits` table with correct `item_ids` array

**Block 3 acceptance:** Build and publish an outfit using items added via Tag.

---

## Block 4: Feed + Steal (Hours 14–20)

### 4.1 [P0] FeedModel
- Fetches recent published outfits via `feed(limit: 20)`
- For each outfit, hydrates `[ClothingItem]` via `itemsByIds(_:)` (single batched query keyed by outfit)
- Hydrates `Profile` per outfit

### 4.2 [P0] FeedCardView
- 2×2 grid of item cutouts (or 1×N if outfit has fewer items)
- Below: occasion pill + caption + comment text field
- Below that: 3 action buttons in a row — ❌ dislike, 👕 Steal this fit, ❤️ like
- Drag gesture: swipe right = like, swipe left = dislike, with fly-off animation and rotation
- Like/dislike state badges visible during drag (the "LIKE"/"NOPE" stamps)

### 4.3 [P0] Like/dislike
- Calls `react(targetType: "outfit", targetId:, kind:)`
- Optimistic: remove card from local feed before write returns

### 4.4 [P0] ⭐ Steal this fit (the differentiator)
- Tap the Steal button → for each item in the outfit, build a new `ClothingItem` with:
  - `id: UUID()` (new)
  - `ownerId: currentUserId`
  - `imageUrl: source.imageUrl` (reuse the same URL)
  - `category: source.category`
  - `isWishlist: true`
  - `sourceItemId: source.id`
- Batch insert via `batchCreateItems(_:)`
- Insert reaction `(target: outfit, kind: .steal)`
- Show toast: "{N} items added to your wishlist"
- Card stays visible but shows a small "Stolen" badge in the corner

### 4.5 [P0] Verify
- Seed user has a published outfit (after Block 5 seeding)
- Open Feed, see card
- Swipe right → reaction row inserted
- Tap Steal → N items appear in your wishlist (visible in Closet)

**Block 4 acceptance:** Full social loop runs: see published outfit → like or steal it → state persists.

---

## Block 5: Seed data + Profile (Hours 20–24)

### 5.1 [P0] Seed script
- Create `Scripts/seed.sql` (or Swift seeding via debug menu)
- Insert 3 demo profiles: `@aria`, `@kai`, `@jules` with `auth.users` rows (you'll need service role for this part — handle securely)
- Use 30+ pre-prepared cutout PNGs of real clothing items, uploaded to `clothing` bucket beforehand
- Insert `clothing_items` referencing those URLs (mix `is_wishlist` true/false)
- Insert 5 published outfits across the 3 accounts
- Insert follow relationships so the demo user follows all 3
- **Curate one outfit specifically as the demo "Steal" target** — make it look great

### 5.2 [P0] Profile view
- Header: avatar (circle, 80pt), username (`fitsHeadline`), handle in muted (`fitsCaption`), follower/following counts
- "See their closet" button (top right)
- 3 sections in scrollable body: Outfits (3-col grid), Recent Items (3-col grid), Favorite Items (placeholder for v1 — show "Coming soon")
- ProfileModel loads outfits and items for the given userId

### 5.3 [P0] Wire up profile navigation
- Tapping any avatar anywhere → push Profile for that user
- Profile of self vs others — for now, identical (no edit affordance, that's P2)

**Block 5 acceptance:** Run seed → fresh install shows populated Feed and viewable demo profiles.

---

## Block 6: Find page (Hours 24–28) [P1 — only if ahead]

### 6.1 [P1] User search
- Capsule search field at top
- Debounced query (300ms) calls `searchProfiles(_:)` (Postgres `ilike` on handle)
- Results list with avatar + handle, tap pushes Profile

### 6.2 [P1] Category rails
- Below search: 2 hardcoded rails ("Tops", "Bottoms")
- Each rail: horizontal scroll of items from `itemsByIds` of a hardcoded curated set
- Tap item → bottom sheet with `Add to wishlist` button

**Block 6 acceptance:** Searching "@aria" finds the demo user. Tapping a Tops item opens detail sheet.

---

## Block 7: Polish (Hours 28–32)

### 7.1 [P0] Empty states
Every screen needs an empty state — never show a blank scroll view:
- Closet empty: "Tag your first item →" with arrow pointing to + tab
- Feed empty: "Follow some people to see their fits" + button
- Profile empty: "No outfits yet"

### 7.2 [P0] Loading states
- Use `ProgressView` or skeleton placeholders during `isLoading`
- Avoid blank flashes on tab switch

### 7.3 [P0] Animations
- Spring on card swipe (already in Feed)
- Spring on selection state change in SlotCarousel
- Fade-in on async images
- Toast slide up from bottom on success/error

### 7.4 [P0] Visual audit
- Grep for hardcoded `Color(red:`, `Color.pink`, `.font(.system(size:` — replace with tokens
- All SF Symbols same weight (`semibold` is house default)
- All cards use the standard shadow

### 7.5 [P0] End-to-end demo run on real device
- Install on physical iPhone
- Run the 90-second demo script start to finish
- Note any glitches — fix them or work around them

---

## Block 8: Demo prep (Hours 32–34)

### 8.1 [P0] Pick the demo shirt
- Test cutout on multiple shirts with simulator/device
- Pick the one that isolates cleanest (solid color + matte fabric beats glossy/patterned)
- Have it physically on hand, ready

### 8.2 [P0] Pre-curate the "Steal" outfit
- This outfit is in seed data — verify it looks great on the Feed card
- Make sure the items are visually cohesive (this becomes the screenshot judges remember)

### 8.3 [P0] Backup recording
- Record full demo flow as a screen capture (QuickTime + iOS device)
- Have it on a laptop ready to play if stage wifi fails
- Practice introducing it: "I'll show the recording in case wifi is unreliable"

### 8.4 [P0] Two devices charged
- One iPhone for "you"
- One iPhone (or simulator on laptop) for "your friend"
- Both charged to 100%
- Both signed into the appropriate demo accounts

---

## Block 9: Rehearse (Hours 34–36)

### 9.1 [P0] Run the pitch out loud, three times
- Time it. Should be 75–90 seconds.
- Record yourself, watch it back, fix awkward beats.

### 9.2 [P0] Identify failure modes
- For each step in the demo, think: what could go wrong here? What's my recovery line?
- Examples:
  - Cutout fails → "It works most of the time — let me try with this other shirt"
  - Upload slow → keep talking about the closet, don't fill silence with apologies
  - Friend device doesn't sync → switch to backup recording

### 9.3 [P0] Sleep
- Better demo + slept brain > marginally more features + zombie brain
- Stop coding by hour 34. Last 2 hours are rehearsal only.

---

## When you finish a block

Run through this checklist before moving on:
- [ ] All P0 acceptance criteria met
- [ ] Committed with a clear message
- [ ] No console errors during the happy path
- [ ] Tested on a real device (or at minimum, verified on simulator)
- [ ] No hardcoded colors/fonts introduced

If anything is broken or sketchy, fix it now — bugs compound across blocks.
