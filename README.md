# Zeen — Cognitive Drift Tracker for iOS

Zeen is a privacy-first iOS app that estimates **cognitive fragmentation** using behavioral signals (app switching, short sessions, notification interruptions, focus breaks) and surfaces a single **Drift Score** — a measure of how scattered your attention has been throughout the day.

Unlike raw screen-time trackers, Zeen focuses on *attention quality*, not duration.

## ✨ Key Features

- **Drift Score Engine** — Weighted scoring across four behavioral factors with adaptive insight generation
- **Smart Insights** — Contextual analysis of your patterns, top drivers, calmest periods, and goal tracking
- **Timeline Visualization** — Hourly fragmentation chart (Charts framework) with Catmull-Rom interpolation and bar breakdown
- **Weekly Trends** — Trend detection (improving / stable / worsening), streak tracking, deep focus analysis per day
- **Animated Glass UI** — Glassmorphism design system with staggered card animations, angular gradient score ring, ambient drifting background orbs, and haptic feedback
- **Privacy Controls** — On-device analysis toggles, no cloud dependencies, no message/content access
- **Onboarding Flow** — Animated splash → feature highlights → profile creation with smooth transitions

## 📐 Architecture

```
Zeen/
├── ZeenApp.swift                  # App entry, environment injection
├── Models/
│   ├── UserModels.swift           # UserProfile (Codable)
│   └── DriftModels.swift          # Score, Level, Factor, Timeline, Insight, Trend models
├── Services/
│   ├── DriftScoringService.swift  # Scoring engine + insight generation + trend detection
│   └── MockDataProvider.swift     # ZeenDataProviding protocol + mock implementation
├── ViewModels/
│   ├── DashboardViewModel.swift   # Daily/weekly data, insights, trend state
│   └── SessionViewModel.swift     # Auth, profile persistence (UserDefaults)
├── DesignSystem/
│   └── ZeenTheme.swift            # Colors, gradients, animations, GlassBackground
└── Views/
    ├── AppRootView.swift          # Splash → Auth → Main flow controller
    ├── RootTabView.swift          # Tab navigation
    ├── Components/
    │   ├── GlassCard.swift        # Glass card with staggered appear animation
    │   ├── ScoreRing.swift        # Angular gradient ring with counting animation
    │   ├── TimelineBar.swift      # Animated bar with gradient fill
    │   ├── StatCard.swift         # Compact metric card
    │   ├── InsightBanner.swift    # Tone-colored insight display
    │   ├── FactorRow.swift        # Factor with animated progress bar
    │   └── ZeenTextField.swift    # Themed text input
    └── Screens/
        ├── SplashView.swift       # Animated brand reveal
        ├── AuthView.swift         # Onboarding + profile creation
        ├── TodayView.swift        # Dashboard with greeting, ring, stats, insights, factors
        ├── TimelineScreen.swift   # Area chart + bar breakdown + attention notes
        ├── WeeklyInsightsView.swift # Trend badge, chart, streaks, deep focus bars
        └── SettingsView.swift     # Profile, privacy, data sources, about
```

## 🚀 How to Run

1. Open `Zeen.xcodeproj` in Xcode 15+.
2. Set minimum deployment target to **iOS 17+**.
3. Build and run on simulator or device.

## 🔌 Production Integration

For real data, wire `ZeenDataProviding` to:

- **FamilyControls / DeviceActivity** — Screen Time–style usage signals
- **Focus status** — System focus mode transitions
- **Notification metadata** — Interruption patterns (no content accessed)

## 📝 Design Principles

- **Attention quality > screen time** — The score reflects fragmentation, not duration
- **On-device by default** — No cloud, no accounts, no data leaving the phone
- **Adaptive insights** — Context-aware analysis that learns your patterns
- **Ambient, not anxious** — The UI should reduce cognitive load, not add to it
