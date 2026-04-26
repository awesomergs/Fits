//
//  FeedCardView.swift
//  Fits
//
//  Full-screen TikTok layout + horizontal Tinder swipe for like/dislike.
//

import SwiftUI

// MARK: - Comment model

struct FeedComment: Identifiable {
    let id = UUID()
    let username: String
    let handle: String
    let text: String
}

private let positiveComments: [FeedComment] = [
    FeedComment(username: "Maya Patel",      handle: "mayap",        text: "obsessed with this whole look 🔥"),
    FeedComment(username: "Jordan Lee",      handle: "jlee",         text: "where is that jacket from??"),
    FeedComment(username: "Sofia Rivera",    handle: "sofrivera",    text: "the color combo is so good"),
    FeedComment(username: "Ethan Brooks",    handle: "ebrooks",      text: "lowkey need those shoes rn"),
    FeedComment(username: "Chloe Kim",       handle: "chloekim",     text: "ok this is actually perfect for fall"),
    FeedComment(username: "Nate Owens",      handle: "nateowens",    text: "W fit no notes"),
    FeedComment(username: "Priya Shah",      handle: "priyashah",    text: "is that vintage or recent? asking for a friend 👀"),
    FeedComment(username: "Alex Turner",     handle: "alexturner",   text: "stealing this immediately"),
    FeedComment(username: "Zoe Nguyen",      handle: "zoeng",        text: "the layering here is chef's kiss"),
    FeedComment(username: "Marcus Reid",     handle: "marcusreid",   text: "need a full breakdown of every item"),
    FeedComment(username: "Isla Foster",     handle: "islaf",        text: "this went so hard omg"),
    FeedComment(username: "Camille Dupont",  handle: "camilled",     text: "très chic honestly"),
    FeedComment(username: "Ryo Tanaka",      handle: "ryotan",       text: "the shoes carry this fit fr"),
    FeedComment(username: "Amara Osei",      handle: "amaraosei",    text: "not me screenshotting this for inspo"),
    FeedComment(username: "Tyler Moss",      handle: "tylermoss",    text: "casual but make it fashion"),
    FeedComment(username: "Lena Bauer",      handle: "lenab",        text: "this is giving quiet luxury vibes"),
    FeedComment(username: "Kai Nakamura",    handle: "kainaka",      text: "fit check passed with flying colors"),
    FeedComment(username: "Nia Clarke",      handle: "niaclarke",    text: "the bag is everything!!"),
    FeedComment(username: "Owen Park",       handle: "owenpark",     text: "solid 9/10 would steal"),
    FeedComment(username: "Fatima Al-Hassan",handle: "fatimah",      text: "ok where do you even shop"),
    FeedComment(username: "Jess Wu",         handle: "jesswu",       text: "this is my roman empire"),
    FeedComment(username: "Ben Castillo",    handle: "bencast",      text: "the fit is immaculate"),
    FeedComment(username: "Rina Kobayashi",  handle: "rinakob",      text: "giving main character energy"),
    FeedComment(username: "Sam Ellis",       handle: "samellis",     text: "I've been looking for a top like that for months"),
    FeedComment(username: "Aisha Diallo",    handle: "aishad",       text: "the proportions are so good here"),
    FeedComment(username: "Felix Wagner",    handle: "felixw",       text: "effortlessly cool"),
    FeedComment(username: "Mia Chen",        handle: "miachen",      text: "this is a top 5 fit for me personally"),
    FeedComment(username: "Luke Santos",     handle: "lukesantos",   text: "dressing like the main character I see"),
    FeedComment(username: "Hana Suzuki",     handle: "hanasuz",      text: "the tonal look is everything rn"),
    FeedComment(username: "Chris Bell",      handle: "chrisbell",    text: "no notes, just send me your closet"),
    FeedComment(username: "Vera Novak",      handle: "veranov",      text: "this is so clean I can't"),
    FeedComment(username: "Yara Ali",        handle: "yaraali",      text: "major style goals"),
    FeedComment(username: "Jin Park",        handle: "jinpark",      text: "everything is perfectly sized"),
    FeedComment(username: "Raj Mehta",       handle: "rajmehta",     text: "okay this is actually insane"),
    FeedComment(username: "Tara Walsh",      handle: "tarawalsh",    text: "this fit lives rent free in my head now"),
    FeedComment(username: "Elena Vasquez",   handle: "elenav",       text: "drop the brand links PLEASE"),
    FeedComment(username: "Darius Cole",     handle: "dariuscole",   text: "the confidence to wear this, respect"),
    FeedComment(username: "Sophie Laurent",  handle: "sophiel",      text: "this is on my mood board now"),
    FeedComment(username: "Kenji Mori",      handle: "kenjimori",    text: "fit so cold I need a jacket"),
    FeedComment(username: "Grace Okafor",    handle: "graceokafor",  text: "this is giving exactly what it was supposed to give"),
    FeedComment(username: "Will Hartley",    handle: "willh",        text: "understated but so considered"),
    FeedComment(username: "Alinta Watson",   handle: "alintaw",      text: "the way every piece just works together"),
    FeedComment(username: "Sana Yoshida",    handle: "sanayosh",     text: "not the fit making me rethink my entire wardrobe"),
    FeedComment(username: "Omar Farouq",     handle: "omarfarouq",   text: "W W W W W"),
    FeedComment(username: "Tariq James",     handle: "tariqj",       text: "who let you cook like this"),
    FeedComment(username: "Ines Morales",    handle: "inesm",        text: "the accessories pull the whole thing together"),
    FeedComment(username: "Blake Sutton",    handle: "blakes",       text: "this is so effortlessly put together"),
    FeedComment(username: "Leila Aziz",      handle: "leilaaziz",    text: "my pinterest board is shaking"),
    FeedComment(username: "Tess Harrington", handle: "tessh",        text: "everything about this is right"),
    FeedComment(username: "Kofi Asante",     handle: "kofiasante",   text: "drip check: passed"),
    FeedComment(username: "Jasper Reed",     handle: "jasperreed",   text: "clean, minimal, elite"),
    FeedComment(username: "Anya Petrova",    handle: "anyap",        text: "how are the fits just getting better"),
    FeedComment(username: "Diego Reyes",     handle: "diegor",       text: "stealing the whole aesthetic not just the fit"),
    FeedComment(username: "Zara Malik",      handle: "zaramalik",    text: "I want your whole wardrobe honestly"),
    FeedComment(username: "Eli Cohen",       handle: "elicohen",     text: "this gives me hope for fashion"),
    FeedComment(username: "Bea Thornton",    handle: "beathornton",  text: "studied this fit for 5 minutes, no notes"),
    FeedComment(username: "Yuki Hayashi",    handle: "yukihay",      text: "the fit is a whole mood"),
    FeedComment(username: "Cleo Jacobs",     handle: "cleojacobs",   text: "ok but where did you get that top"),
    FeedComment(username: "Callum Fraser",   handle: "callumf",      text: "just sent this to my entire group chat"),
    FeedComment(username: "Valentina Cruz",  handle: "valcruz",      text: "this is genuinely an artwork"),
    FeedComment(username: "Astrid Holm",     handle: "astridholm",   text: "clean lines, great proportions, 10/10"),
    FeedComment(username: "Theo Blackwood",  handle: "theoblack",    text: "whoever styled this understood the assignment"),
    FeedComment(username: "Remi Fontaine",   handle: "remif",        text: "the casual luxury balance is unreal"),
    FeedComment(username: "Ike Obi",         handle: "ikeobi",       text: "not me buying everything in this fit"),
    FeedComment(username: "Linnea Strand",   handle: "linneas",      text: "the color palette is so cohesive"),
    FeedComment(username: "Matteo Romano",   handle: "matteor",      text: "Milano approved"),
    FeedComment(username: "Iris Chen",       handle: "irischen",     text: "you really said fashion is art and proved it"),
    FeedComment(username: "Celeste Noir",    handle: "celestenoir",  text: "this is the fit of the season for me"),
    FeedComment(username: "Ximena Torres",   handle: "ximenat",      text: "ok you really woke up and chose excellence"),
    FeedComment(username: "Paloma Vega",     handle: "palomav",      text: "the accessories are the story here"),
    FeedComment(username: "Sienna Fox",      handle: "siennafox",    text: "this popped up on my fyp and I had to comment"),
]

