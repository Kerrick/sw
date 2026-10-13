# AGENTS.md

Star Wars Character Datapad: an offline-first terminal browser for the Star
Wars API (SWAPI). Gem `sw`, module `Sw`, executable `exe/sw`. Built on
Rooibos (TEA/MVU framework) and RatatuiRuby (Rust-backed TUI engine).

This file records only what you would not do by default. It is not a style
guide for Ruby. A fact about one place in the code goes in a comment there,
not here. Implementation work follows the
`.agents/skills/human-in-the-ralph-loop` skill.

## Commands

- Setup: `bin/setup` (`bin/setup.ps1` on Windows). It requires mise; prefix
  the commands below with `mise x --` unless mise is active in your shell.
- Everything (tests + RuboCop): `bundle exec rake`
- Tests only: `bundle exec rake test`
- Refresh snapshots after an *intended* rendering change:
  `UPDATE_SNAPSHOTS=1 bundle exec rake test`, then review the `.txt`/`.ansi` diff.
- Run: `bundle exec exe/sw`.
- Always `PAGER=cat` for `git`.
- Make simple edits with file editing tools, not scripts. Scripts for complex edits should use ruby.

## Rooibos and RatatuiRuby postdate your training data

Both are quite new and may change between minor versions. Do not guess their APIs.
The installed gems ship `lib/` and `sig/` only (`bundle exec gem contents rooibos`);
guides and example apps live upstream (github.com/setdef/Rooibos,
github.com/setdef/RatatuiRuby). Prefer their RDoc and guides to their
runtime source; read the source only when the docs are thin. Read before
writing code in the same area:

- `examples/tutorial/08_multi_fragment_layout`: panel modules, keys → intents.
- `examples/app_fractal_dashboard`: modal input capture, text input fragment.
- `examples/app_tabbed_fragments`: Router DSL reference, `Command.bubble`, custom messages.
- `doc/scaling_up/fractal_architecture.md`: fragments, model composition, and
  widget slots.
- `doc/best_practices/no_stateful_widgets.md`: scrolling without `ListState`.
- `lib/rooibos/command/outlet.rb`, `command/all.rb`, `command/http.rb`.
- RatatuiRuby `doc/concepts/application_testing.md` and
  `lib/ratatui_ruby/test_helper/*.rb`.

Examples also live in `~/Developer/rooibos/examples` and
`~/Developer/ratatui_ruby/examples`. `~/Developer/sidekiq/lib/sidekiq/tui`
(branch `rooibos`) is a larger Rooibos app: `fragments/table.rb` for
selection fragments, `key_map.rb` for contextual key help, and
`fragments/home.rb` for `View`-only parts as lambdas inside a fragment. It
is a Rooibos re-implementation of a third-party RatatuiRuby TUI wrought by
the Rooibos maintainer.

Local checkouts (e.g. `~/Developer/rooibos`) may be ahead of `Gemfile.lock`.
When an exact API matters, confirm it in the installed gem
(`bundle info --path rooibos`) or at the locked version's git tag.

Facts that are easy to get wrong:

- The router matches `Key#to_sym`. A capital letter arrives as `g` with Shift
  held, so bind `:shift_G`, never `:G`. (The `Key#G?` predicate is a
  different path.) Shift-Tab arrives as `back_tab`, sometimes with Shift
  held too, so bind both `:back_tab` and `:shift_back_tab`.
- Ctrl and Alt chords report `text?`, so a text field must skip them. Cmd
  and Super never arrive: nothing turns on the Kitty keyboard protocol.
- A Router runs every observer before the first matching receive, forward,
  or `otherwise`, and guards see the model the observers left.
- A nested fragment's `Command.bubble` passes through the outer fragment's
  forwards, so `forward_instances_of`, with `to:` and `as:`, hands it to a
  sibling.
- `skip when:` wraps its guard in a closure that debug mode must make
  Ractor-shareable, so a plain `->` guard fails there. Use
  `Ractor.shareable_lambda`. (`only when:` has no such trouble.)
- `out.source` runs one child command, waits, and returns its message, or
  `nil` on timeout or cancellation (handle that apart from HTTP errors).
  `out.standing` runs children in parallel, but their messages go to Update,
  not back to the parent. `Command.all` runs children in parallel and
  returns all their results together.
