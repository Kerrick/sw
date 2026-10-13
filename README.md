# Star Wars Character Datapad

This is my submission for LiminalArc's take-home exercise. It's a small app
for exploring Star Wars characters, using data from the
[Star Wars API](https://swapi.info/). It runs in a terminal. It works offline
after the first launch. You drive it entirely from the keyboard.

It does everything the brief asked. All 82 characters appear in a scrolling
list, and typing in Search narrows it. Beside the list are the highlighted
character's attributes, species, and homeworld. Below them is every film,
with the ones the character isn't in dimmed, and then the starships and
vehicles they pilot. The first launch shows a loading screen, a search with no
matches says so, and a failed download says what went wrong and offers to try
again.

I built it on two open-source Ruby gems I created and maintain:
[RatatuiRuby](https://www.ratatui-ruby.dev), a library that draws terminal user
interfaces (TUIs), and [Rooibos](https://www.rooibos.run), a framework for
building applications on top of it. The brief specified "the programming language,
framework, and tools you know best." No tools fit that description better.

You can see the app without running it. The tests record every screen they
check under `test/**/snapshots/`. The `.txt` files read well in GitHub's web
view. The `.ansi` files show the same screens in color if you `cat` them in a
terminal.

## Why a terminal

The brief allowed a web, mobile or desktop app. Before choosing, I asked what
a Character Datapad could offer that people can't already get.

The data has two problems. First, swapi.info is frozen. It stops at the first
six films, though the Skywalker Saga now has nine and other Star Wars films
have come out since. For now, the data, and so this app, believes the sequels
never happened. Second, the same data is already on
[Wookieepedia](https://starwars.fandom.com/), which offers a far richer
experience than any web client for this API could. A web Datapad would be a
worse Wookieepedia.

So the Datapad has to do something Wookieepedia can't. It can live in the
terminal, where web browsers handle sites like Wookieepedia poorly. And it
can work offline. The whole dataset is under 200 KB, so the app downloads it
once and works offline from then on.

There is a plainer reason too. I [wrought](#how-i-used-ai) RatatuiRuby and
Rooibos, which makes them the tools I know best, and I'd welcome the chance to
talk about them in the follow-up interview.

## Running it

You need [mise](https://mise.jdx.dev), which installs the Ruby version this
app pins (4.0 or later). On Windows, `bin/setup.ps1` installs Ruby through
RubyInstaller instead, because mise can't build a working Ruby there.
Precompiled `ratatui_ruby` gems exist for macOS on Apple Silicon, x86_64
Linux, and 64-bit Windows. On other platforms, Bundler builds the gem from
source, which needs a [Rust toolchain](https://rustup.rs). The first launch
needs the network. After that, the app reloads its cache weekly when it
can, and keeps using the old cache when it can't.

```sh
git clone https://github.com/Kerrick/sw.git && cd sw
bin/setup        # or bin/setup.ps1 on Windows
mise x -- bundle exec exe/sw
```

The app opens with the character list focused, and a green border marks
whichever panel has focus. As in [lazygit](https://github.com/jesseduffield/lazygit),
the focused panel decides what each key means, and the line under the title
lists them. A few keys work without being listed: the
[CUA](https://en.wikipedia.org/wiki/IBM_Common_User_Access) arrow keys, Home,
and End; Tab and Shift-Tab, and `/` for Search; and Ctrl-C and F5, which quit
and reload even from Search, where `q` and `r` type.

## Assumptions

The brief left some questions open. Here is each one and what I assumed.

Is a terminal app a desktop application? I assumed so. It runs locally on
all three desktop platforms, and my reasons for choosing it are above.

Should the app expect its data to change? No. I checked swapi.info,
swapi.dev, and swapi.tech, and all three stop at six films. The app downloads
once and reloads its cache only after seven days.

Should it expect the data to stay this way forever? No. It's built for
a frozen dataset, but not for this particular one. Nothing in it assumes six
films, or episodes numbered one through six. If a source with the rest of the
Skywalker Saga appears, adding them should mean new data, not new code.

What counts as missing data? I let the API's own values decide. It uses
"unknown" for missing values and "n/a" for values that don't apply, like a
droid's hair color. It uses "none" as a real answer, like a bald character's
hair. The app shows the first two for what they are and treats "none" as
data. It also copes with numbers written with commas (Jabba weighs "1,358"),
ranges (a starship's crew of "30-165"), and a planet named "unknown," which
it treats as an unknown homeworld rather than a place.

Can a planet measure zero? No. Six planets have a diameter of "0," and the
planet named "unknown" also takes zero hours to turn and zero days to orbit.
Planets aren't black holes, so the app treats a zero diameter, rotation
period, or orbital period as unknown. A planet can be empty, though. Tund's
population of zero is real: its last Sorcerer killed everything living there.

What is Luke's species? Unknown, because the data doesn't say. Thirty-two
of the 82 characters, Luke among them, have no species, and the Human
species doesn't list him. The wireframe shows him as Human, and most of the 32
are. But R4-P17 is a droid, and Sly Moore is an Umbaran, so guessing Human
would make the app wrong about them. The app shows an empty species as
unknown. That's a problem in the data, and the place to fix it is the source.

In what order should characters appear? Alphabetically by name, as the
wireframe shows them. The API lists them in its own arbitrary-seeming order.

What about image placeholders? The brief allowed them but didn't require
them, and in a terminal the space is better spent on text. If it turns out to be
important, I look forward to adding
[image support](https://github.com/ratatui/ratatui-image) to RatatuiRuby.

## How it's built

Rooibos follows [The Elm Architecture](https://guide.elm-lang.org/architecture/)
(MVU): one immutable model, a view of it, and an update function that turns each
message into a new model (and, optionally, a command for the runtime to run).

The app parses the API's JSON into immutable classes (`Character`, `Planet`
and the rest) and cleans up the data's quirks on the way in. They form a small
[Domain Model](https://martinfowler.com/eaaCatalog/domainModel.html) that
answers questions like which films a character appears in. Every object keeps
its associations in both directions, so no kind of object is the center: asking
who pilots a vehicle is as easy as asking what a character pilots.

Loading happens in [custom Rooibos commands](https://www.rooibos.run/docs/v0.8/Rooibos/Command/Custom.html).
They fetch the API's root, then all the collections at once, and cache the raw
responses in the platform's standard cache directory, found with the
[`etcetera`](https://rubygems.org/gems/etcetera) gem. When the cache is more
than a week old, the app shows it anyway and reloads in the background,
swapping in the new data in one step. If that reload fails, it keeps the old
data. Only a first launch without a network shows an error.

The screen is one [module](https://www.rooibos.run/docs/v0.8/doc/scaling_up/fractal_architecture_md.html)
per panel. Only the list and Search take focus, and only they keep state. The
other panels, and the pieces inside every panel, like the attributes table, are
only views. The root's model records which panel has focus, and its
[router](https://www.rooibos.run/docs/v0.8/doc/scaling_up/message_routing_md.html)
turns keys into intents (so the down arrow and `j` both mean "move down") and
routes each intent to the focused panel. The list keeps its selection in its
model rather than in a stateful widget, as
[Rooibos recommends](https://www.rooibos.run/docs/v0.8/doc/best_practices/no_stateful_widgets_md.html).

The brief needed one screen, centered on a character. A screen centered on a
vehicle, a planet, or a film would be a new arrangement of the same panels
over the same domain model, and a choice at the top of which screen to show.

## Choices and tradeoffs

A web app would have been easier for most reviewers to run and for most
teams to inherit. I chose the option with a reason to exist alongside
Wookieepedia, and I accepted that fewer people can run it. A niche audience
with no competition beats losing on the open web.

Building upon my own libraries cuts both ways. I know them deeply, they fit
the problem, and the app uses them the way their guides recommend. But a team
inheriting this app would inherit an app using a young framework, still before
its 1.0 release, which is built on a library with a small community and one
maintainer. In client work that would have been a non-starter five years ago.
In the era of agentic generative AI, an LLM can maintain a small dependency if
the maintainer doesn't. For an exercise meant to show my software design skills
given a much smaller problem than the Skills Assessment, I judged it worth the
cost, and I'd like to discuss it.

The app downloads everything at once instead of fetching each character as
it's chosen. The whole dataset is seven parallel requests and under 200 KB.
Getting it up front makes offline use and instant search possible, and puts
every network error in one place. Fetching on demand would add a loading state
to every selection and gain nothing on data this small.

It shows one loading state instead of filling in panels as data arrives.
Each request takes well under half a second, so progressive loading would
flash several half-finished screens in under a second.

The cache holds raw JSON, not parsed objects. When I change a parsing rule,
the fix works with existing caches without a new download.

The panels beside the list follow its highlight, as lazygit's do. Requiring
Enter to choose a character would double the keystrokes for browsing.

The Starships and Vehicles panel heights are the maximum the current dataset
needs, rather than adding focus and scrolling to those panels right now.

The layout is meant for a reasonably large terminal, and a small window will be
cramped. Responsive design is possible with RatatuiRuby, but was deemed
out-of-scope for a few hours.

There is no [Domain-Driven Design](https://www.domainlanguage.com/ddd/) here,
and no [hexagonal architecture](https://alistair.cockburn.us/hexagonal-architecture/).
In my Skills Assessment I recommended both for a legacy enterprise CMS. They
pay for themselves in large systems with many teams and shifting requirements.
This is a read-only viewer for a few hundred records that rarely, if ever,
change.

## Tests & Testing

I wrought tests before the code they cover. They run with the linter, or alone:

```sh
mise x -- bundle exec rake
mise x -- bundle exec rake test
```

When a change to the screen is intended, regenerate the snapshots with
`UPDATE_SNAPSHOTS=1 mise x -- bundle exec rake test` and read the diff before
committing.

The suite never touches the network. Tests that need HTTP talk to a real local
server that replays recorded responses from the API, instead of mock objects.
Update functions are pure, so unit tests call them directly and check the model
and command they return, with no terminal involved. Snapshot tests run the real
app in a headless terminal for the screens worth seeing. Each snapshot is named
for the example it shows: Luke selected, a search for "sky," a search with no
matches, a first launch without a network. Read together, they describe the app.

## With more time

1. Add a responsive UI that works with screens as small as 80 columns wide and
24 rows high.
2. Add image support to RatatuiRuby, and then to this application.
3. Fix RatatuiRuby so a cursor drawn inside a panel moves the terminal's own
   cursor, then use it in Search in place of the blinking underscore.
4. Add screens to browse each collection, and links between them.
5. Improve accessibility, with respect for `NO_COLOR` and a
   non-interactive (CLI) mode.
6. Add mouse support.

## How I used AI

I use three words for how code comes to exist. Code I wrote, I typed by
hand, with nothing generated. Code I wrought, an AI agent generated while I
iterated with it, and I reviewed every change before committing it, so I own
every diff. Code I requested, an agent built with little or no review from
me, the way a dark factory runs without lights.

I wrought this repository. I could have written it. But my Skills Assessment
was light on AI, and I wrote it rather than wrought it, so this exercise was my
chance to show the other half of how I work. I wrought RatatuiRuby and Rooibos
too. The `etcetera` gem was requested, so I treat it like any other
third-party gem whose source I haven't read.

The workflow is committed as an agent skill, in the open
[Agent Skills](https://agentskills.io) format, at
`.agents/skills/human-in-the-ralph-loop/`. A [Ralph
loop](https://venturebeat.com/technology/how-ralph-wiggum-went-from-the-simpsons-to-the-biggest-name-in-ai-right-now)
lets an agent run until the work is done. Mine keeps a human in it. The agent
builds one small behavior at a time, test first, and stops twice in every
cycle: once for me to review the failing test, and once for me to review the
implementation before it commits. When something important is unclear, it
asks instead of assuming. So the agent's work had to meet behavior I had
already specified, and nothing was committed until I had read it. Nothing in
the skill is specific to this app, so a team could adopt it as it stands.
[`AGENTS.md`](https://agents.md) holds what the skill leaves out: this
project's conventions, and the facts about the data and the libraries that an
agent is likely to get wrong.

I planned with the agent too, and this README went through several rounds of
generating and extensive hand-editing, with my review between each.

All of this took time. The brief asked for a few hours. The twelve issues
took me about ten hours, after two hours of planning. I could probably have
written the app faster by hand. The first six issues ran two to four times
over their estimates because I was tuning the skill and `AGENTS.md`, while the
last six had accurate estimates. That was worth it to me for two reasons. The
skill will serve every Rooibos app I build from now on. And work like this,
early in a new repo, moves what one developer knows out of their head and into
files a team can read and an agent will follow. I also want the Datapad to
become one of Rooibos's example applications, so I built more than the brief
asked for, like CI on three platforms and offline caching. I could have stopped
at the timebox with less to show, but I kept going because the work was going
well, and because I enjoyed it.

## Maintaining it

Start with `AGENTS.md`. (That it took coding agents to get so many teams
to write onboarding docs is a subject for a blog post.) `AGENTS.md` is short,
and it covers the vocabulary, the data's quirks, and how the tests are written.

To handle a new quirk in the data, add the raw value to a recorded response,
write a failing test for the class that parses it, then fix the parser.
Because the cache holds raw JSON, users get the fix without downloading
again. To add a key binding, map the key to an existing intent in the
top-level router. A panel changes only if the intent is new. A new panel that
only displays data is a view function; give it a model and update function
only if it can take focus. A new screen arranges panel modules, old and new,
and asks the top level to choose it. Put new questions about the data in
the domain model, not in a view. More Skywalker Saga films should need no
code at all. If they do, something assumed what it shouldn't have. Films
without an episode number, like Rogue One, would need a small change to how
films sort and are labeled.

Rooibos and RatatuiRuby are young, so read their changelogs before
upgrading. Their guides and example apps live on GitHub, not in the
installed gems.

I planned the work as GitHub issues, each with an estimate, and each commit
names the issue it advances. Commits are small and go straight to `main`,
and `bundle exec rake` passes before each.
