# Architecture: personal 2D football game (a rebuild of Dream League Soccer's core loop)

For personal use, runs in the browser (desktop and phone), fully offline,
no accounts, no server. Fictional players and clubs. All art and audio are
original or open-licensed.

## Stack

| layer | choice | why |
| --- | --- | --- |
| language | TypeScript (strict) | types catch most match-logic bugs |
| build | Vite | zero-config dev server, static build |
| rendering | HTML5 Canvas 2D, own thin renderer | top-down 2D needs no engine; keeps bundle tiny |
| game loop | fixed 60 Hz simulation step, rendered with requestAnimationFrame | deterministic match logic, testable without a screen |
| UI (menus) | plain DOM + CSS (tokens from replica-design) | menus are forms and lists, not canvas |
| input | Pointer Events: virtual joystick + buttons on touch, keyboard on desktop | one code path for both |
| persistence | IndexedDB (via `idb-keyval`), JSON save with a version number | offline, survives reloads; localStorage is too small |
| audio | Web Audio API, original or CC0 sounds | no licensed music |
| tests | Vitest for logic, Playwright for UI flows | see replica-test |
| hosting | none needed. `vite build` gives static files. Optional: GitHub Pages | personal use |
| backend, auth, payments, email, jobs | none | no accounts, no money, no network features in v1 |

No microservices, no database server. The clone does not need the original's
architecture, only its features. Online mode (S15) is skipped, so there is no
backend to plan.

## Schema

No SQL. Data is one `SaveGame` JSON object in IndexedDB. Access rules: none
(single local user). Static reference data (players, clubs, divisions) is
generated from a seed on first run, so it is fictional and reproducible.

```ts
type Position = 'GK' | 'DF' | 'MF' | 'FW';

interface Player {
  id: string;
  name: string;            // generated, fictional
  position: Position;
  age: number;
  // ratings 1..99, drive match outcomes
  pace: number; shooting: number; passing: number;
  defending: number; physical: number; goalkeeping: number;
  clubId: string | null;   // null = free agent / on the market
  price: number;           // coins
}

interface Club {
  id: string; name: string;
  kit: { home: Kit; away: Kit };
  badge: BadgeSpec;        // shapes and colours drawn in code
  isUser: boolean;
  divisionId: number;
}

interface Kit { primary: string; secondary: string; pattern: 'plain' | 'stripes' | 'hoops' | 'sash'; }

interface Lineup { formation: '4-4-2' | '4-3-3' | '3-5-2' | '4-2-3-1'; slots: (string | null)[]; } // 11 player ids

interface Division { id: number; tier: number; name: string; clubIds: string[]; } // tier 1..8

interface Fixture {
  id: string; season: number; divisionId: number; round: number;
  homeId: string; awayId: string;
  result: { home: number; away: number } | null;
}

interface Coach { type: 'technical' | 'physical'; level: number; }       // level 0..5
interface Facility { type: 'stadium' | 'medical' | 'commercial' | 'training'; level: number; }

interface SaveGame {
  version: number;                 // migrations by version
  seed: number;                    // for reproducible generation
  coins: number;
  season: number;
  userClubId: string;
  manager: { hair: number; outfit: number };
  players: Player[]; clubs: Club[]; divisions: Division[]; fixtures: Fixture[];
  lineup: Lineup; coaches: Coach[]; facilities: Facility[];
  settings: { sound: boolean; controls: 'joystick' | 'keyboard'; language: string };
}
```

Hard constraints (enforced in the data layer, checked by tests):

- A lineup has exactly 11 distinct players, exactly 1 GK, all from the user's club.
- Coins never go negative. Every spend goes through one `spend(amount)` function.
- A fixture is played once. Re-playing a played fixture is rejected.
- Squad size has a min and max. Release is blocked below the minimum.
- Save writes are atomic: write the new object, then swap the key.

## Modules (replaces the API section)

No HTTP routes. The boundary is a set of modules, one per flow.