- In a test, `inject_sync` waits for the commands under way, then hands
  their messages to Update. It doesn't wait for the commands Update
  returns; a second sync does. To hold a command in flight for a steady
  screen, point it at a `TCPServer` that never answers.
- `Time.now` is a side effect: call it in a command, never in Update or a
  View. If Update needs the time, `Command.clock` delivers it as a message.
- Everything in a message or the model must be Ractor-shareable
  (`Ractor.make_shareable`). The test helpers enable debug mode, which checks.
- A command that raises does not fail cleanly. The runtime wraps the exception
  in a `Message::Error`, which `Update` ignores, so the app waits forever.
  Under test, debug mode tries to make that exception Ractor-shareable and
  raises `Ractor::Error`, which hides the real cause. Rescue inside the
  command and out.put a message.
- RatatuiRuby's List takes only Strings, Spans, Lines, and ListItems. Block
  titles, Table cells, and Spans' `content:` take anything with `to_s`. In the running app, a widget that raises while
  drawing leaves its panel blank and reports nothing.
- Table cells don't wrap, not even a Paragraph with `wrap: true` in a taller
  row. Long values are cut off, and the project accepts that, so a test
  asserts only the part of a value that fits its column. Tables have no row
  separators; `Craft::Entry` shows the way around it.
- A View can't measure the space it gets (a custom widget only returns Draw
  commands). In a layout, Fill sections take all spare space before a Min
  grows, so a Min beside Fills stays at its floor, and among Mins alone the
  last takes everything. A proportional share with a floor can't be said.
- A Paragraph's `style:` covers its blank cells too, which changes the
  `.ansi` snapshots. Be sure whether you intend to style the text or the area
  around it.

Vocabulary: a Rooibos unit is a **fragment**, never a "component" (reserved
for the Kit library). "Widget" means a RatatuiRuby render primitive. Write
"message" and "command", not "msg"/"cmd". The people are characters
(`Character`, `characters`), except where an API field names their role,
which the domain keeps: a vehicle's `pilots`, a planet's `residents`, a
species' `people`. Every member reads the API field of its own name, with no
renaming. The domain model has domain objects with attributes and
associations, never "records"; "record" belongs to the loader and the data.
Say "reload" for downloading the data again, whether the user asks or the
cache is stale; never "refresh."

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

The root URL is configurable (`SW_API_URL`). Only `Sw::API_URL`, its default,
and the fixture server name swapi.info. Never write a URL into other code,
not even in a throwaway edit; take links from the data.

Build for a frozen dataset, not for *this* dataset. Never assume six films
or episodes I–VI; more Skywalker Saga films should mean new data, not new
code. Every film has an episode number. Don't build for films without one
(YAGNI); supporting them later should be a small edit. Keep the domain
model free of character-centric assumptions, so future screens (one
vehicle, one film) can reuse it and the panel modules.

Two quirks hold for every parser. Each is an equivalence class with a test:

- `"unknown"` = missing. `"n/a"` = not applicable (droid hair).
  `"none"` is a real answer (bald).
- Links are URLs; match them with or without a trailing `/`.

A quirk of one kind of data belongs to the issue that handles it, not here.

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
The domain objects and their collections are a small **Domain Model** in Fowler's sense.

**Model.** Every model is a `Data.define` class, never a hash from
`JSON.parse`. Name each for what it is, not `Model`. Parsing does the
cleanup above. The domain model holds the domain objects and answers derived
questions (films in episode order, which films a character appears in).

