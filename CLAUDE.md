# ExDetox

iOS app helping users detox from an ex-partner.

## Starter origin

Created from [BatcaveStarter](https://github.com/azeribatman/batcavestarter). Infrastructure was synced to match the current starter; feature code and the persistence stack (SwiftData, generic `Store<State>` base) diverge intentionally and should be preserved.

## Architecture

```
Request -> NetworkClient -> (feature code) -> Store -> View
SwiftData @Model records back persistent Stores (Tracking, UserProfile, Notification)
```

- **NetworkClientType** protocol - `NetworkClient` is the live implementation. ExDetox does not currently use a mock client at the network layer; mocking lives at the repository layer (`Network/Repository/Mock/`).
- **Store** - generic `Store<State: StoreState>` base class in `ExDetox/Base/Store/`. Concrete stores: `TrackingStore`, `UserProfileStore`, `NotificationStore`. Stores are persisted via SwiftData (`TrackingPersistence`, `TrackingMigration`).
- **DependencyContainer** - lightweight DI hook at `App/DependencyContainer.swift`. Owns the live `NetworkClient`; ready for future repositories. Stores in this project are still created as `@State` in `ExDetoxApp` and injected via `.environment()`.
- **Router** - `Router/Router.swift` (`@Observable`). `RouterDestination` enum carries a `view(for:)` builder that resolves destination -> View inline.

## Project structure

```
ExDetox/
|-- App/
|   |-- ExDetoxApp.swift           # @main entry point, AppDelegate, model container
|   |-- ScreenshotsApp.swift       # alternate entry for screenshot generation
|   |-- DependencyContainer.swift  # DI hook (live NetworkClient, future repos)
|   `-- Config/
|       |-- AppConfig.swift        # reads xcconfig values
|       |-- AppEnvironment.swift   # always .live (no Mock scheme wired)
|       `-- Configurations/
|           |-- Development.xcconfig
|           `-- Release.xcconfig
|-- Router/
|   |-- Router.swift
|   |-- Router+Extension.swift     # withAppRouter() modifier
|   |-- Router+Sheet.swift
|   `-- RouterDestination.swift    # enum + view(for:) builder
|-- Network/
|   |-- Client/                    # NetworkClient, NetworkClientType,
|   |                              # NetworkClientFactory, NetworkError, etc.
|   |-- Request/
|   |   |-- Base/                  # Request protocol + extensions
|   |   `-- Multipart/             # file upload support
|   |-- Response/                  # EmptyResponse
|   `-- Repository/
|       `-- Mock/                  # MockRepository (repo-layer mocking)
|-- Base/
|   `-- Store/                     # Store<State> base + concrete stores
|-- Screens/                       # SwiftUI views
|   |-- Onboarding/
|   |-- Main/
|   |-- Quiz/
|   |-- Creator/
|   `-- Screenshots/
|-- Components/                    # shared in-app components
|-- Reusable/
|   |-- Button/                    # PrimaryButtonStyle, SecondaryButtonStyle,
|   |                              # TextButtonStyle
|   |-- Preview/                   # PreviewContainer
|   |-- Background/, Blur/, Confetti/, Loader/, Notification/, Scroll/, Spacer/
|-- Extensions/
|   |-- Color/                     # Color+Hex, Color+App (semantic tokens)
|   |-- Typography/                # AppTypography
|   |-- Font/                      # Font+App, UIFont+App
|   |-- Localization/              # L10n, String+Localization
|   |-- Foundation/                # AppSpacing, AppRadius
|   |-- View/, UIApplication/, UIDevice/, UIImage/, Image/, Date/,
|   |   String/, JSON/, NSMutableData/, NotificationCenter/, Task/, Error/,
|   |   AsString/, PrefixSequence/, UINavigationController/
|-- Helpers/
|   |-- Analytics/, Audio/, ChatLimit/, Clipboard/, Creator/, Debug/,
|   |   Execute/, File/, Haptics/, Keychain/, Notifications/,
|   |   SwipeGesture/, URL/
|-- Models/, Design/, Demo/
|-- Localization/
|   `-- en.lproj/Localizable.strings
`-- Files/                         # Assets.xcassets, Roasts, Quotes, Learning,
                                   # Notifications, Onboarding
```

`ExDetox.xcodeproj` uses Xcode 16 synchronized folder groups, so any file added under `ExDetox/` is picked up by the target automatically.

## Build schemes

| Scheme | What it does |
|--------|-------------|
| **ExDetox** | Main app target |
| **ExDetox Creator** | Internal Creator panel build |

ExDetox does not currently have a Mock scheme. `AppEnvironment.current` is always `.live`.

## Design system

### Colors (`Extensions/Color/Color+App.swift`)
- Semantic tokens: `Color.appPrimary`, `.appSecondary`, `.appBackground`, `.appSurface`, `.appCardBackground`, `.appBorder`, `.appAccent`, `.appError`, `.appSuccess`, etc. (auto switch light/dark).
- Raw palette: `neutral50`-`neutral950`, `brand50`-`brand700`.
- ExDetox forces light mode at the root (`.preferredColorScheme(.light)` in `ExDetoxApp`). The dark variants are present so the tokens still work if that is ever relaxed.

### Typography (`Extensions/Typography/AppTypography.swift`)
- Tokens: `.heading1`-`.heading6`, `.bodyL/M/S/XS`, `.labelL/S/XS`, `.caption`.
- Apply via `Text("Hello").appFont(.heading3)` or `.font(.app(.bodyM))`.
- System font by default. Set `customFontName` in `AppTypography` to switch to a bundled font.

### Spacing & Radius (`Extensions/Foundation/AppSpacing.swift`)
- `AppSpacing.xs` (4) through `AppSpacing.xxxxl` (48).
- `AppRadius.sm` (8) through `AppRadius.xl` (20) + `AppRadius.full` (pill).

### Button styles (`Reusable/Button/`)
- `Button("Go") { }.primaryButton()` - filled, full-width, supports `leftIcon:`, `rightIcon:`, `isLoading:`.
- `Button("Cancel") { }.secondaryButton()`.
- `Button("Skip") { }.textButton()`.

### Localization (`Extensions/Localization/`)
- Type-safe keys: `L10n.commonOk.localized` -> looks up `"common.ok"` in `Localizable.strings`.
- Raw key access: `"some.key".localized` via `String+Localization`.
- Strings file: `ExDetox/Localization/en.lproj/Localizable.strings`.
- ExDetox currently has many hardcoded UI strings. Migrate them to `L10n` only as you touch each screen; do not do a big bang migration.

### Previews
- Wrap views in `PreviewContainer { YourView() }` to get a default `Router` + `DependencyContainer` for previews.

## Image generation (fal.ai MCP)

Project-scoped MCP server in `.mcp.json` uses fal.ai for image generation (GPT Image 2, Nano Banana 2, FLUX.2, Imagen 4, Ideogram V3, Seedream, etc.).

To activate locally:

1. Get an API key at https://fal.ai/dashboard/keys
2. `export FAL_KEY="fal_..."` in your shell profile
3. Restart Claude Code in the project root; it will pick up `.mcp.json` and prompt to approve the server.

The `.mcp.json` references `${FAL_KEY}` so the key never gets committed.

## Skills

- **`skills/demo/`** - `/demo` workflow. Records a screen-recorded walkthrough of an app flow and saves a `.mov` to `~/Documents/`. `scripts/record-demo.sh` is already configured for ExDetox (`SCHEME=ExDetox`, `BUNDLE_ID=com.app.exdetox`); update `DEFAULT_TEST_ID` once the recorder UITest exists.

## Writing style (no AI slop)

When writing ANY text in this project (code comments, docs, commit messages, PR bodies, UI strings, localized strings):

- **No em-dashes (`-`) or en-dashes (`-`).** Use a regular hyphen `-`, a comma, a period, or a colon. Never use Unicode dashes.
- **No letter-spaced "tracked" headers** like `H E A D E R` or `T I T L E`. Write headers normally. Do not insert spaces between letters for emphasis, ever, anywhere (UI, comments, docs).
- **No `tracking()` / `kerning()`** applied to text just to spread letters apart for an "AI-styled" look.
- Keep prose plain and direct. No marketing fluff: no "seamlessly", "leverages", "delve", "robust", "comprehensive".

## Conventions

- **DTOs are optional**; UI models are non-optional.
- **State holds UI models**; never raw DTOs.
- **Session errors**: check `error.isSessionEnded` and skip setting `state.error` for those (global handler takes over).
- **No mock repository classes at the network layer**: mocking lives in `Network/Repository/Mock/`.
- **Localized strings**: prefer `L10n.caseName.localized`. Existing hardcoded strings are okay; migrate opportunistically.
- **Folder rules**: Extensions are organized by concept (one folder per type/feature), not by framework. Helpers are organized into subfolders too.

## Upgrading starter infra

This project tracks BatcaveStarter for infrastructure (Network/Client, Network/Request, Extensions, Helpers, Reusable, Router base, App/Config base, design tokens, button styles, L10n scaffold, root tooling).

To upgrade: tell Claude *"upgrade starter infra to latest batcavestarter"*. Claude should:

1. Clone the latest BatcaveStarter
2. Sync infrastructure files only (not Screens, Stores, RouterDestination contents, MockRepository, Localizable.strings content, xcconfigs)
3. Preserve ExDetox's diverging patterns: generic `Store<State>` base, repo-layer mocking, SwiftData persistence, `RouterDestination.view(for:)` inline builder, `.preferredColorScheme(.light)`, AppsFlyer/Superwall/Firebase wiring.
