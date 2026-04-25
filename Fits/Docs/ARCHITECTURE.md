# Fits — Architecture

## Stack

| Layer | Choice | Why |
|---|---|---|
| UI | SwiftUI, iOS 17+ | Native, fast iteration via Previews, `@Observable` |
| Auth | Supabase Auth (Apple Sign In or magic link) | One-line setup, no password UX to build |
| DB | Supabase Postgres | Relational fits the closet→outfit→items model |
| Storage | Supabase Storage | Public buckets for cutout PNGs |
| ML | VisionKit `VNGenerateForegroundInstanceMaskRequest` | On-device, free, ~200ms, no API key |
| Realtime | Supabase Realtime | Optional — for live reactions on demo, only if time permits |

## Information architecture

4 tabs + center-button create:

```
[ Feed ] [ Find ] [ + Tag ] [ Closet ] [ Profile ]
   ⌂        🔍        ⊕         👔          👤
```

Tag is the center "+", matching Instagram/TikTok mental models for "create".

## Data model

### Schema

```sql
-- ============= ENUMS =============
create type item_category as enum (
  'top', 'bottom', 'outerwear', 'shoes', 'accessory', 'full_body'
);
create type reaction_kind as enum ('like', 'dislike', 'comment', 'steal');
create type target_kind as enum ('outfit', 'item');

-- ============= TABLES =============

-- 1:1 with auth.users
create table public.profiles (
  id uuid primary key references auth.users on delete cascade,
  username text unique not null,
  handle text unique not null,
  avatar_url text,
  bio text,
  created_at timestamptz default now()
);

-- Closet + wishlist + stolen items all live here
create table public.clothing_items (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  image_url text not null,
  category item_category not null,
  occasion_tags text[] default '{}',
  is_wishlist boolean default false,
  source_item_id uuid references public.clothing_items(id) on delete set null,
  source_shop text,
  source_url text,
  created_at timestamptz default now()
);

-- A curated set of items for an occasion
create table public.outfits (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  occasion text not null,
  item_ids uuid[] not null,
  caption text,
  published boolean default false,
  created_at timestamptz default now()
);

-- Likes, dislikes, comments, steals
create table public.reactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  target_type target_kind not null,
  target_id uuid not null,
  kind reaction_kind not null,
  comment text,
  created_at timestamptz default now(),
  unique (user_id, target_type, target_id, kind)
);

create table public.follows (
  follower_id uuid not null references public.profiles(id) on delete cascade,
  following_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (follower_id, following_id),
  check (follower_id <> following_id)
);
```

### Indexes

```sql
create index on public.clothing_items (owner_id, category);
create index on public.clothing_items (owner_id, is_wishlist);
create index on public.clothing_items (source_item_id);
create index on public.outfits (owner_id, published);
create index on public.outfits (created_at desc) where published = true;
create index on public.reactions (target_type, target_id);
create index on public.follows (follower_id);
create index on public.follows (following_id);
```

### RLS policies

```sql
alter table public.profiles enable row level security;
alter table public.clothing_items enable row level security;
alter table public.outfits enable row level security;
alter table public.reactions enable row level security;
alter table public.follows enable row level security;

-- Profiles: public read, self write
create policy "profiles_read_all" on public.profiles for select using (true);
create policy "profiles_insert_self" on public.profiles for insert with check (auth.uid() = id);
create policy "profiles_update_self" on public.profiles for update using (auth.uid() = id);

-- Items: public read (profiles are public per PRD), self write
create policy "items_read_all" on public.clothing_items for select using (true);
create policy "items_write_self" on public.clothing_items for all
  using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

-- Outfits: published readable by all; drafts only self
create policy "outfits_read" on public.outfits for select
  using (published = true or auth.uid() = owner_id);
create policy "outfits_write_self" on public.outfits for all
  using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

-- Reactions: public read, self write
create policy "reactions_read_all" on public.reactions for select using (true);
create policy "reactions_write_self" on public.reactions for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Follows: public read, self write
create policy "follows_read_all" on public.follows for select using (true);
create policy "follows_write_self" on public.follows for all
  using (auth.uid() = follower_id) with check (auth.uid() = follower_id);
```

### Storage buckets

In Supabase dashboard:
- `clothing` — public bucket for cutout PNGs
- `avatars` — public bucket for profile pictures

Policy on each: authenticated users can `INSERT`, `SELECT` is public.

## Key flows

### Flow: Tag → Closet (the magic moment)