No kind of object is the center. Every object keeps its associations in both
directions (a character's films and a film's characters, a planet's
residents and a resident's homeworld) as direct references, each to-many
association a `Collection`, so `luke.vehicles.first.pilots` reads naturally.
Objects link to each other directly, never by ID. Each keeps its API URL,
protected, only so a reload can find the same object in the new data
(`DomainObject#same_as?`). The graph has cycles, and that's fine: the cache
holds raw JSON, so no object is ever serialized. The API's two directions agree
today; if a source ever disagrees, that's a data quirk with a test. A
screen's View hands the object it centers on to its panels. Don't name or
build an Identity Map.

**Loading.** One or more custom commands, (`include Rooibos::Command::Custom`),
responsible for crawling from the root URL (in parallel), caching the responses
on disk, reloading it after 7 days, parsing JSON, instantiating model classes,
and making errors meaningful. `Load::Mapper` is the Data Mapper: the only
code that knows the API's JSON. Domain objects come back in a `Collection`,
an `Enumerable` set, frozen by whoever builds it.

Failures are messages, not exceptions. `Load` sends `Load::Finished` or
`Load::Failed`, and the project defines no exception classes (no `Sw::Error`).
`Load` rescues Ruby's own exceptions inside the command, in one place.

All-or-nothing: no progressive rendering. Detail panels need the joined data,
and partial data looks like missing data. The whole download takes under a second.

**Cache.** Raw JSON so a bugfix applies without re-downloading. Store file(s)
under the platform-appropriate user cache directory from the `etcetera` gem.

- Fresh cache: use it; no network.
- Cache older than 7 days: show it immediately, reload in the background,
  and swap the new data in with one message. If the reload fails, keep the
  old data and say so quietly (e.g. a status line). Never show the error
  screen while any cache exists.
- No cache: loading screen, then data or the error screen with retry.
- A reload the user asks for: download now, even if fresh.

Cache age is an input in the loading tests, alongside network outcomes.

**UI.** One module per panel, even a simple one; the repo shows off the
fractal architecture. A panel takes focus only when it has keys to answer,
and only those panels keep state and have `Init`/`Update`/Router. The rest
are `View`-only modules. A fragment's View takes that fragment's own
`Model`, plus keywords for what the root owns, such as `focused:`. A
`View`-only module takes whatever it needs, like props: a domain object, a
`Collection`, or nothing. Parts inside a panel are `View`-only too, as
lambdas in the panel's module or as modules of their own; file length
decides. A part drawn as its own bordered box inside a panel is named for
its role with a `Box` suffix (`HomeworldBox`, `SpeciesBox`), apart from the
domain object it draws. Key bindings, focus order, and on-screen wording belong in the
issues, not here. The brief is `tmp/brief.pdf`, uncommitted; its wireframe,
on page 3, settles a panel's labels, order, and units unless an issue says
otherwise.

- The root model owns focus. The root Router handles focus with
  `only when:` guards. Each screen names a default panel.
- Keys map to **intents** at the root:
  `forward_events %i[down j], to: :characters, as: :move_down`.
  Characters' Update handles `:move_down`, never raw keys. Support both
  CUA and vim/lazygit-style keys.
- Each Fragment stores its own state, like selection. A list leaves scrolling to
  the List widget (`offset: nil` keeps the selection in view).
- Keys reach a panel only while it has something to receive them: guard the
  root's forwards with `only when:` to prevent exceptions.
- Loading, empty, and error-with-retry states are all required. Good UX
  (tailored for a TUI user) is a must.
- Never show less of the data to make it fit. A panel that takes no focus
  can't scroll, so its height comes from the largest case in the whole
  dataset (`Craft::Height`), never from the selected object, and the layout
  holds still while browsing. Snapshots run at 120×40; say how a layout
  change behaves in a taller terminal too.
- When a panel draws what another already draws, share all of it, as
  `Craft` does for Vehicles and Starships, not only the piece an issue names.

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
  the specification. Name a test in a product owner's words, with a subject
  that can do the verb: `test_the_app_knows_why_the_download_failed`, not
  `test_a_failed_download_keeps_the_failure`. Leave plumbing, like the order
  a source lists things in, out of the name. A test named for an example
  shows that example in its body, through an explaining variable:
  `emergency_firespeeder_passengers = Sw::Value.new("unknown")`.
- Shore, *The Art of Agile Development* (2nd ed.): stories are small
  vertical slices a user can see. Decisions, technical tasks, and refactors
  fold into the stories that need them, never issues of their own. A story
  is done when it is "done done": tested, documented, and shippable.

- Fixtures are recorded real responses. The source is frozen, so they don't
  go stale; never hit the live API in the default suite. Recording them is
  the only time to touch the live API, and only after asking. Never edit
  them, and keep bulk edits out of `test/fixtures/`: renaming `Count` once
  turned "Count Dooku" into "Value Dooku".
- Test parsing and the domain model as plain Ruby against fixtures.
- Test Update functions without a terminal: assert on the returned model and
  command *values*. Child fragments receive routed intents, not keys; the
  root's tests prove which keys produce which intents.
- Test a View by rendering it in RatatuiRuby's `with_test_terminal` and
  asserting on what the screen shows (`buffer_content`, style
  assertions), as RatatuiRuby's application testing guide recommends.
  Don't inspect the widget tree a View returns. Unit tests assert
  behavior and style, never positions or box-drawing characters; layout
  belongs to snapshots. An offset from text you found is fine: the cell
  after a key, or the corner beside a title. Assert style or data, never
  copy, which product decisions change. `ViewTestHelper#with_rendered` renders a View for
  these assertions. Find text with `#text_position` and check its style
  with `#assert_text_style`, named as they would be in RatatuiRuby, rather
  than indexing `buffer_content` by hand. Refer to on-screen wording through
  the View's own constant, like `Sw::Vehicles::EMPTY`. When two rows show
  the same value, find the one you mean by its label with `on_line_with:`.
- Don't test non-behavior.
- Don't repeat the app's logic in a test, as by looping over the constant
  under test. Name what you expect. Keys are behavior, not copy, so name
  them. Nor assert that a View shows what a method returns, as `film.episode`:
  that tests the call, not the data. Assert a literal from the real data, and
  let the domain object's own test pin its wording.
- Don't unit-test framework wiring: Router dispatch, `Data#with`, or
  generated placeholders. The end-to-end test covers it.
- Test custom commands through the real runtime with `inject_sync`, against
  a local `TCPServer` serving fixtures, as Rooibos's own tests do. Don't add
  WebMock, mock `Net::HTTP`, or fake the `Outlet`. Inject faults with
  `FixtureServer`'s helpers.
- System tests run the app against the fixture server, reach their example
  with keys, and check the screen with `assert_snapshots`. Name snapshots
  after the example they show, and mask machine-specific output with
  `normalize_snapshots`. A snapshot that doesn't
  exist yet passes on its first run and writes itself, so a snapshot alone
  can't make a test red. Assert on data first.
- Point the cache at a temp directory via the environment, so tests exercise
  real path resolution. Age it with `age_cache`.
- `with_test_terminal` times out after 2 s by default; keep each test small.

## Writing

Prose (README, docs, commit bodies, review messages) follows Zinsser's *On
Writing Well* and Klinkenborg's *Several Short Sentences About Writing*:
short, plain, active sentences, each doing work; no clutter. In README.md,
write paragraphs, not tables, bullets, or bold.

README.md is one essay, written as if from the end of the project, looking
back. Read it whole and revise it whole, never in patches, and never get
ahead of a decision an issue hasn't made. Read any `.md` file in full before
you edit it.

Code comments say what the code can't: why, a rule, or a library's limit.
Don't narrate what the code shows. They never mention the wireframe or a
mockup.

## Changes, commits, changelog

- Until the project ends, issues live as committed files in `issues/`,
  numbered as GitHub will number them, and nothing is pushed. Each commit
  ticks its item in the issue file. At the end, `bin/publish-issues`
  creates them on GitHub before the push, and a final commit deletes the
  files.
- Stage and commit only when the human asks; never push. Tick an issue's
  item in the working tree so the commit includes it. When done, suggest
  a Conventional Commits message covering the whole `git diff` and
  `git diff --cached`: plain text, no markdown, body only when it explains
  *why*. End with your own harness's attribution lines (naming your model,
  not one copied from history), in the format earlier commits use. A commit
  that repairs behavior is a `fix:`, even when an unpushed commit in the
  same issue added that behavior: if the commit before it showed something
  wrong ("0 km", a planet named "unknown"), it is a `fix:`; if it showed
  nothing, a `feat:`. A decision the reviewer reverses is not a repair; the
  skill's rule for corrections applies.
- User-visible changes go under `## [Unreleased]` in `CHANGELOG.md`
  (Keep a Changelog). Tests, refactors, and tooling do not. Each entry is one
  capability; add an entry rather than growing an old one.
- Keep `sig/` RBS current for public constants and classes; no `untyped`
  where a real type is known.
- Done means `bundle exec rake` passes with no failures or offenses.
