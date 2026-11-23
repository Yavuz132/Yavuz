# Recon map: Dream League Soccer 2020 (Android / iOS mobile game)

Scope: core loop = build a club, play 3D football matches against AI in a
division ladder, earn coins, upgrade squad and stadium. Online mode and
licensed content are out of scope for v1.
For: the user's own project (assumed: a rebrandable, original football game).
Date: 2026-11-23

Status: first pass from public sources only. Screens and flows below are
INFERRED from the store description and public walkthrough/guide pages.
Replace guesses with real observations once the user walks through their own
copy of the game (or a screenshot set) with me.

## Sources

| # | source | URL | notes |
| --- | --- | --- | --- |
| 1 | Softonic download page | https://dream-league-soccer-2020.softonic.com.tr/android/download | blocked automated read (HTTP 406). Not used. |
| 2 | Official store description (as quoted in a public walkthrough video) | https://www.youtube.com/watch?v=2O9RXq2EukI | feature list, 8 divisions, stadium, coaches, online mode, kit customisation |
| 3 | Walkthrough video, tutorial + first match + stadium management (20:34) | https://www.youtube.com/watch?v=2O9RXq2EukI | flow evidence; not yet watched frame by frame |
| 4 | Dream League Soccer guide (controls, training mode, team development) | https://www.scribd.com/document/608932922/Dream-League-Soccer-Guide | covers a later edition (2022); controls likely similar |
| 5 | Manager/Career mode overview | https://www.facebook.com/fb-answers/dream-league-soccer-manager-mode/ | later edition; low confidence for 2020 |

## Core loop

Play a match, win coins and division progress, spend coins on players,
coaches and stadium upgrades, then play the next match.

## Screens

| ID | screen | route / how to reach | purpose | key components | states seen |
| --- | --- | --- | --- | --- | --- |
| S01 | Splash / loading | app launch | load assets | logo, progress bar | loading |
| S02 | Tutorial / first match | first launch | teach controls, play intro match | on-screen controls, hints | guess |
| S03 | Main menu / hub | after tutorial | entry to every section | tabs: play, team, club, store, settings | guess |
| S04 | Season / division screen | hub > play | pick next fixture, see division table | fixtures list, league table, division badge | guess |
| S05 | Pre-match / lineup | before kickoff | choose formation, check squad | pitch view, player cards | guess |
| S06 | Match (3D) | kickoff | gameplay | pitch, virtual joystick, pass / shoot / sprint buttons, score, timer, pause | playing, paused, half time, full time |
| S07 | Match result | after match | outcome, rewards | score, stats, coin reward | win, draw, loss |
| S08 | Squad / team management | hub > team | view players, lineup, formation | player list, player card, ratings | guess |
| S09 | Player detail | team > player | see ratings, contract, coach upgrade | stat bars, level | guess |
| S10 | Transfer market | hub > team | sign / release players | player list, price, buy button | guess |
| S11 | Coaches | hub > club | develop technical and physical abilities | coach cards, upgrade button | guess |
| S12 | Stadium / facilities | hub > club | upgrade stadium, medical, commercial, training | facility cards, cost, upgrade | evidenced (video 20:34) |
| S13 | Customise club (kit and logo) | hub > club | edit kit and badge | colour pickers, templates, import | evidenced (store text) |
| S14 | Customise manager | hub > club | hairstyle, outfit | option carousel | evidenced (store text) |
| S15 | Online mode / leaderboards | hub > play | ranked matches, global leaderboard | rank, prizes | OUT OF SCOPE v1 |
| S16 | Events | hub > play | timed events with prizes | event cards, timer | evidenced (store text) |
| S17 | Training mode | hub > play | practise controls | pitch, drills | evidenced (guide) |
| S18 | Settings | hub | audio, controls, language, graphics | toggles, sliders | guess |

## Flows

```
F01 First launch to first win
    S01 -> S02 -> S06 -> S07 -> S03
    happy path clicks: ~3 menu taps, then a full match
    edge: skip tutorial, app backgrounded mid-match, loss in the tutorial

F02 Play next league match
    S03 -> S04 -> S05 -> S06 -> S07 -> S04
    edge: half time, pause and quit mid-match (forfeit?), draw

F03 Sign a player
    S03 -> S08 -> S10 -> S09 -> back to S08
    edge: not enough coins, squad full, release a player first

F04 Upgrade stadium or coach
    S03 -> S12 (or S11) -> confirm
    edge: not enough coins, max level

F05 Customise kit
    S03 -> S13 -> save -> kit appears in S05 and S06
    edge: imported custom image (needs upload and validation)

F06 Promotion
    S07 -> S04 (new division) after enough wins
    edge: relegation rules unknown

F07 Events
    S03 -> S16 -> match -> reward in S07
```

## Components

| component | variants | states | used on |
| --- | --- | --- | --- |
| Button | primary, secondary, icon | default, pressed, disabled | all |
| Virtual joystick | movement | idle, active | S06 |
| Action buttons | pass, shoot, sprint, cross (inferred) | default, pressed, cooldown | S06 |
| Player card | compact, detailed | normal, selected, injured (guess) | S05, S08, S09, S10 |
| Rating bar | attributes | n/a | S09 |
| League table | n/a | highlighted own team | S04 |
| Currency chip | coins | n/a | S03, S10, S11, S12 |
| Facility card | stadium, medical, commercial, training | locked, upgradable, max | S12 |
| Modal | confirm, reward | n/a | all |
| Kit preview | home, away | n/a | S13 |

## Inferred data model

```
Club        id, name, kit (colours, pattern, badge), manager_look, coins, division, stadium_level
            evidence: S13, S14, S12. confidence: high

Player      id, name, position, ratings (pace, shooting, passing, defending, physical, gk), age
            evidence: S08/S09, store text "develop technical and physical". confidence: medium
            note: the original uses licensed real players. The clone uses fictional ones.

SquadSlot   club_id, player_id, formation_slot
            confidence: medium

Division    id, tier (1..8), name, teams
            evidence: store text "8 divisions". confidence: high

Fixture     id, season, division_id, home_club, away_club, score, played_at
            confidence: medium

Coach       id, type (technical | physical), level
            evidence: store text. confidence: medium

Facility    club_id, type (stadium | medical | commercial | training), level
            evidence: store text, video 20:34. confidence: high

Event       id, name, window, reward
            confidence: guess
```

Relationships: Club 1-n SquadSlot, Player 1-n SquadSlot, Club 1-n Facility,
Club 1-n Coach, Division 1-n Fixture, Club 1-n Fixture.

## Feature matrix

See `features.csv`. Must: 11, should: 7, could: 3, skip: 4.

## Out of scope (cannot or should not be cloned)

- FIFPro-licensed real players (3,500+), real names, likenesses: licensed. Use fictional players.
- Real club names, kits, badges, stadiums: trademarks. Use fictional clubs.
- Commentary recordings, licensed music (named bands in the store text): owned content.
- Dream League Online mode, global leaderboards, matchmaking: needs a network of players and a server. Revisit after v1.
- The original's art, animations and motion-capture data.

## Size

Screens 18 (17 in scope), flows 7, entities 8. Hard parts: real-time 3D match
gameplay and player AI (teammates, opponents, goalkeepers), touch controls
that feel right, mobile performance. Size: L if 3D (Unity or Godot). M if
2D top-down in the browser or with a 2D engine. Recommend deciding this at
architect time.