```
PhotosPicker
   │
   ▼
loadTransferable(Data) → UIImage
   │
   ▼
BackgroundRemovalService.cutout(image)
   │
   ├── success → cutout UIImage
   └── failure → raw UIImage (silent fallback, optional toast)
   │
   ▼
User picks category + wishlist toggle
   │
   ▼
[OPTIMISTIC] Insert local ClothingItem with placeholder URL into ClosetModel
   │
   ▼
Upload PNG to Storage `clothing/items/{uuid}.png`
   │
   ▼
Insert clothing_items row with public URL
   │
   ▼
Reconcile local item by id (replace placeholder URL with real URL)
```

The user sees the new item in their closet **before** the upload completes. Network failures during upload should not block the UI; they should show a small retry banner.

### Flow: Compose → Publish

1. `ClosetView` → tap "Build a fit" → push `OutfitBuilderView`
2. Builder holds `@State picks: [ItemCategory: ClothingItem]`
3. User picks occasion from dropdown menu
4. Each `SlotCarousel` filters `items` by its category and writes to `picks[category]`
5. Tap Publish → construct `Outfit(itemIds: picks.values.map(\.id), occasion:, published: true)`
6. Insert outfit row, dismiss to ClosetView (or pop to Feed if you want to show the result immediately)

### Flow: Feed swipe + Steal

1. `FeedModel.load()` fetches recent published outfits, joined with their items and the publisher's profile
2. `FeedCardView` displays outfit grid + caption + comment field + 3 actions (dislike / steal / like)
3. **Swipe right** → animate card off-screen, then `react(outfitId, kind: .like)`
4. **Swipe left** → animate card off-screen, then `react(outfitId, kind: .dislike)`
5. **Tap Steal** ⭐:
   - For each `item_id` in `outfit.itemIds`, insert a new `clothing_items` row owned by current user, with `image_url` and `category` copied from source, `is_wishlist = true`, `source_item_id = original_id`
   - Insert reaction `(target: outfit, kind: steal)`
   - Show toast: "N items added to your wishlist"
   - Mark card as stolen (small badge corner)

The Steal action is a single batched RPC if you want — or N inserts wrapped in a single Supabase function. Either way, must feel instant.

## Background removal — must not fail the user

```swift
@available(iOS 17, *)
enum BackgroundRemovalService {
    /// Returns a cutout if possible, otherwise returns the original image.
    /// Never throws — the Tag flow must never be blocked by this.
    static func cutout(from image: UIImage) async -> UIImage {
        do { return try await performCutout(image) }
        catch { return image }
    }

    private static func performCutout(_ image: UIImage) async throws -> UIImage {
        guard let cg = image.cgImage else { return image }
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cg)
        try handler.perform([request])
        guard let result = request.results?.first else { return image }
        let masked = try result.generateMaskedImage(
            ofInstances: result.allInstances,
            from: handler,
            croppedToInstancesExtent: true
        )
        let ci = CIImage(cvPixelBuffer: masked)
        guard let out = CIContext().createCGImage(ci, from: ci.extent) else { return image }
        return UIImage(cgImage: out)
    }
}
```

Robust > perfect. Graceful degradation > demo failure.

## Design system

### Color tokens

| Role | Hex | Token | Usage |
|---|---|---|---|
| Background | `#FFE5D9` | `FitsTheme.background` | App background, large surfaces |
| Surface | `#FFFFFF` | `FitsTheme.surface` | Cards, sheets |
| Muted | `#D8E2DC` | `FitsTheme.muted` | Dividers, placeholders, disabled states |
| Highlight | `#FFCAD4` | `FitsTheme.highlight` | Selected pills, soft accents |
| Accent | `#F4ACB7` | `FitsTheme.accent` | Wishlist border, like state, secondary CTAs |
| Primary | `#9D8189` | `FitsTheme.primary` | Primary text, primary buttons, top bars |

```swift
import SwiftUI

extension Color {
    static let alabasterGrey = Color(hex: "D8E2DC")
    static let powderPetal   = Color(hex: "FFE5D9")
    static let pastelPink    = Color(hex: "FFCAD4")
    static let cherryBlossom = Color(hex: "F4ACB7")
    static let dustyMauve    = Color(hex: "9D8189")

    init(hex: String) {
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        self.init(
            red:   Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >>  8) & 0xFF) / 255,
            blue:  Double( rgb        & 0xFF) / 255
        )
    }
}

enum FitsTheme {
    static let background = Color.powderPetal
    static let surface    = Color.white
    static let muted      = Color.alabasterGrey
    static let highlight  = Color.pastelPink
    static let accent     = Color.cherryBlossom
    static let primary    = Color.dustyMauve
}
```

