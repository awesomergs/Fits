# Fits

> Social apps show outfits. Shopping apps sell clothes. Fits connects the two — through your real closet.

Fits is an iOS app built in 36 hours at a hackathon. It lets you photograph physical clothing items, automatically removes the background using on-device ML, and builds a digital closet. From there you can assemble outfits, publish them to a feed, and let friends "steal" your look — adding all your items to their wishlist in one tap.

## Demo Loop

**Tag a real shirt → cutout appears in closet → build a fit → publish → friend swipes right → "Steal this fit" → all items added to their wishlist**

## Features

- **Tag** — Pick a photo, remove the background with on-device VisionKit, select a category, save to closet or wishlist
- **Closet** — Browse your items by category (tops, bottoms, outerwear, shoes, accessories) or view them on a paper-doll avatar
- **Outfit Builder** — Assemble items from each category slot, choose an occasion, and publish
- **Feed** — Swipe through outfits from people you follow; like, dislike, or steal the whole look
- **Steal This Fit** — One tap copies every item in an outfit to your wishlist
- **Profile** — View published outfits and recent items; see follower/following stats
- **Find** — Search for users by handle

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9+ |
| UI | SwiftUI (iOS 17+) |
| Background Removal | VisionKit `VNGenerateForegroundInstanceMaskRequest` |
| Image Processing | Vision + CoreImage (HSV skin-tone removal) |
| Photos | PhotosUI PhotosPicker |
| State Management | `@Observable` final classes |
| Database | Supabase Postgres (mocked in current build) |
| Auth | Supabase Auth — Apple Sign In / magic link (mocked) |
| Storage | Supabase Storage (mocked) |

## Requirements

- Xcode 15+
- iOS 17.0+ device or simulator (iPhone 15 Pro recommended)
- No third-party packages — everything uses system frameworks

## Getting Started

1. Clone the repo
2. Open `Fits.xcodeproj` in Xcode
3. (Optional) Create `Fits/Secrets.swift` to wire up Supabase:
   ```swift
   enum Secrets {
       static let supabaseURL = "https://<your-project>.supabase.co"
       static let supabaseAnonKey = "YOUR_ANON_KEY"
   }
   ```
4. Select the iPhone 15 Pro simulator and press ⌘R

Without `Secrets.swift` the app runs entirely on `MockStore` — 7 demo profiles, 50+ seeded items, and 10+ outfits, so the full demo loop works out of the box.

## Project Structure

```
Fits/
├── App/                      — Entry point and root routing
├── Features/
│   ├── Auth/                 — Sign in (mocked)
│   ├── Feed/                 — Outfit feed with swipe reactions
│   ├── Find/                 — User search
│   ├── Tag/                  — Photo → cutout → closet flow
│   ├── Closet/               — Closet shelves, outfit builder, avatar try-on
│   └── Profile/              — User profile and stats
├── Services/
│   ├── AuthService.swift     — Auth facade (mocked)
│   ├── ImageUploadService.swift
│   └── MockStore.swift       — All demo data and in-memory state
├── Models/                   — Codable structs: Profile, ClothingItem, Outfit, Reaction
├── DesignSystem/             — Color tokens, font sizes, shared components
└── TabBarView.swift          — 5-tab navigation (Tag as center +)
```

## Architecture

One `@Observable final class` per screen (`FeedModel`, `ClosetModel`, etc.) owned directly by the view. No global store abstraction — models call `MockStore` directly. Async/await throughout with `.task` modifiers for lifecycle binding.

Background removal never fails the user: VisionKit foreground detection followed by HSV-based skin-tone filtering, with a silent fallback to the original image if anything goes wrong.

## Design System

**Colors:** dusty mauve · powder petal · alabaster grey · pastel pink · cherry blossom  
**Typography:** SF Pro at 4 sizes (title/headline/body/caption)  
**Spacing:** multiples of 4pt  
**Corner radius:** 16 (cards) · 12 (buttons) · capsule (pills)

## Supabase Schema (planned)

Tables: `profiles`, `clothing_items`, `outfits`, `reactions`, `follows`  
Storage buckets: `clothing` (item cutout PNGs), `avatars`  
RLS: public read on profiles/items/reactions, self-write only

## Team Members:

Rohan George

Pranet Jagtap

Rachit Kumar

Gautham Gopinath
