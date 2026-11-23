# Architecture: personal 3D football game for Android (a rebuild of Dream League Soccer's core loop)

For personal use. Android APK built by the user in Unity. Offline, single
player, no accounts, no server. Fictional players and clubs. All art, audio
and animations are original, generated or open-licensed. Nothing is taken from
the original game's files.

Supersedes the earlier browser/2D plan (changed on the user's request).

## Stack

| layer | choice | why |
| --- | --- | --- |
| engine | Unity 2022.3 LTS | most used mobile engine, long-term support, builds Android APK |
| language | C# | Unity's language |
| render pipeline | URP (Universal Render Pipeline) | good mobile performance |
| 3D match | Unity 3D scene: pitch, ball (Rigidbody sphere), 22 players | the real game is 3D |
| character models | simple original low-poly humanoids first, replaceable later | placeholders now, art later |
| animation | Animator with a small set: idle, run, kick, tackle, GK dive, celebrate | original or open-licensed clips only |
| input | Unity Input System + on-screen stick and on-screen buttons | touch controls like the original |
| menus | UI Toolkit or uGUI with canvas scaler (portrait and landscape safe) | one UI system for all screens |
| persistence | JSON save in `Application.persistentDataPath`, versioned | offline, simple |
| audio | Unity AudioSource, original or CC0 sounds | no licensed music or commentary |
| tests | pure C# core library tested with `dotnet test` here, Unity Test Framework for scene tests on the user's machine | I can verify logic without the Editor |
| build | Unity Editor > Android (IL2CPP, ARM64), done by the user | |
| backend, auth, payments | none | offline personal game |

## Repository layout

```
game/
  Core/                      pure C# (no UnityEngine), compiled by dotnet AND Unity
    Sim/        MatchSim, PlayerAI, GoalkeeperAI, Rules, QuickSim
    Model/      Player, Club, Division, Fixture, Coach, Facility, SaveGame
    Game/       Season, Team, Club, Economy, Generator
    Store/      SaveStore, Migrations
  Core.Tests/                xUnit tests for Core, run with `dotnet test`
  UnityProject/
    Assets/Scripts/View/     MonoBehaviours that draw the Core state (players, ball, camera)
    Assets/Scripts/Input/    touch stick, buttons
    Assets/Scripts/UI/       screens S01-S18
    Assets/Scenes/           Boot, Menu, Match
    Assets/Art, Audio/       original assets only
```

Why split: match rules, AI, season and economy are plain C#, so I can build
and test them here without Unity. Unity code only reads Core state and draws
it. That keeps most of the work verifiable.

## Data model (replaces SQL)

One `SaveGame` JSON object. No database. Access rules: none (single local user).
Players, clubs and divisions are generated from a seed on first run, so they are
fictional and reproducible.

```csharp
enum Position { GK, DF, MF, FW }

class Player   { string Id, Name; Position Pos; int Age;
                 int Pace, Shooting, Passing, Defending, Physical, Goalkeeping; // 1..99
                 string ClubId; int Price; }
class Kit      { string Primary, Secondary; string Pattern; }  // plain, stripes, hoops, sash
class Club     { string Id, Name; Kit Home, Away; BadgeSpec Badge; bool IsUser; int DivisionId; }
class Lineup   { string Formation; string[] Slots; }           // 11 player ids
class Division { int Id, Tier; string Name; string[] ClubIds; } // tier 1..8
class Fixture  { string Id; int Season, DivisionId, Round; string HomeId, AwayId; Result Score; }
class Coach    { string Type; int Level; }                     // technical | physical, 0..5
class Facility { string Type; int Level; }                     // stadium | medical | commercial | training
class SaveGame { int Version; int Seed; int Coins; int Season; string UserClubId;
                 Manager Manager; List<Player> Players; List<Club> Clubs;
                 List<Division> Divisions; List<Fixture> Fixtures; Lineup Lineup;
                 List<Coach> Coaches; List<Facility> Facilities; Settings Settings; }
```

Constraints enforced in Core and covered by tests:

- A lineup has exactly 11 distinct players, exactly 1 GK, all from the user's club.
- Coins never go negative; every spend goes through `Economy.Spend`.
- A fixture is played once.
- Squad size has a minimum and a maximum.
- Save writes are atomic (write temp file, then replace) and keep one backup.

## Modules (replaces the API section)

| module | does | used by | flow |
| --- | --- | --- | --- |
| `Core/Sim/MatchSim` | fixed-step match simulation: positions, ball, rules, clock, score | Match scene | F01, F02, F07 |
| `Core/Sim/PlayerAI`, `GoalkeeperAI` | decisions for every non-controlled player each tick | MatchSim | F02 |
| `Core/Sim/QuickSim` | resolves AI vs AI fixtures from ratings, no rendering | Season | F02 |
| `Core/Game/Season` | fixtures, table, promotion, rewards | S04, S07 | F02, F06 |
| `Core/Game/Team` | lineup, formation, sign, release | S05, S08-S10 | F03 |
| `Core/Game/Club` | coaches, facilities, kit, manager, upgrade costs | S11-S14 | F04, F05 |
| `Core/Game/Economy` | earn, spend, price and reward tables (one tuning file) | all | F02-F04 |
| `Core/Game/Generator` | seeded clubs, players, divisions | first run | F01 |
| `Core/Store/SaveStore` | load, save, migrate, reset | all | all |
| `View/*` | draws MatchSim state with 3D models, camera, effects | Match scene | F01, F02 |
| `Input/*` | on-screen stick and buttons to a `PlayerInput` struct | Match scene | F01, F02 |
| `UI/*` | screens S01-S18 | router | all |

No webhooks, no jobs. Season rollover runs when the last fixture is played.

## The parts that bite

- **Match AI is the hardest part.** Formation home positions, shift with the ball,
  nearest player presses, ball carrier chooses pass, shoot or dribble by
  simple scored rules, goalkeeper positioning and dives. Tune with parameters.
- **Sim in Core, view in Unity.** `MatchSim` runs at a fixed step on its own
  coordinates. Unity interpolates models between steps. Never let physics
  decide rules. The ball can be a custom integrator in Core so results are
  deterministic and testable.
- **Determinism.** Seeded random number generator. A match is replayable from a
  seed, which makes bugs reproducible.
- **Camera and controls feel.** Broadcast-style side camera that follows the
  ball, stick dead zone, buttons 48dp or more, multi-touch for stick plus
  buttons. This needs a real phone to judge. Expect several tuning rounds.
- **Mobile performance.** Low-poly models, GPU instancing, no per-frame
  allocations, target 60 fps on a mid-range phone, cap quality settings.
- **Animation and models are the biggest art cost.** Placeholders first so the
  game is playable, art later. Only original or open-licensed assets.
- **Backgrounding mid-match.** Auto-pause on app pause. Never resume on its own.
- **Save corruption.** Versioned schema, migrate on load, one backup copy.
- **Balance.** Coin rewards, prices, upgrade costs in one tuning table.
- **Clean room.** Fictional names, own badges and kits, own audio.
  Replica's brand step is skipped for personal use, but real names stay out.
- **What I cannot verify here.** Anything that needs the Unity Editor: scenes,
  animation, touch feel, APK build. I verify Core with tests, and give the user a
  checklist for the Unity side.

## Build order

1. **Core vertical slice** (tested here): Model, Generator, MatchSim with simple
   AI, a text log or headless match that produces sensible scores, seeded and
   repeatable. Proves the logic before any 3D.
2. **Unity vertical slice** (S06, S07, S03): Boot, Menu and Match scenes, pitch,
   ball, 22 capsule players, stick plus pass and shoot, clock, score, result
   screen. The user opens it in Unity, plays in the Editor, then builds the APK.
3. **Must-haves, by area:** GK AI and rules (S06), divisions and table (S04),
   lineup and formation (S05, S08, S09), coins (S03).
4. **Should-haves:** transfer market (S10), coaches (S11), facilities (S12),
   kit editor (S13), manager look (S14), tutorial (S02), training (S17),
   settings (S18).
5. **Could-haves:** commentary text, events (S16), custom kit image import,
   better models and animation.

## Decisions made

- Unity 3D, Android, offline single player. No online mode.
- User builds the APK. I deliver the Unity project files, Core code and tests.
- Fictional content only.
