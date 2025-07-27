# 📱 Earn It - Screen Time API Implementation

## Overview

This implementation follows the technical realization strategy from `overview.md` to integrate Apple's Screen Time API for real app blocking functionality. The MVP includes full Screen Time integration with:

- ✅ Family Controls authorization
- ✅ Real app selection using FamilyActivityPicker
- ✅ ManagedSettings for blocking/unblocking apps
- ✅ DeviceActivity monitoring for background operation
- ✅ Custom shield UI with branded experience
- ✅ URL scheme redirection from shield to main app
- ✅ App Groups for data sharing between extensions

## 🏗️ Architecture

### Core Components

1. **ScreenTimeManager** - Main manager for Screen Time API integration
2. **DeviceActivityMonitorExtension** - Background monitoring (needs separate target)
3. **ShieldConfigurationDataSource** - Custom shield appearance (needs separate target)
4. **ShieldActionDelegate** - Shield button interactions (needs separate target)
5. **FamilyActivityPickerView** - Real app selection interface
6. **ProofSubmissionView** - Habit completion from shield redirection

### Data Flow

```
User selects apps → FamilyActivityPicker → ScreenTimeManager stores selection
       ↓
ScreenTimeManager applies ManagedSettings blocking
       ↓
DeviceActivityMonitor detects app access attempts
       ↓
Shield shown with custom UI (ShieldConfiguration)
       ↓
User taps "Complete Habits" → ShieldActionDelegate → URL scheme redirect
       ↓
Main app opens ProofSubmissionView → User completes habit
       ↓
ScreenTimeManager clears blocking → Apps unlocked
```

## 🛠️ Setup Instructions

### 1. Xcode Project Configuration

**App Groups:**
- Add App Group capability to main target: `group.com.earnit.app`
- This enables data sharing between main app and extensions

**Entitlements:**
- Family Controls: `com.apple.developer.family-controls` ✅ (already added)
- App Groups: `group.com.earnit.app` ✅ (already added)

### 2. Required Extension Targets

⚠️ **IMPORTANT**: The following files need to be moved to separate extension targets:

#### DeviceActivityMonitorExtension Target
- Create new "Device Activity Monitor Extension" target
- Move `DeviceActivityMonitorExtension.swift` to this target
- Add Family Controls capability
- Add App Group: `group.com.earnit.app`
- Set principal class: `EarnitDeviceActivityMonitor`

#### ShieldConfigurationExtension Target
- Create new "Shield Configuration Extension" target  
- Move `ShieldConfigurationExtension.swift` to this target
- Add Family Controls capability
- Add App Group: `group.com.earnit.app`
- Set principal class: `EarnitShieldConfigurationDataSource`

#### ShieldActionExtension Target
- Create new "Shield Action Extension" target
- Move `ShieldActionExtension.swift` to this target
- Add Family Controls capability
- Add App Group: `group.com.earnit.app`
- Set principal class: `EarnitShieldActionDelegate`

### 3. Project Configuration

**URL Scheme Setup:**
- In Xcode, go to your target's **Info** tab
- Under **URL Types**, add a new URL Type:
  - **Identifier**: `com.earnit.app.urlscheme`
  - **URL Schemes**: `earnit`

**Privacy Permissions:**
- Add these keys to your target's build settings or Info tab:
  - **Camera Usage Description**: "Earn It needs camera access to let you take photos as proof of completing your daily habits."
  - **Photo Library Usage Description**: "Earn It needs photo library access to let you select photos as proof of completing your daily habits."

### 4. Bundle ID Requirements

Ensure bundle IDs follow Apple's convention:
- Main app: `com.yourcompany.earnit`
- DeviceActivity extension: `com.yourcompany.earnit.deviceactivity`
- Shield config extension: `com.yourcompany.earnit.shieldconfig`
- Shield action extension: `com.yourcompany.earnit.shieldaction`

## 🔧 Implementation Details

### Modern Screen Time API (iOS 15+)

⚠️ **Important**: This implementation uses the current Screen Time API:
- `ShieldActionDelegate` (base class for handling shield actions)
- `ShieldConfigurationDataSource` (base class for configuring shield appearance)

These classes provide the functionality for customizing the shield that appears when apps are blocked.

### Authorization Flow

1. User starts onboarding
2. App requests Family Controls authorization with biometric prompt
3. User grants permission
4. App can now use Screen Time APIs

### App Selection Process

1. User taps "Select Real Apps" in onboarding
2. System's FamilyActivityPicker opens
3. User selects apps/categories to guard
4. Selection stored as opaque tokens in App Groups
5. DeviceActivity monitoring starts for selected apps

### Blocking Mechanism

1. ManagedSettingsStore applies shields to selected apps
2. When user tries to open blocked app, custom shield appears
3. Shield shows "Time to Earn It!" message with branded UI
4. User taps "Complete Habits" → redirects to main app

### Habit Completion Flow

1. Main app opens to ProofSubmissionView (from URL scheme)
2. User selects which habit to complete
3. PhotoCaptureView opens for proof submission
4. Upon completion, all apps automatically unlock
5. Shield updates to show "Unlocked!" state

## 📱 User Experience

### Onboarding Steps

1. **Welcome** - App introduction and value proposition
2. **Add Habits** - User creates daily habits
3. **Authorization** - Request Screen Time permissions
4. **App Selection** - Choose apps to guard using system picker
5. **Complete** - Setup finished, monitoring begins

### Daily Flow

1. User tries to access guarded app
2. Custom shield appears: "Time to Earn It!"
3. User taps "Complete Habits"
4. Main app opens showing incomplete habits
5. User selects habit and submits photo proof
6. All apps unlock immediately
7. Next day: habits reset, apps re-lock

## 🔍 Testing & Debugging

### Debug Information

The implementation includes extensive logging:
- Authorization status changes
- App selection events
- Monitoring start/stop
- Shield interactions
- Habit completion events

### Common Issues

1. **Monitoring stops working**: Call `restartMonitoring()` in ScreenTimeManager
2. **Shield not appearing**: Check authorization and app selection
3. **URL scheme not working**: Verify Info.plist configuration
4. **Apps not blocking**: Ensure ManagedSettings is properly configured

### Demo Mode

The app includes a "ScreenTime Demo" tab that simulates the blocking experience without real Screen Time API for testing purposes.

## 📝 Key Files

- `ScreenTimeManager.swift` - Core Screen Time API integration
- `FamilyActivityPickerView.swift` - Real app selection interface
- `ProofSubmissionView.swift` - Habit completion from shield
- `DeviceActivityMonitorExtension.swift` - Background monitoring
- `ShieldConfigurationExtension.swift` - Custom shield appearance (ShieldConfigurationDataSource)
- `ShieldActionExtension.swift` - Shield button handling (ShieldActionDelegate)
- `earnit.entitlements` - App capabilities

## 🚀 Deployment Notes

1. **App Store Review**: Screen Time API requires special approval
2. **Entitlement Request**: Submit detailed explanation of app's purpose
3. **Testing**: Test on physical device (Screen Time API doesn't work in simulator)
4. **Extensions**: Ensure all extension targets are included in build

## 🔄 Future Enhancements

1. **Timed Unlocks**: Unlock apps for specific duration after habit completion
2. **Advanced Scheduling**: Different habits for different days
3. **Category Blocking**: Block entire categories instead of individual apps
4. **Web Domain Blocking**: Block websites in addition to apps
5. **Analytics**: Track habit completion rates and app usage patterns

---

This implementation provides a solid foundation for the "Earn It" app's core functionality while following Apple's Screen Time API best practices. 