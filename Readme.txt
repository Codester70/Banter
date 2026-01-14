Banter

Contextual in-game /say banter with a single button and macro-callable combat callouts.

Banter lets your character speak short, appropriate lines during combat and downtime — either by pressing a dedicated Speak button/keybind or by wiring banter directly into your combat macros (interrupts, attacks, defensives, etc.).

This addon is opt-in, non-spammy, and designed to feel intentional rather than automated.

✨ Features

One-click / keybind Speak button

Always says something appropriate for your current situation

Never blocked by cooldowns

Debounced to prevent accidental double-fires

Macro-callable combat banter

Attach banter to spells like interrupts, attacks, defensives, or burst cooldowns

Per-category cooldowns prevent spam

Smart context detection

Low health

In combat

Just finished a fight

Idle / out of combat

No repetition

Lines never repeat within a category until the full pool is exhausted

Movable UI

Drag the Speak button wherever you want

Position is saved between sessions

Always uses /say

Simple, predictable, immersive

🔊 How It Works (High Level)

Banter has two ways to speak:

1️⃣ Speak Button / Keybind

Press the button (or keybind)

Banter chooses the best category automatically:

Low HP → Combat → Victory → Idle

Always speaks (with a tiny debounce)

2️⃣ Macro Buttons

You call Banter from your own macros using /click

Each macro category has its own cooldown

Example: interrupt macros only speak every few seconds, no matter how often you spam the ability

🎮 Usage
Speak Button

Click the Speak button on screen
or

Bind a key to “Speak (Contextual)” in Key Bindings → AddOns → Banter

The Speak button:

Always says something

Never repeats lines until all options are used

Is safe to press whenever you want

⌨️ Macro Integration

You can add banter to your existing macros using /click.

/click Banter_SpeakButton

Interrupt
#showtooltip
/cast Kick
/click Banter_ClickInterrupt

Generic Attack
#showtooltip
/cast Crusader Strike
/click Banter_ClickAttack

Defensive Cooldown
#showtooltip
/cast Shield Wall
/click Banter_ClickDefensive

Burst Cooldown
#showtooltip
/cast Avenging Wrath
/click Banter_ClickBurst

Heal
/cast Renew
/click Banter_ClickHeal


If a category is on cooldown, nothing is said — your spell still fires normally.

🖱️ Moving the Speak Button
Unlock & Drag
/banter unlock


Drag the button anywhere on screen

/banter lock


Lock it in place

Set Position Precisely
/banter pos <x> <y>


Example:

/banter pos 300 -200


Coordinates are relative to the center of the screen.

Reset to Default
/banter reset

👀 Show / Hide the Button
/banter hide
/banter show


(The keybind still works even if the button is hidden.)

🧪 Test It
/banter test


Forces a contextual Speak without needing combat.

🔧 Slash Commands Summary
/banter show
/banter hide
/banter lock
/banter unlock
/banter pos <x> <y>
/banter reset
/banter test

⚠️ Notes & Design Decisions

Banter never speaks automatically — it only speaks when you press a button or macro

This avoids spam and stays within Blizzard’s UI rules

Lines are gender-neutral

Repetition across /reload is allowed by design

Party/response banter and tone packs are planned for future versions

🧭 Planned Features (Future)

Character-to-character responses

Tone packs (serious, snarky, heroic, etc.)

Gendered or class-specific line packs

Optional party/instance channel support

UI options panel

❤️ Credits

Designed and built by Cody, with architectural planning and implementation support from V.