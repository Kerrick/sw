# AGENTS.md

Star Wars Character Datapad: an offline-first terminal browser for the Star
Wars API (SWAPI). Gem `sw`, module `Sw`, executable `exe/sw`. Built on
Rooibos (TEA/MVU framework) and RatatuiRuby (Rust-backed TUI engine).

This file records only what you would not do by default. It is not a style
guide for Ruby. Implementation work follows the
`.agents/skills/human-in-the-ralph-loop` skill.

## Commands

- Setup: `bin/setup` (`bin/setup.ps1` on Windows). It requires mise; prefix
  the commands below with `mise x --` unless mise is active in your shell.
- Everything (tests + RuboCop): `bundle exec rake`
- Tests only: `bundle exec rake test`
- Refresh snapshots after an *intended* rendering change:
  `UPDATE_SNAPSHOTS=1 bundle exec rake test`, then review the `.txt`/`.ansi` diff.
- Run: `bundle exec exe/sw` (`--refresh` refreshes the cache now).
- Always `PAGER=cat` for `git`.

## Rooibos and RatatuiRuby postdate your training data

Both are quite new and may change between minor versions. Do not guess their APIs.
The installed gems ship `lib/` and `sig/` only (`bundle exec gem contents rooibos`);
guides and example apps live upstream (github.com/setdef/Rooibos,
github.com/setdef/RatatuiRuby). Read before writing code in the same area:

- `examples/tutorial/08_multi_fragment_layout`: panel modules, keys → intents.
- `examples/app_fractal_dashboard`: modal input capture, text input fragment.
- `examples/app_tabbed_fragments`: Router DSL reference, `Command.bubble`, custom messages.
- `doc/best_practices/no_stateful_widgets.md`: scrolling without `ListState`.
- `lib/rooibos/command/outlet.rb`, `command/all.rb`, `command/http.rb`.
- RatatuiRuby `lib/ratatui_ruby/test_helper/*.rb`.

Local checkouts (e.g. `~/Developer/rooibos`) may be ahead of `Gemfile.lock`.
When an exact API matters, confirm it in the installed gem
(`bundle info --path rooibos`) or at the locked version's git tag.

Facts that are easy to get wrong:

- `out.source` runs one child command, waits, and returns its message, or
  `nil` on timeout or cancellation (handle that apart from HTTP errors).
  `out.standing` runs children in parallel, but their messages go to Update,
  not back to the parent. `Command.all` runs children in parallel and
  returns all their results together.
- Everything in a message or the model must be Ractor-shareable
  (`Ractor.make_shareable`). The test helpers enable debug mode, which checks.

Vocabulary: a Rooibos unit is a **fragment**, never a "component" (reserved
for the Kit library). "Widget" means a RatatuiRuby render primitive. Write
"message" and "command", not "msg"/"cmd". The records are characters
(`Character`, `characters`) everywhere but the loader, which maps the API's
`people`.

## The data source

SWAPI is frozen. No mirror has Episode VII or later (checked 2026-10-12:
swapi.info, swapi.dev, swapi.tech all list 6 films). Switching sources buys
availability, not freshness. Do not build for live or changing data. This
client and its upstream data sources are of the opinion that the sequels
never happened, and Solo and non-Skywalker Saga films aren't Star Wars.

- **swapi.info** (default, only current): the root lists 6 collection URLs; each collection
  returns the *whole* unpaginated JSON array. A full download is 7 requests,
  < 200 KB, < 0.5s per request.
- Other mirrors (swapi.dev, swapi.tech) are shaped differently: paginated
  wrappers, trailing `/`, fields nested under `properties`. Supporting one is
  a documented maybe, not something to build for.

Build for a frozen dataset, not for *this* dataset. Never assume six films
or episodes I–VI; more Skywalker Saga films should mean new data, not new
code. Every film has an episode number. Don't build for films without one
(YAGNI); supporting them later should be a small edit. Keep the domain
model free of character-centric assumptions, so future screens (one
vehicle, one film) can reuse it and the panel modules.