### Typography

SF Pro is iOS default — `Font.system(...)` gets you it free. Don't load custom fonts.

```swift
extension Font {
    static let fitsTitle    = Font.system(size: 28, weight: .bold)
    static let fitsHeadline = Font.system(size: 20, weight: .semibold)
    static let fitsBody     = Font.system(size: 16, weight: .regular)
    static let fitsCaption  = Font.system(size: 13, weight: .medium)
}
```

### Spacing & shape

- Stick to multiples of 4 for spacing: `4, 8, 12, 16, 20, 24`
- Card corner radius: `16`
- Button corner radius: `12` (or `.capsule` for pills)
- Default shadow: `color: .black.opacity(0.06), radius: 12, y: 4`

### Wishlist visual rule (single most important visual)

```swift
.overlay(
    RoundedRectangle(cornerRadius: 12)
        .strokeBorder(
            item.isWishlist ? FitsTheme.accent : .clear,
            style: StrokeStyle(lineWidth: 2, dash: item.isWishlist ? [4] : [])
        )
)
.overlay(alignment: .topTrailing) {
    if item.isWishlist {
        Image(systemName: "bookmark.fill")
            .foregroundStyle(FitsTheme.accent)
            .padding(6)
    }
}
```

## Project structure

```
Fits/
├── App/
│   ├── FitsApp.swift            — @main, configures Supabase
│   ├── RootView.swift           — auth gate + TabBar
│   └── TabBar.swift             — 5-tab TabView with Tag as center +
├── Features/
│   ├── Feed/
│   │   ├── FeedView.swift
│   │   ├── FeedModel.swift
│   │   └── FeedCardView.swift
│   ├── Find/
│   │   ├── FindView.swift
│   │   └── FindModel.swift
│   ├── Tag/
│   │   ├── TagView.swift
│   │   ├── TagModel.swift
│   │   └── BackgroundRemovalService.swift
│   ├── Closet/
│   │   ├── ClosetView.swift
│   │   ├── ClosetModel.swift
│   │   ├── OutfitBuilderView.swift
│   │   ├── SlotCarousel.swift
│   │   └── ItemCard.swift
│   └── Profile/
│       ├── ProfileView.swift
│       └── ProfileModel.swift
├── Services/
│   ├── SupabaseService.swift    — singleton, all DB calls
│   ├── AuthService.swift        — sign in/out
│   └── ImageUploadService.swift — PNG → Storage URL
├── Models/
│   ├── Profile.swift
│   ├── ClothingItem.swift
│   ├── Outfit.swift
│   └── Reaction.swift
├── DesignSystem/
│   ├── Color+Fits.swift
│   ├── Font+Fits.swift
│   └── Components.swift         — PrimaryButton, Pill, Toast
└── Secrets.swift                — gitignored
```

## Models

```swift
struct Profile: Codable, Identifiable, Hashable {
    let id: UUID
    let username: String
    let handle: String
    let avatarUrl: String?
    let bio: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, username, handle, bio
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
    }
}

enum ItemCategory: String, Codable, CaseIterable {
    case top, bottom, outerwear, shoes, accessory
    case fullBody = "full_body"

    var displayName: String {
        switch self {
        case .top:        "Tops"
        case .bottom:     "Bottoms"
        case .outerwear:  "Outerwear"
        case .shoes:      "Shoes"
        case .accessory:  "Accessories"
        case .fullBody:   "Full Body"
        }
    }
}

struct ClothingItem: Codable, Identifiable, Hashable {
    let id: UUID
    let ownerId: UUID
    let imageUrl: String
    let category: ItemCategory
    let occasionTags: [String]
    let isWishlist: Bool
    let sourceItemId: UUID?
    let sourceShop: String?
    let sourceUrl: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, category
        case ownerId       = "owner_id"
        case imageUrl      = "image_url"
        case occasionTags  = "occasion_tags"
        case isWishlist    = "is_wishlist"
        case sourceItemId  = "source_item_id"
        case sourceShop    = "source_shop"
        case sourceUrl     = "source_url"
        case createdAt     = "created_at"
    }
}

struct Outfit: Codable, Identifiable, Hashable {
    let id: UUID
    let ownerId: UUID
    let occasion: String
    let itemIds: [UUID]
    let caption: String?
    let published: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, occasion, caption, published
        case ownerId   = "owner_id"
        case itemIds   = "item_ids"
        case createdAt = "created_at"
    }
}

enum ReactionKind: String, Codable {
    case like, dislike, comment, steal
}
```