private let negativeComments: [FeedComment] = [
    FeedComment(username: "Dev Sharma",      handle: "devsharma",    text: "idk about this one honestly"),
    FeedComment(username: "Tobias Greer",    handle: "tobiasgreer",  text: "not really my style but ok"),
    FeedComment(username: "Nadia Petrov",    handle: "nadiap",       text: "the colors are giving a lot"),
    FeedComment(username: "Leo Moreau",      handle: "leomoreau",    text: "I think the shoes are fighting the rest of the fit"),
    FeedComment(username: "Marco Ricci",     handle: "marcoricci",   text: "feels a bit off to me, can't explain why"),
    FeedComment(username: "Fiona Bell",      handle: "fionab",       text: "this is giving confused energy"),
    FeedComment(username: "Hamid Rahimi",    handle: "hamidr",       text: "the fit is okay I guess"),
    FeedComment(username: "Simone Dubois",   handle: "simoned",      text: "I've seen this look done better tbh"),
    FeedComment(username: "Luca Ferrari",    handle: "lucaf",        text: "not sure the pieces go together"),
    FeedComment(username: "Nour Hassan",     handle: "nourhassan",   text: "the proportions feel a little off"),
    FeedComment(username: "Arthur Lebrun",   handle: "arthurl",      text: "missing something, can't put my finger on it"),
    FeedComment(username: "Pita Havili",     handle: "pitah",        text: "giving try hard energy imo"),
    FeedComment(username: "Rosie Gallagher", handle: "rosieg",       text: "not for me personally but do you"),
    FeedComment(username: "Ivan Sokolov",    handle: "ivansok",      text: "the jacket doesn't work with the rest"),
    FeedComment(username: "Phoebe Hart",     handle: "phoebehart",   text: "feels like three different fits in one"),
    FeedComment(username: "Soren Jensen",    handle: "sorenj",       text: "the color clash is a bit much"),
    FeedComment(username: "Miriam Okonkwo",  handle: "miriamok",     text: "idk the vibe feels off today"),
    FeedComment(username: "Olu Adeyemi",     handle: "oluadeyemi",   text: "bold choice, I'll say that"),
    FeedComment(username: "Rowan Murphy",    handle: "rowanm",       text: "not my taste but I respect the commitment"),
    FeedComment(username: "Axel Brandt",     handle: "axelbrandt",   text: "the fit needs editing"),
    FeedComment(username: "Kwame Boateng",   handle: "kwameb",       text: "something about this isn't landing for me"),
    FeedComment(username: "Pierre Blanc",    handle: "pierreb",      text: "un peu trop pour moi"),
    FeedComment(username: "Hugo Lemaire",    handle: "hugol",        text: "the accessories are competing too much"),
    FeedComment(username: "Aaliyah Moore",   handle: "aaliyahm",     text: "this needed one less piece"),
    FeedComment(username: "Adele Fontaine",  handle: "adelef",       text: "the texture mixing isn't working here"),
    FeedComment(username: "Mila Voss",       handle: "milavoss",     text: "I feel like this misses"),
    FeedComment(username: "Cara Flynn",      handle: "caraflynn",    text: "idk the silhouette looks awkward"),
    FeedComment(username: "Leila Aziz",      handle: "leilaaziz",    text: "the fit is giving a 5/10 from me"),
    FeedComment(username: "Hugo Lemaire",    handle: "hugo_l",       text: "would've worked better with different shoes"),
    FeedComment(username: "Ximena Torres",   handle: "ximena_t",     text: "trying a bit too hard with the layering"),
]