| module | does | called by | flow |
| --- | --- | --- | --- |
| `sim/match.ts` | runs one match step by step: ball, players, rules, score, clock | S06 | F01, F02, F07 |
| `sim/ai.ts` | decides for each non-controlled player and the GK each tick | match.ts | F02 |
| `sim/quick.ts` | resolves a match from ratings without rendering (for AI vs AI fixtures) | season.ts | F02 |
| `input/controls.ts` | joystick, buttons, keyboard to a `PlayerInput` struct | S06 | F01, F02 |
| `render/pitch.ts` | draws pitch, players, ball, HUD | S06 | F01, F02 |
| `game/season.ts` | fixtures, table, promotion, rewards | S04, S07 | F02, F06 |
| `game/team.ts` | lineup, formation, sign / release, ratings | S05, S08-S10 | F03 |
| `game/club.ts` | coaches, facilities, kit, manager, upgrade costs | S11-S14 | F04, F05 |
| `game/economy.ts` | `earn()`, `spend()`, price and reward tables | all | F02-F04 |
| `game/generate.ts` | seeded generation of clubs, players, divisions | first run | F01 |
| `store/save.ts` | load, save, migrate, reset | everything | all |
| `ui/*` | DOM screens S01-S18 | router | all |

Jobs and webhooks: none. Season rollover runs when the last fixture is played.

## The parts that bite

- **Match AI is the hardest part.** Start with simple steering: each player has
  a home position from the formation, shifts with the ball, the nearest player
  chases, the ball carrier chooses pass / shoot / dribble by simple rules.
  Tune with parameters, not special cases.
- **Determinism.** Fixed time step plus a seeded random number generator
  (`mulberry32`). Then a match is replayable from a seed, which makes bugs
  reproducible and tests possible.
- **Touch controls feel.** Joystick dead zone, button size 48px or more, no
  accidental page scroll or zoom (`touch-action: none`), multi-touch for
  joystick plus buttons together. Needs a real phone to judge.
- **Performance on phones.** Draw at device pixel ratio but cap it, reuse
  objects, no allocations in the game loop, pause when the tab is hidden.
- **Backgrounding mid-match.** Auto-pause on `visibilitychange`. Never resume
  on its own.
- **Save corruption.** Versioned schema, migrate on load, keep one backup copy
  of the previous save, offer reset.
- **Balance.** Coin rewards, prices and upgrade costs live in one tuning
  table, not in the code, so they can be changed without touching logic.
- **Audio autoplay.** Browsers block sound until the first tap. Start audio on
  the first user gesture.
- **Clean room.** Names, badges, kits, sounds are all generated or original.
  `replica-brand` is skipped (personal use), but keep real names out anyway.

## Build order

1. **Vertical slice** (S06, S07, S03): one match between two generated teams.
   Pitch, ball, 11 vs 11 with simple AI, joystick plus pass / shoot, score,
   clock, final whole-match result screen, save coins. Proves the loop and the
   controls. Touches: `sim`, `render`, `input`, `store`. No season yet.
2. **Must-haves, by area:**
   - match: GK AI, rules (kickoff, half time, throw-ins, goal kicks), result
     screen and reward (S06, S07).
   - season: divisions, fixtures, table, promotion (S04, S07).
   - team: lineup, formation, ratings affect outcome (S05, S08, S09).
   - economy: earn and spend (S03).
3. **Should-haves:** transfer market (S10), coaches (S11), facilities (S12),
   kit and badge editor (S13), manager look (S14), tutorial (S02), training
   mode (S17), settings (S18).
4. **Could-haves:** commentary text, events (S16), custom kit image import.
5. **Fixes from replica-entrepreneur:** skipped by choice (personal use).
   Optional later: read what players dislike in the original (grind, ads,
   pay-to-win) and leave those out.

## Decisions to confirm

- 2D top-down in the browser (assumed). Change to Godot or Unity if you want 3D.
  That would roughly triple the match work and change this document's stack.
- Offline single-player only. No online mode.
