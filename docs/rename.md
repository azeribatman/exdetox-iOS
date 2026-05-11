# Rename checklist

How to turn BatcaveStarter into **YourApp**.

## 1. Clone

```bash
git clone <batcavestarter-url> YourApp
cd YourApp
rm -rf .git && git init
```

## 2. Rename on disk

```bash
# Folders
mv BatcaveStarter YourApp
mv BatcaveStarter.xcodeproj YourApp.xcodeproj
mv BatcaveStarterTests YourAppTests
mv BatcaveStarterUITests YourAppUITests

# Shared schemes
mv YourApp.xcodeproj/xcshareddata/xcschemes/BatcaveStarter.xcscheme \
   YourApp.xcodeproj/xcshareddata/xcschemes/YourApp.xcscheme
mv YourApp.xcodeproj/xcshareddata/xcschemes/BatcaveStarter-Mock.xcscheme \
   YourApp.xcodeproj/xcshareddata/xcschemes/YourApp-Mock.xcscheme
```

## 3. Find-and-replace in files

Replace in **all** files (case-sensitive):

| Find | Replace |
|------|---------|
| `BatcaveStarter` | `YourApp` |
| `batcavestarter` | `yourapp` |
| `com.batcavestarter.app` | `com.yourcompany.yourapp` |

Key files that contain the project name:
- `YourApp.xcodeproj/project.pbxproj`
- `YourApp.xcodeproj/xcshareddata/xcschemes/*.xcscheme`
- `YourApp/App/YourAppApp.swift` (rename file too)
- `YourApp/Info.plist`
- `YourAppTests/` and `YourAppUITests/` test files

```bash
# One-liner (macOS sed)
find . -type f \( -name "*.swift" -o -name "*.pbxproj" -o -name "*.xcscheme" -o -name "*.plist" -o -name "*.xcconfig" \) \
  -exec sed -i '' 's/BatcaveStarter/YourApp/g; s/batcavestarter/yourapp/g; s/com\.batcavestarter\.app/com.yourcompany.yourapp/g' {} +
```

## 4. Rename the App entry point

```bash
mv YourApp/App/BatcaveStarterApp.swift YourApp/App/YourAppApp.swift
```

## 5. Update xcconfig BASE_HOST

Edit `YourApp/App/Config/Configurations/Development.xcconfig` and `Release.xcconfig`:
```
BASE_HOST = api.yourapp.com
```

## 6. Set your Development Team

In `project.pbxproj`, replace `DEVELOPMENT_TEAM = M4D9WCCL22` with your team ID. Or open Xcode → Signing & Capabilities → select your team.

## 7. Verify

```bash
xcodebuild -scheme YourApp -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -sdk iphonesimulator build

xcodebuild -scheme YourApp-Mock -configuration Mock \
  -destination 'generic/platform=iOS Simulator' \
  -sdk iphonesimulator build
```

## 8. Add starter origin to CLAUDE.md

Add this section to your project's CLAUDE.md so future upgrades work:

```markdown
## Starter origin
Created from [BatcaveStarter](https://github.com/azeribatman/batcavestarter).
To upgrade infrastructure, tell Claude: "upgrade starter infra to latest batcavestarter"
```

## 9. Clean up

- Delete or rename `Screens/Example/` (it's the reference feature).
- Remove the `example` case from `App/Router/RouterDestination`.
- Remove `ExampleMockDataProvider` registration from `NetworkClientFactory.defaultMockRegistry()`.
- Remove `exampleRepository` + `makeExampleStore()` from `DependencyContainer`.
- Update `LaunchView` to point at your real first screen.
- Delete `docs/rename.md` and update `CLAUDE.md` for your project.