private func comments(for outfit: Outfit) -> [FeedComment] {
    let hash = abs(outfit.id.hashValue)
    let count = 2 + (hash % 6)
    var seed = hash

    func nextRand() -> Int {
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        return seed < 0 ? -seed : seed
    }

    let posTarget: Int
    let negTarget: Int
    if outfit.hotness >= 0.5 {
        posTarget = max(1, Int((Double(count) * 0.8).rounded()))
        negTarget = count - posTarget
    } else {
        negTarget = max(1, Int((Double(count) * 0.8).rounded()))
        posTarget = count - negTarget
    }

    var posIndices = Set<Int>()
    var posResult: [FeedComment] = []
    while posResult.count < posTarget {
        let idx = nextRand() % positiveComments.count
        if posIndices.insert(idx).inserted { posResult.append(positiveComments[idx]) }
    }

    var negIndices = Set<Int>()
    var negResult: [FeedComment] = []
    while negResult.count < negTarget {
        let idx = nextRand() % negativeComments.count
        if negIndices.insert(idx).inserted { negResult.append(negativeComments[idx]) }
    }

    // Interleave positive and negative deterministically
    var result: [FeedComment] = []
    var pi = 0, ni = 0
    while pi < posResult.count || ni < negResult.count {
        if pi < posResult.count { result.append(posResult[pi]); pi += 1 }
        if ni < negResult.count { result.append(negResult[ni]); ni += 1 }
    }
    return result
}

