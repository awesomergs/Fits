# Supabase Setup Guide for Fits

## Prerequisites

You already have:
- Supabase project URL: `https://ojqvyuwgdrayyrrxhgyx.supabase.co`
- Service key (keep this secret, use only in backend)
- Need to get: **Anon public key** from Supabase dashboard

---

## Step 1: Deploy Database Schema

1. Open Supabase dashboard → SQL Editor
2. Click **"New Query"**
3. Copy the entire contents of `supabase_setup.sql` into the editor
4. Click **"Run"** (or `Cmd+Enter`)
5. You should see "Success" — all tables, indexes, and RLS policies are now created

---

## Step 2: Create Storage Buckets

1. Supabase dashboard → **Storage**
2. Click **"Create bucket"**
   - Name: `clothing`
   - Make it **Public** (toggle on)
   - Create
3. Repeat for `avatars` bucket

4. For each bucket, check the **Policies** tab:
   - You should see a policy allowing public SELECT and authenticated INSERT
   - If not, manually create:
     ```
     CREATE POLICY "authenticated_insert_public_read"
       ON storage.objects
       FOR ALL
       USING (true)
       WITH CHECK (auth.role() = 'authenticated');
     ```

---

## Step 3: Get Your Anon Key

1. Supabase dashboard → **Settings** → **API**
2. Copy the **"anon [public]"** key (the long base64 string, NOT the service key)
3. You'll need this for the iOS app

---

## Step 4: Create Secrets.swift in iOS App

1. In Xcode, right-click the `Fits` folder → "New File"
2. Create `Secrets.swift`:

```swift
enum Secrets {
    static let supabaseURL = "https://ojqvyuwgdrayyrrxhgyx.supabase.co"
    static let supabaseAnonKey = "YOUR_ANON_KEY_HERE"  // Paste the key from Step 3
}
```

3. **Important**: Add to `.gitignore` so secrets are never committed:

```bash
# In the repo root .gitignore, add:
Fits/Secrets.swift
```

---

## Step 5: Test RLS Policies

Optional but recommended — verify that row-level security is working correctly:

1. SQL Editor → **New Query**
2. Paste this test (as a test user, not service role):

```sql
-- Test as authenticated user
SELECT * FROM public.profiles;  
-- Should return only your profile(s)

SELECT * FROM public.clothing_items WHERE is_wishlist = false;
-- Should return items you own

SELECT * FROM public.outfits WHERE published = true;
-- Should return published outfits from all users

SELECT * FROM public.outfits WHERE published = false;
-- Should return only your draft outfits
```

If RLS is working correctly, drafts will only show your own, but published will show all.

---

## Step 6: (Optional) Seed Demo Data

To have a richer demo experience, you can manually insert some profiles + items:

```sql
-- Insert demo profiles
INSERT INTO public.profiles (id, username, handle, bio)
VALUES 
  ('550e8400-e29b-41d4-a716-446655440000'::uuid, 'demo1', '@demo1', 'First demo user'),
  ('650e8400-e29b-41d4-a716-446655440001'::uuid, 'demo2', '@demo2', 'Second demo user');

-- Insert demo items (replace IDs with your user IDs)
INSERT INTO public.clothing_items (owner_id, image_url, category, occasion_tags, is_wishlist)
VALUES 
  ('550e8400-e29b-41d4-a716-446655440000'::uuid, 'https://via.placeholder.com/200?text=shirt1', 'top', ARRAY['casual', 'summer'], false),
  ('550e8400-e29b-41d4-a716-446655440000'::uuid, 'https://via.placeholder.com/200?text=jeans', 'bottom', ARRAY['casual', 'everyday'], false);
```

---

## Troubleshooting

### "Query returned empty results"

**Most likely cause**: RLS policy is blocking your query.

**Solution**:
1. Check that you're running the query as an authenticated user (not service role)
2. Check the policy — does it allow what you're trying to do?
3. Verify `auth.uid()` matches the `owner_id` or `user_id` in the row

### "Permission denied" on bucket uploads

**Likely cause**: Storage policy isn't configured correctly.

**Solution**:
1. Go to Storage → bucket → Policies
2. Verify a policy exists allowing `INSERT` for authenticated users

### "Invalid UUID" or encoding errors

**Likely cause**: Column type mismatch.

**Solution**: Ensure all `id` columns are `uuid` type, and when inserting from Supabase dashboard, use the UUID picker (don't paste strings).

---

## What's Next

Once this is done:
1. Go back to Xcode
2. Proceed with Phase 2: Add `Codable` to models
3. Then implement `SupabaseService`
