# Zeen (iOS SwiftUI Prototype)

Zeen is a privacy-first iOS concept app that estimates cognitive fragmentation using behavior signals (app switching, short sessions, interruptions, and focus breaks), then surfaces a simple **Cognitive Drift Score**.

## What is included

- SwiftUI app scaffold (`ZeenApp`) with a polished glass-style interface
- Daily score screen with factor breakdown
- Timeline screen for high-fragmentation windows
- Weekly insights with `Charts`
- Settings/privacy screen
- Scoring engine + mock data provider for challenge demo

## Folder structure

- `Zeen/ZeenApp.swift`
- `Zeen/Models/`
- `Zeen/Services/`
- `Zeen/ViewModels/`
- `Zeen/DesignSystem/`
- `Zeen/Views/`

## How to run

1. In Xcode, create a new iOS App project named `Zeen` (SwiftUI lifecycle).
2. Replace generated Swift files with the files in `ios/Zeen/Zeen/`.
3. Set minimum deployment target to iOS 17+.
4. Build and run.

## Notes on Apple APIs

For production integrations, wire the data layer to:

- `FamilyControls` / `DeviceActivity` (Screen Time style usage signals)
- Focus status signals where available
- Local notification metadata patterns

This prototype intentionally uses mock data so it runs without entitlements during a coding challenge.
