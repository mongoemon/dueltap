# Gameplay Configuration Reference

This document explains all configurable gameplay parameters in the DuelTap project. All values are loaded from CSV files in the `assets/` directory. Edit these files to tune the game without changing code.

---

## 1. `assets/battle.csv` — **Global Gameplay Parameters**
| Parameter                  | Example | Description |
|----------------------------|---------|-------------|
| auto_attack_min            | 1       | Minimum possible auto-attack damage. |
| auto_attack_max            | 999     | Maximum possible auto-attack damage. |
| auto_attack_interval       | 0.7     | Seconds between auto-attack gauge increments. Lower = faster auto-attacks. |
| auto_attack_decay          | 2       | Decay per increment for auto-attack gauge. Higher = gauge fills slower over time. |
| auto_attack_gauge_max      | 100     | Value at which auto-attack gauge is full. |
| heal_amount                | 18      | Default HP restored by heal. |
| special_attack_multiplier  | 2.5     | Multiplier for special attack damage. |
| shield_duration            | 7       | Seconds shield lasts. |
| shield_reduction           | 0.6     | Percent damage reduced by shield (0.6 = 60%). |
| stamina_gauge_factor       | 10      | Multiplier for stamina to gauge fill. |
| exhaust_cost_percent       | 8       | Percent of max exhaust gauge depleted per tap attack (if not overridden by character). |
| exhaust_recovery_slow      | 2       | Exhaust recovery per tick when below cost. |
| exhaust_recovery_normal    | 25      | Exhaust recovery per tick when above cost. |
| max_exhaust_gauge          | 120     | Default max exhaust gauge (overridden by character if set). |
| max_gauge                  | 100     | Max value for player/opponent gauge. |
| max_attack_gauge           | 100     | Max value for opponent attack gauge. |
| max_player_attack_gauge    | 100     | Max value for player attack gauge. |
| max_shield_gauge           | 100     | Max value for shield gauge. |
| player_recovery_points     | 2       | Number of times player can heal per battle. |
| opponent_recovery_points   | 2       | Number of times opponent can heal per battle. |
| shield_deplete_per_tick    | 14      | Shield gauge depleted per tick. |
| evade_chance_per_speed     | 0.025   | Evade chance per speed point (e.g., 0.025 = 2.5% per point). |
| max_evade_chance           | 0.45    | Maximum evade chance (0.45 = 45%). |
| crit_chance                | 0.13    | Chance for critical hit (0.13 = 13%). |
| crit_multiplier            | 2.3     | Critical hit damage multiplier. |
| miss_chance                | 0.04    | Chance to miss (0.04 = 4%). |
| rng_seed                   | 42      | Seed for deterministic RNG (optional). |

---

## 2. `assets/characters.csv` — **Per-Character Stats**
| Column                | Example (Warrior) | Description |
|-----------------------|-------------------|-------------|
| name                  | Warrior           | Character name. |
| auto_attack           | 22                | Auto-attack power (used for gauge/auto attacks). |
| tap_attack            | 14                | Tap/manual attack power. |
| defense               | 8                 | Reduces incoming damage. |
| speed                 | 4                 | Affects evade chance and gauge fill. |
| stamina               | 7                 | Affects auto-attack gauge fill speed. |
| strength              | 3                 | Reduces incoming damage as a percent. |
| hp                    | 120               | Maximum health points. |
| exhaust               | 140               | Max exhaust gauge (limits tap attacks). |
| exhaust_cost_percent  | 8                 | Percent of exhaust gauge depleted per tap attack. |
| exhaust_recovery_slow | 2                 | Exhaust recovery per tick when below cost. |
| exhaust_recovery_normal| 25                | Exhaust recovery per tick when above cost. |
| tap_attack_cooldown   | 0.7               | Cooldown (seconds) between tap attacks for this character. |

---

## 3. `assets/skills.csv` — **Skill Definitions**
| Column         | Example         | Description |
|---------------|-----------------|-------------|
| character     | Warrior         | Character this skill belongs to. |
| skill_name    | Iron Smash      | Name of the skill. |
| cooldown      | 2               | Cooldown (seconds) before skill can be used again. |
| multiplier    | 2.8             | Damage multiplier for the skill. |
| effect_type   | stun            | Type of effect (e.g., stun, aoe, defense_buff, shield, heal, speed_buff). |
| effect_value  | 1               | Value for the effect (e.g., turns stunned, shield amount, heal amount). |
| description   | High-damage...  | Description of the skill. |

---

## 4. `assets/status_effects.csv` — **Buffs, Debuffs, Status Effects**
| Column      | Example      | Description |
|-------------|-------------|-------------|
| effect_name | stun        | Name of the effect. |
| duration    | 1           | Duration (turns or seconds) of the effect. |
| strength    | 0           | Strength of the effect (e.g., % for buffs, amount for shield/heal). |
| stackable   | false       | Can this effect stack? (true/false) |
| description | ...         | Description of the effect. |

---

## 5. `assets/combo.csv` — **Combo/Chain/Charge Mechanics**
| Column      | Example      | Description |
|-------------|-------------|-------------|
| combo_name  | basic_combo | Name of the combo/chain/charge mechanic. |
| threshold   | 2           | Number of actions to trigger the combo. |
| multiplier  | 1.7         | Damage multiplier when combo is triggered. |
| bonus_type  | extra_damage| Type of bonus (e.g., extra_damage, stun). |
| bonus_value | 15          | Value of the bonus (e.g., extra damage, turns stunned). |
| description | ...         | Description of the combo mechanic. |

---

## 6. `assets/ai.csv` — **Enemy/AI Behavior**
| Column          | Example | Description |
|-----------------|---------|-------------|
| character       | Warrior | Character this AI config applies to. |
| aggression      | 8       | How aggressive the AI is (higher = more aggressive). |
| skill_usage_freq| 4       | How often the AI uses skills (higher = more frequent). |
| target_priority | player  | Who the AI prefers to target (player, random, etc.). |
| description     | ...     | Description of the AI's behavior. |

---

## How to Use
- Edit the CSV files in `assets/` to tune gameplay.
- All changes are hot-reloadable (just restart the app if you change assets).
- Use these parameters to balance, experiment, and create your ideal game feel. 