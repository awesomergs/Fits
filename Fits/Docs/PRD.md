# Fits — Product Requirements

## Positioning (memorize this)

> Social apps show outfits. Shopping apps sell clothes. **Fits connects the two — through your real closet.**

Every product decision flows from this. If a feature doesn't reinforce the closet-as-bridge thesis, cut it.

## Three-beat demo narrative

1. **Problem** — Deciding what to wear is hard, and people want feedback from friends they trust.
2. **Solution** — Fits turns your closet into a social object: tag what you own, build fits, get feedback.
3. **Magic** — Adding items is instant. Snap a photo, the background drops out on-device, it's in your closet in two seconds.

Memorize these three sentences. They are the pitch.

## Why this isn't just "Instagram for outfits"

This question will come up. The answer:

> Instagram shows you a flat image. Fits is built on a structured closet — every outfit is **reusable**, **remixable**, and **traceable to individual items**. That's why we can do "Steal this fit" with one tap. You can't do that on Instagram because Instagram doesn't know what's in the picture.

Internalize this. Say "real closet" often during demos.

## Target user

Style-conscious 18–28-year-olds who already share fit checks in group chats, screenshot pieces from PacSun and Aritzia, and keep Pinterest boards. They have phones full of outfit photos with no organizational system. They follow fashion influencers but trust their friends' taste more.

## Core value loop

```
   Tag ──▶ Compose ──▶ Publish ──▶ Discover ──▶ Steal ──▶ Tag
   (build      (build      (get feedback)  (see        (add to
    closet)     a fit)                      friends')   wishlist)
```

The closet is the unit that makes every other action coherent. Without it, this is Instagram. With it, this is something new.

## Scope

### P0 — demo critical (must ship)

- **Auth** — Apple Sign In *or* magic link, whichever wires faster. No password flows.
- **Tag flow** — `PhotosPicker` → on-device cutout → category select → wishlist toggle → save
- **Closet view** — items grouped by category, wishlist visually distinct (dashed cherry-blossom border + bookmark icon)
- **Outfit builder** — slot carousels per category, occasion picker (Streetwear/Work/Gala/Casual/Date Night), publish action
- **Feed** — published outfits, swipe right (like) / swipe left (dislike), comment field per card
- **"Steal this fit"** ⭐ — one-tap copy of all items in an outfit to current user's wishlist (the differentiating mechanic)
- **Profile** — avatar, handle, follower counts, outfit grid, recent items
- **Seeded demo data** — 3 demo accounts with content (see "Empty app problem" below)

### P1 — only if P0 is rock-solid

- Find page — user search by handle + 2 hardcoded category rails
- Tap individual feed item → detail sheet with "Add to wishlist"
- Follow / unfollow from Profile
- Comment posting (the field exists in P0; submitting it is P1)

### P2 — do not build

- Shop tab (cut from the original sketch)
- True 2D paper-doll avatar (the slot-row layout is v1; the avatar is v2)
- Direct messages
- Notifications / push
- Onboarding tutorial
- Settings beyond auth
- Recommended Friends algorithm (hardcode if needed for Find)

## ⭐ The "Steal this fit" mechanic

This is your one differentiating mechanic. Per the feedback round, the app needs ONE thing that makes it feel intentional and not just a remix of Instagram. This is it.

**UX:**
- Every feed card has three action buttons in a row: ❌ dislike, 👕 **Steal this fit**, ❤️ like
- Tap Steal → all items in the outfit are inserted into the current user's `clothing_items` as wishlist items, marked with `source_item_id` pointing to the originals
- Toast confirms: "4 items added to your wishlist"
- The hearted/stolen state is visible on the card afterward (faint badge in the corner)

**Why this matters strategically:**
- It's the literal product positioning made tactile — "social → closet" in one tap
- It's the tap-the-screen, get-an-instant-result kind of action that judges remember
- It's the moment the demo earns the "we connect the two" line

**Implementation:** see `ARCHITECTURE.md` § "Flow: Steal".

## Empty app problem — seed data is non-negotiable

Without seed data the feed is empty and the demo dies. Build seeding as a real deliverable.

**Required seeded content (must exist before demo):**

- **3 demo accounts:** `@aria`, `@kai`, `@jules` — pick visually distinct vibes (one streetwear, one minimal, one statement)
- **8–12 clothing items per account** — span all categories (top/bottom/outerwear/shoes/accessory), mix owned and wishlist
- **5 published outfits across the 3 accounts** — all visually decent, real product photos with backgrounds removed (use Pexels, Unsplash, or pulled-and-cleaned product shots; use VisionKit on them in advance and upload the cutouts)
- **Follow graph:** the demo user (you on stage) follows all 3 demo accounts
- **One outfit specifically curated to be the demo's "Steal this fit" target** — make sure it looks great because every judge will see it

**Where it lives:** `Scripts/seed.sql` — a SQL file that inserts profiles, items (with already-uploaded image URLs), outfits, and follows. Or a Swift seeding routine triggered from a debug menu. Either way, **checked in and re-runnable**.

## Demo script (90 seconds, memorize verbatim)

> "What if your closet was social?
>
> *(Open Fits, tap Tag.)* I just bought this shirt. *(Snap photo of physical shirt held up to the camera.)* The app removed the background on-device — no API, no waiting. *(Cutout appears.)* It's in my closet. *(Tap save, switch to Closet tab, scroll, the shirt is the first item.)*
>
> Tonight's a date — let me build a fit. *(Pick "Date Night" from occasion dropdown, swipe through tops and pick one, swipe through bottoms, swipe through shoes.)* Publish. *(Tap publish, switch to second simulator/device representing a friend.)*
>
> My friend opens the app. *(Outfit is the top card on Feed.)* They like it. *(Swipe right.)* And — they want this exact look. *(Tap "Steal this fit".)* All four items are now in their wishlist. That's Fits — closet, social, shopping, in one loop."

That's it. Practice it out loud at least three times before demo. Time it.

## De-risking the demo (mandatory)

- **Cutout can fail.** If `VNGenerateForegroundInstanceMaskRequest` returns no subject, fall back to using the raw image silently. Never block the flow with an error.
- **Upload can be slow.** Show the cutout immediately and upload in the background. Closet should reflect the new item before upload completes (optimistic UI).
- **Wifi can die mid-demo.** Record a screen-capture of the full working flow on day-2 night as a backup — judges will accept it if your stage wifi fails.
- **Pre-stage the demo shirt.** Test the cutout against the actual shirt you'll demo with. Pick the one that isolates cleanest. Solid color and matte fabric work better than glossy or patterned.
- **Pre-curate the demo "Steal" outfit.** The outfit your friend (second device) will appear to publish should be hardcoded in seed data — not built live, in case Closet building has any quirks.
- **Charge two devices** to 100% before demo. One for "you", one for "your friend". Have a third as backup.

## Success criteria

The 90-second demo runs end-to-end without error in front of judges. Nothing else matters. Not feature count, not code quality, not architecture — the demo running cleanly is the win condition.