// MARK: - Card view

struct FeedCardView: View {
    let outfit: Outfit
    let items: [ClothingItem]
    let profile: Profile?
    var onLike: (() -> Void)? = nil
    var onDislike: (() -> Void)? = nil
    var onSteal: (() -> Void)? = nil
    var onTryOn: (([ClothingItem]) -> Void)? = nil

    @GestureState private var dragX: CGFloat = 0
    @State private var stampDirection: CGFloat = 0   // 1 = like, -1 = dislike, 0 = none
    @State private var isStolen: Bool = false
    @State private var stealToastMessage: String? = nil
    @State private var showComments = false

    private let threshold: CGFloat = 90

    var body: some View {
        ZStack {
            background

            HStack(alignment: .bottom, spacing: 0) {
                outfitContent
                    .frame(width: 280, height: 640, alignment: .bottomLeading)

                actionSidebar
                    .frame(width: 80, height: 640)
            }

            stampOverlay

            if let msg = stealToastMessage {
                VStack {
                    ToastView(message: msg)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer()
                }
                .padding(.top, 60)
            }
        }
        .frame(width: 360, height: 640)   // 🔥 hard lock
        .clipped()                        // 🔥 nothing escapes
        .offset(x: stampDirection != 0 ? 0 : dragX)
        .rotationEffect(.degrees(stampDirection != 0 ? 0 : Double(dragX / 30)))
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: stampDirection)
        .gesture(horizontalSwipeGesture)
        .sheet(isPresented: $showComments) {
            CommentsSheet(comments: comments(for: outfit))
        }
    }

    // MARK: - Background

    private var background: some View {
        ZStack {
            Color.black

            if let first = items.first {
                ItemImageView(item: first, contentMode: .fill)
                    .blur(radius: 40)
                    .opacity(0.5)
                    .clipped()
            }
        }
        .frame(maxWidth: .infinity)
        .clipped()
    }

    // MARK: - Outfit content

    private var outfitContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Spacer(minLength: 40)
            itemsGrid
                .scaleEffect(0.95)
            Spacer(minLength: 40)

            VStack(alignment: .leading, spacing: 6) {
                profileRow

                if let caption = outfit.caption, !caption.isEmpty {
                    Text(caption)
                        .lineLimit(2)
                        .font(.fitsBody)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                }

                Text(outfit.occasion)
                    .font(.fitsCaption)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            .padding(.top, 20)
        }
        .frame(width: 280, height: 640, alignment: .bottomLeading)
    }

    private var itemsGrid: some View {
        let gridItems = Array(items.prefix(4))

        return Group {
            if gridItems.isEmpty {
                EmptyView()
            } else if gridItems.count == 1 {
                ItemImageView(item: gridItems[0], contentMode: .fill)
                    .frame(width: 200, height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.leading, 16)
            } else {
                LazyVGrid(
                    columns: [GridItem(.fixed(120)), GridItem(.fixed(120))],
                    spacing: 8
                ) {
                    ForEach(gridItems) { item in
                        ItemImageView(item: item, contentMode: .fill)
                            .frame(width: 120, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.leading, 16)
            }
        }
    }

    private var profileRow: some View {
        HStack(spacing: 8) {
            AsyncImage(url: profile?.avatarUrl.flatMap(URL.init)) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Circle().fill(.white.opacity(0.3))
                }
            }
            .frame(width: 34, height: 34)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(.white.opacity(0.4), lineWidth: 1))

            VStack(alignment: .leading, spacing: 1) {
                Text(profile?.username ?? "User")
                    .font(.fitsCaption.weight(.semibold))
                    .foregroundStyle(.white)
                Text("@\(profile?.handle ?? "")")
                    .font(.micro)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
    }

    // MARK: - Hotness indicator

    private var hotnessIndicator: some View {
        VStack(spacing: 4) {
            Image(systemName: outfit.hotness >= 0.5 ? "flame.fill" : "trash.fill")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(outfit.hotness >= 0.5 ? Color.orange : Color.red)
                .shadow(color: .black.opacity(0.4), radius: 4)
            Text("\(Int(outfit.hotness * 100))%")
                .font(.micro)
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    // MARK: - Action sidebar

    private var actionSidebar: some View {
        VStack(spacing: 24) {
            Spacer()

            AsyncImage(url: profile?.avatarUrl.flatMap(URL.init)) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Circle().fill(.white.opacity(0.3))
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(.white, lineWidth: 1.5))

            hotnessIndicator

            actionButton(
                systemImage: "bubble.left.fill",
                label: "\(comments(for: outfit).count)",
                color: .white
            ) {
                showComments = true
            }

            actionButton(
                systemImage: isStolen ? "checkmark.circle.fill" : "tshirt.fill",
                label: isStolen ? "Stolen" : "Steal",
                color: isStolen ? FitsTheme.accent : .white
            ) {
                guard !isStolen else { return }
                isStolen = true
                onSteal?()
                showStealToast()
            }

            if isStolen {
                actionButton(
                    systemImage: "person.fill",
                    label: "Try On",
                    color: FitsTheme.accent
                ) {
                    onTryOn?(items)
                }
            }
        }
        .padding(.trailing, 16)
        .padding(.bottom, 32)
        .frame(width: 80)
    }

    private func actionButton(
        systemImage: String,
        label: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(color)
                    .shadow(color: .black.opacity(0.4), radius: 4)
                Text(label)
                    .font(.micro)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Stamp overlay

    private var stampOverlay: some View {
        let likeOpacity: Double  = stampDirection > 0 ? 1 : (dragX > 20  ? min(Double(dragX  - 20) / 60, 1) : 0)
        let nopeOpacity: Double  = stampDirection < 0 ? 1 : (dragX < -20 ? min(Double(-dragX - 20) / 60, 1) : 0)

        return ZStack {
            HStack(spacing: 6) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 36, weight: .black))
                Text("NOT")
                    .font(.system(size: 48, weight: .black))
            }
            .foregroundStyle(.red)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(.red, lineWidth: 4))
            .rotationEffect(.degrees(-15))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .opacity(nopeOpacity)

            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 36, weight: .black))
                Text("HOT")
                    .font(.system(size: 48, weight: .black))
            }
            .foregroundStyle(.orange)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(.orange, lineWidth: 4))
            .rotationEffect(.degrees(15))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .opacity(likeOpacity)
        }
    }

    // MARK: - Gesture

    private var horizontalSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .updating($dragX) { value, state, _ in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                state = value.translation.width
            }
            .onEnded { value in
                let dx = value.translation.width
                guard abs(dx) > abs(value.translation.height) else { return }
                if dx > threshold { triggerReaction(direction: 1) }
                else if dx < -threshold { triggerReaction(direction: -1) }
            }
    }

    private func triggerReaction(direction: CGFloat) {
        guard stampDirection == 0 else { return }
        stampDirection = direction
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if direction > 0 { onLike?() } else { onDislike?() }
            stampDirection = 0
        }
    }

    private func showStealToast() {
        let count = items.count
        stealToastMessage = "\(count) \(count == 1 ? "item" : "items") added to your closet"
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            stealToastMessage = nil
        }
    }
}