## Service interface

```swift
final class SupabaseService {
    static let shared = SupabaseService()
    let client: SupabaseClient

    var currentUserId: UUID? { client.auth.currentUser?.id }

    // Items
    func myItems(wishlist: Bool? = nil) async throws -> [ClothingItem]
    func itemsForUser(_ userId: UUID) async throws -> [ClothingItem]
    func itemsByIds(_ ids: [UUID]) async throws -> [ClothingItem]
    func uploadItemImage(_ data: Data) async throws -> String
    func createItem(_ item: ClothingItem) async throws
    func batchCreateItems(_ items: [ClothingItem]) async throws

    // Outfits
    func feed(limit: Int) async throws -> [Outfit]
    func outfitsByUser(_ userId: UUID) async throws -> [Outfit]
    func publishOutfit(_ outfit: Outfit) async throws

    // Reactions
    func react(targetType: String, targetId: UUID, kind: ReactionKind, comment: String?) async throws

    // Steal
    func stealOutfit(_ outfit: Outfit, sourceItems: [ClothingItem]) async throws

    // Profiles
    func profile(for userId: UUID) async throws -> Profile
    func searchProfiles(_ query: String) async throws -> [Profile]
}
```

## State management

- One `@Observable` view model per screen, owned by the view
- `@State private var model = FeedModel()` (iOS 17 lets `@State` hold reference types now)
- Models call `SupabaseService.shared` directly — no extra abstraction layer
- Each model exposes `var isLoading: Bool` and a `func load() async` triggered from `.task { ... }`

```swift
@Observable
final class FeedModel {
    var outfits: [Outfit] = []
    var itemsByOutfit: [UUID: [ClothingItem]] = [:]
    var profilesByUser: [UUID: Profile] = [:]
    var isLoading = false

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            outfits = try await SupabaseService.shared.feed(limit: 20)
            // Hydrate items and profiles in parallel
            // ...
        } catch {
            print("Feed load failed:", error)
        }
    }

    func react(to outfit: Outfit, kind: ReactionKind) async {
        // Optimistic: remove card from feed before reaction returns
        outfits.removeAll { $0.id == outfit.id }
        try? await SupabaseService.shared.react(
            targetType: "outfit", targetId: outfit.id, kind: kind, comment: nil
        )
    }

    func steal(_ outfit: Outfit) async {
        guard let sourceItems = itemsByOutfit[outfit.id] else { return }
        try? await SupabaseService.shared.stealOutfit(outfit, sourceItems: sourceItems)
    }
}
```

## Date decoding (gotcha)

Supabase returns ISO8601 with fractional seconds, which the default `.iso8601` strategy doesn't parse. Use this:

```swift
extension JSONDecoder {
    static let supabase: JSONDecoder = {
        let d = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            if let date = formatter.date(from: str) { return date }
            // fallback without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: str) { return date }
            throw DecodingError.dataCorruptedError(
                in: container, debugDescription: "Bad date: \(str)"
            )
        }
        return d
    }()
}
```

Configure `SupabaseClient` to use this decoder if the SDK exposes that hook; otherwise decode manually after fetching raw data.

## Optimistic UI patterns

| Action | Optimistic update |
|---|---|
| Save tag | Insert local `ClothingItem` with placeholder URL; reconcile on upload complete |
| Publish outfit | Show "Published!" toast immediately; revert on error |
| Feed swipe | Animate card off screen before reaction write returns |
| Steal | Show toast immediately; reconcile if the batch insert errors |
| Follow | Increment counts in UI before write returns |

Never block the user on a network round-trip during the demo.

## Auth approach

For hackathon speed: **Apple Sign In** if your team has Apple Developer access, otherwise **magic link** via Supabase email auth. Skip password flows entirely.

After first sign-in, prompt for `username` and `handle` to create the `profiles` row. Fail loudly if either is taken (Postgres unique constraint will reject).

## Known issues & workarounds

- `PhotosPicker` simulator: drag images into the simulator's Photos app via Finder before testing
- `VNGenerateForegroundInstanceMaskRequest` requires `@available(iOS 17, *)` annotation
- `AsyncImage` doesn't cache — fine for demo, may stutter on long scrolls
- Supabase Swift SDK signatures vary across minor versions; verify against installed README
- Date decoding: see "Date decoding (gotcha)" above
