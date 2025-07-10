# Combat Widgets Overview

This document summarizes the main combat UI widgets for player and opponent columns in the combat feature.

## PlayerColumn

**Purpose:**
Displays the player's character info, stats, action buttons, skill buttons, and visual feedback for combat events (damage, heal, miss).

**Main Sub-widgets:**
- `PlayerAvatar`: Shows the player's avatar and name.
- `PlayerStats`: Displays HP, ATK, DEF, SPD, STA, STR.
- `PlayerAutoAttackRow`: Displays the auto-attack gauge, which fills automatically based on the player's stamina. When the gauge reaches 100, the player automatically attacks the opponent with their ATK value, and the gauge resets to 0. The gauge then refills from stamina. The gauge turns green and bold when full to indicate an imminent auto-attack.
- `PlayerActionButtons`: Renders Attack, Heal, Special, and Shield buttons.
- `PlayerSkillButtonsRow`: Displays the skill buttons row.
- **Visual Feedback:**
  - Red number for damage (`showDamage`, `damageAmount`)
  - Blue number for heal (`showHeal`, `healAmount`)
  - Gray "Miss" indicator (`showMiss`)

## OpponentColumn

**Purpose:**
Displays the opponent's character info, stats, action buttons, skill buttons, and visual feedback for combat events (damage, heal, miss).

**Main Sub-widgets:**
- `OpponentAvatar`: Shows the opponent's avatar and name.
- `OpponentStats`: Displays HP, ATK, DEF, SPD, STA, STR.
- `OpponentAutoAttackRow`: Shows the auto-attack gauge if applicable.
- `OpponentActionButtons`: Renders Attack, Heal, and Special buttons.
- `OpponentSkillButtonsRow`: Displays the skill buttons row.
- **Visual Feedback:**
  - Red number for damage (`showDamage`, `damageAmount`)
  - Blue number for heal (`showHeal`, `healAmount`)
  - Gray "Miss" indicator (`showMiss`)

## Usage

Both columns are used in the combat screen to represent the player and opponent, providing interactive controls and real-time feedback for combat actions.

---

**Note:**
- All sub-widgets are kept small and focused for maintainability.
- Visual feedback overlays are implemented using a `Stack` and `AnimatedOpacity` for smooth appearance/disappearance.
- Avatar widgets use a placeholder icon; replace with actual character images as needed. 