// MARK: - Comments sheet

private struct CommentsSheet: View {
    let comments: [FeedComment]

    var body: some View {
        VStack(spacing: 0) {
            Text("Comments")
                .font(.fitsHeadline)
                .foregroundStyle(FitsTheme.primary)
                .padding(.top, 20)
                .padding(.bottom, 16)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(comments) { comment in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(FitsTheme.accent)

                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(comment.username)
                                        .font(.fitsHeadline)
                                        .foregroundStyle(FitsTheme.primary)
                                    Text("@\(comment.handle)")
                                        .font(.fitsCaption)
                                        .foregroundStyle(FitsTheme.primary.opacity(0.5))
                                }
                                Text(comment.text)
                                    .font(.fitsBody)
                                    .foregroundStyle(FitsTheme.primary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(FitsTheme.background.ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - micro font

private extension Font {
    static var micro: Font { .system(size: 11, weight: .medium) }
}

#Preview {
    let profile = Profile(
        id: UUID(),
        username: "Aria Chen",
        handle: "aria",
        avatarUrl: "https://i.pravatar.cc/150?img=47"
    )
    let outfit = Outfit(
        ownerId: profile.id,
        occasion: "Streetwear",
        itemIds: [],
        caption: "weekend fit 🖤",
        published: true
    )
    return FeedCardView(outfit: outfit, items: [], profile: profile)
        .background(Color.black)
}