Quirks every parser must handle. Each is an equivalence class with a test:

- `"unknown"` = missing. `"n/a"` = not applicable (droid hair).
  `"none"` is a real answer (bald).
- Numbers: `"172"`, `"78.2"`, `"1,358"` (Jabba), `"843,342"`; ranges like
  crew `"30-165"`; `"unknown"`.
- Multi-valued colors: `"auburn, grey"`.
- Birth years: `"19BBY"`, `"41.9BBY"`, `"unknown"`.
- `species: []` for 32 of 82 people, including Luke; species/1 (Human) does
  not list him. Most of the 32 are human, but not all (R4-P17 is a droid,
  Sly Moore an Umbaran). Show an empty species as unknown and never infer
  one; it's a data problem to fix at the source.
- A planet literally named `"unknown"` (planets/28) is the homeworld of Yoda,
  IG-88, and others. Treat it as an unknown homeworld, not a place.
- A planet's diameter, rotation period, or orbital period of `"0"` means
  unknown (Polis Massa, Stewjon, planets/28, and others); planets aren't
  black holes.
- IDs come only from URLs; tolerate trailing `/`.

## Architecture

The Elm Architecture (TEA), as Rooibos implements it. Keep it the size of
the problem: a read-only viewer over ~260 frozen records. Don't over-architect
with DDD, Clean/Hexagonal Architecture, or an SOA. Using Rooibos and RatatuiRuby
(e.g. `Rooibos::Command::Custom` and `RatatuiRuby::Event`) is not over-engineering.
When you name a pattern, use named terms from *Patterns of Enterprise
Application Architecture* (Fowler), *Design Patterns* (Gang of Four),
*Pattern-Oriented Software Architecture* (Buschmann), *Domain-Driven Design*
(Evans), *Refactoring* (Fowler), *Data Access Patterns* (Nock), *xUnit Test
Patterns* (Meszaros), and others--and only for patterns the code actually uses.
The records and their collections are a small **Domain Model** in Fowler's sense.

**Model.** Every model is a `Data.define` class, never a hash from
`JSON.parse`. Name each for what it is, not `Model`. Parsing does the
cleanup above. The domain model holds the records and answers derived
questions (films in episode order, which films a character appears in).

