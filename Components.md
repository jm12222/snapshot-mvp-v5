# FDS Component Library

This document lists all Facebook Design System (FDS) components in the prototype, organized by the taxonomy defined in `Sources/Resources/PrototypeSettings.swift`.

Each entry includes the user-facing name shown in the prototype's Components menu and the Swift source file that implements it.

---

## Navigation
*How users move between screens*

| Component | Source File |
|---|---|
| Navigation Bar | `Sources/Components/FDSNavigationBar.swift` |
| Sub-Navigation Bar | `Sources/Components/FDSSubNavigationBar.swift` |
| Tab Bar | `Sources/Components/FDSTabBar.swift` |

---

## Actions
*How users take action*

| Component | Source File |
|---|---|
| Buttons & Chips | `Sources/Components/FDSButton.swift`, `Sources/Components/FDSActionChip.swift`, `Sources/Components/FDSInfoChip.swift` |
| Icon Buttons | `Sources/Components/FDSIconButton.swift` |
| Selection Cell | `Sources/Components/FDSSelectionCell.swift` |
| Reaction Bar | `Sources/Components/FDSReactionBar.swift` |

---

## Content
*What users see*

| Component | Source File |
|---|---|
| List Cell | `Sources/Components/FDSListCell.swift` |
| Notification Cell | `Sources/Components/FDSNotificationCell.swift` |
| Unit Header | `Sources/Components/FDSUnitHeader.swift` |
| Text Pairing | `Sources/Components/FDSTextPairing.swift` |
| Comment | `Sources/Components/FDSComment.swift` |
| Divider | `Sources/Components/FDSDivider.swift` |

---

## Identity & Media
*People, entities, and visual content*

| Component | Source File |
|---|---|
| Profile Photo | `Sources/Components/FDSProfilePhoto.swift` |
| Facepile | `Sources/Components/FDSFacepile.swift` |
| Media Card | `Sources/Components/FDSMediaCard.swift` |
| Asset Lockup | `Sources/Components/FDSAssetLockup.swift` |
| Action Tile | `Sources/Components/FDSActionTile.swift` |

---

## Feedback & Status
*System communicating state to the user*

| Component | Source File |
|---|---|
| Contextual Message | `Sources/Components/FDSContextualMessage.swift` |
| Tooltip | `Sources/Components/FDSTooltip.swift` |
| Badge | `Sources/Components/FDSBadge.swift` |
| Confirmation Dialogues (Toasts) | `Sources/Components/FDSInstantFeedback.swift` |
| Progress | `Sources/Components/FDSProgressBar.swift` |
| Glimmer (Loading) | `Sources/Components/FDSGlimmer.swift` |

---

## Inputs & Surfaces
*Data entry and overlay containers*

| Component | Source File |
|---|---|
| Text Input | `Sources/Components/FDSTextInput.swift` |
| Search Bar | `Sources/Components/FDSSearchBar.swift` |
| Bottom Sheet | `Sources/Components/FDSBottomSheet.swift` |
| Share Sheet | `Sources/Components/FDSShareSheet.swift` |

---

## Utility / Internal
*Supporting components and managers — not surfaced in the Components menu*

| Component | Source File | Purpose |
|---|---|---|
| FDSPressedState | `Sources/Components/FDSPressedState.swift` | Shared button-style for pressed-state behavior |
| DrawerContainer | `Sources/Components/DrawerContainer.swift` | Drawer presentation container |
| DrawerStateManager | `Sources/Components/DrawerStateManager.swift` | Drawer state management |
| DemoModePicker | `Sources/Components/DemoModePicker.swift` | Demo concept picker for prototype settings |
| FDSReactionBarPreview | `Sources/Components/FDSReactionBarPreview.swift` | Preview view for the Reaction Bar gallery |
| FDSShareSheetPreview | `Sources/Components/FDSShareSheetPreview.swift` | Preview view for the Share Sheet gallery |
| FDSTabBarPreview | `Sources/Components/FDSTabBarPreview.swift` | Preview view for the Tab Bar gallery |

---

_Source of truth for the taxonomy: `Sources/Resources/PrototypeSettings.swift` → `ComponentsView`._