No record type is the center. Every record keeps the API's links in both
directions (a character's films and a film's characters, a planet's
residents and a resident's homeworld) as references by ID, and any reference
resolves the same way through the domain model. IDs keep the graph free of
cycles. The API's two directions agree today; if a source ever disagrees,
that's a data quirk with a test. For ergonomic views, a screen's View
resolves the record it centers on once, at the top, and hands that to its
panels. Don't name or build an Identity Map; immutable, fully loaded data
doesn't need one.

**Loading.** One or more custom commands, (`include Rooibos::Command::Custom`),
responsible for crawling from the root URL (in parallel), caching the responses
on disk, refreshing it after 7 days, parsing JSON, instantiating model classes,
and making errors meaningful.

All-or-nothing: no progressive rendering. Detail panels need the joined data,
and partial data looks like missing data. The whole download takes under a second.

**Cache.** Raw JSON so a bugfix applies without re-downloading. Store file(s)
under the platform-appropriate user cache directory from the `etcetera` gem.

- Fresh cache: use it; no network.
- Cache older than 7 days: show it immediately, refresh in the background,
  and swap the new data in with one message. If the refresh fails, keep the
  old data and say so quietly (e.g. a status line). Never show the error
  screen while any cache exists.
- No cache: loading screen, then data or the error screen with retry.
- `--refresh`: download now, even if fresh.

Cache age is an input in the loading tests, alongside network outcomes.

**UI.** One module per panel. Only panels that take focus and keep state
have `Init`/`Update`/Router. The rest are `View`-only modules. Key
bindings, focus order, and on-screen wording belong in the issues, not here.

- The root model owns focus. The root Router handles focus with
  `only when:` guards. Each screen names a default panel.
- Keys map to **intents** at the root:
  `forward_events %i[down j], to: :characters, as: :move_down`.
  Characters' Update handles `:move_down`, never raw keys. Support both
  CUA and vim/lazygit-style keys.
- A text field captures typing: global first (Ctrl+C), then intent
  management, then keystrokes (`otherwise route_to: :search`). Handle Paste
  events. Draw the cursor with `tui.cursor`.
- Search bubbles a message upward; the root forwards it to Characters.
- Each focusable panel stores its own selection, viewport, and scroll data,
  as non-stateful versions of RatatuiRuby widgets need.
- Loading, empty ("No characters match …"), and error-with-retry states
  are all required. Good UX (tailored for a TUI user) is a must.

## Testing

The approach comes from five books. Apply them; don't cite them in code.

- Beck, *Test-Driven Development: By Example*: keep a test list, write the
  failing test first, and take small red-green-refactor steps (fake it,
  triangulate, or obvious implementation, depending on confidence).
- Freeman and Pryce, *Growing Object-Oriented Software, Guided by Tests*:
  start from a walking skeleton, and drive each feature from a failing
  end-to-end test, with unit tests as the inner loop. In MVU, "mock roles,
  not objects" becomes asserting on the commands Update returns.
- Tarlinder, *Developer Testing*: choose cases by equivalence class,
  boundary value, decision table, and state transition.
- Adzic, *Specification by Example*, without Gherkin: key examples from the
  real data name the tests and snapshots
  (`test_luke_appears_in_episodes_three_through_six`), so the suite reads as
  the specification.
- Shore, *The Art of Agile Development* (2nd ed.): stories are small
  vertical slices a user can see. Decisions, technical tasks, and refactors
  fold into the stories that need them, never issues of their own. A story
  is done when it is "done done": tested, documented, and shippable.

- Fixtures are recorded real responses. The source is frozen, so they don't
  go stale; never hit the live API in the default suite. Recording them is
  the only time to touch the live API, and only after asking.
- Test parsing and the domain model as plain Ruby against fixtures.
- Test Update functions without a terminal: assert on the returned model and
  command *values*. Child fragments receive routed intents, not keys; the
  root's tests prove which keys produce which intents.
- Test a View by rendering it in RatatuiRuby's `with_test_terminal` and
  asserting on what the screen shows (`buffer_content`, style
  assertions), as RatatuiRuby's application testing guide recommends.
  Don't inspect the widget tree a View returns. Unit tests assert
  behavior and style, never positions or box-drawing characters; layout
  belongs to snapshots.
- Test custom commands through the real runtime with `inject_sync`, against
  a local `TCPServer` serving fixtures, as Rooibos's own tests do. Don't add
  WebMock, mock `Net::HTTP`, or fake the `Outlet`.
- System tests run the app and check the screen with `assert_snapshots`.
  They start from an explicit fixture-built model unless they are
  about loading. Name snapshots after the example they show, and mask
  machine-specific output with `normalize_snapshots`.
- Point the cache at a temp directory via the environment, so tests exercise
  real path resolution.
- `with_test_terminal` times out after 2 s by default; keep each test small.

## Writing

Prose (README, docs, commit bodies, review messages) follows Zinsser's *On
Writing Well* and Klinkenborg's *Several Short Sentences About Writing*:
short, plain, active sentences, each doing work; no clutter. In README.md,
write paragraphs, not tables, bullets, or bold.

## Changes, commits, changelog

- Don't stage or commit unless asked. When done, suggest a Conventional
  Commits message covering the whole `git diff` and `git diff --cached`:
  plain text, no markdown, body only when it explains *why*. End with
  your own harness's attribution lines (naming your model, not one copied
  from history), in the format earlier commits use.
- User-visible changes go under `## [Unreleased]` in `CHANGELOG.md`
  (Keep a Changelog). Tests, refactors, and tooling do not.
- Keep `sig/` RBS current for public constants and classes; no `untyped`
  where a real type is known.
- Done means `bundle exec rake` passes with no failures or offenses.
