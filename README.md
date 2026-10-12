# Star Wars Character Datapad

This is my submission for LiminalArc's take-home exercise. It's a small app
for exploring Star Wars characters, using data from the
[Star Wars API](https://swapi.info/). It runs in a terminal. It works offline
after the first launch. You drive it entirely from the keyboard.

I built it on two open-source Ruby gems I created and maintain:
[RatatuiRuby](https://www.ratatui-ruby.dev), a library that draws terminal user
interfaces (TUIs), and [Rooibos](https://www.rooibos.run), a framework for
building applications on top of it. The brief specified "the programming language,
framework, and tools you know best." No tools fit that description better.

You can see the app without running it. The tests record every screen they
check under `test/**/snapshots/`. The `.txt` files read well in GitHub's web
view. The `.ansi` files show the same screens in color if you `cat` them in a
terminal.

## What the brief asked for

The brief asked for an app that lets someone view a list of characters,
search for one, and select one to see their attributes, species, and
homeworld. It also asked for the films they appear in and the starships and
vehicles they pilot, and for clear loading, empty, and error states. A
wireframe showed all of it on one web-style page. Only that page was
required, and images could be placeholders.

The Datapad does each of those things. All 82 characters appear in a
scrolling list, and typing in the search field narrows it. Choosing a
character fills the panels beside the list with their attributes, species, and
homeworld. Below them is every film, with the ones the character isn't in
dimmed, as the wireframe showed. The starships and vehicles they pilot come
last. The first launch shows a loading screen. A search with no matches says
so. A failed download says what went wrong and offers to try again.

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

There is a plainer reason too. I maintain RatatuiRuby and Rooibos, and I'd
welcome the chance to talk about them in the follow-up interview. That I
[wrought](#how-i-used-ai) them makes them the tools I know best. It also makes them a risk, which I take up below.

Those conclusions informed the rest. The app is a Rooibos application. On its
first launch it starts at the API's root URL, downloads the entire small dataset,
and caches it on disk. Each panel on screen is its own module. Like
[lazygit](https://github.com/jesseduffield/lazygit), the app tracks which
panel has focus, and that panel decides what each key means. When the search
field has focus, keystrokes type into it. When the character list has focus,
keystrokes move through it. Both the classic arrow and Home keys
(from IBM's CUA guidelines) and the `j`, `k`, `g`, and `G` keys of vim and newer
terminal apps work.

## Running it

You need [mise](https://mise.jdx.dev), which installs the Ruby version this
app pins (4.0 or later). On Windows, `bin/setup.ps1` installs Ruby through
RubyInstaller instead, because mise can't build a working Ruby there.
Precompiled `ratatui_ruby` gems exist for macOS on Apple Silicon, x86_64
Linux, and 64-bit Windows. On other platforms, Bundler builds the gem from
source, which needs a [Rust toolchain](https://rustup.rs). The first launch
needs the network. After that, the app refreshes its cache weekly when it
can, and keeps using the old cache when it can't.

```sh
git clone https://github.com/Kerrick/sw.git && cd sw
bin/setup        # or bin/setup.ps1 on Windows
mise x -- bundle exec exe/sw
```

To refresh the cache now, run `mise x -- bundle exec exe/sw --refresh`.

The focused panel has a green border. Tab and Shift-Tab move between
panels. So do the number keys: 1 for Characters, 2 for the selected
character, 3 for Search, then 4, 5, and 6 for Films, Starships, and
Vehicles. A slash also jumps to Search. In the character list, the arrow keys
or `j` and `k` move the highlight, and the panels beside it follow. Home and
End, or `g` and `G`, jump to either end. The same keys scroll any other
panel. Search filters the list as you type. Enter keeps the filter and
returns to the list. Esc clears it. Ctrl-C quits from anywhere, and `q`
quits from anywhere but Search. F5 and `r` reload the data from the API.

## Assumptions

The brief left some questions open. Here is each one and what I assumed.

Is a terminal app a desktop application? I assumed so. It runs locally on
all three desktop platforms, and my reasons for choosing it are above.

Should the app expect its data to change? No. I checked swapi.info,
swapi.dev, and swapi.tech, and all three stop at six films. The app downloads
once and refreshes its cache only after seven days.

Should it expect the data to stay this way forever? No. It's built for
a frozen dataset, but not for this particular one. Nothing in it assumes six
films, or episodes numbered one through six. If a source with the rest of the
Skywalker Saga appears, adding them should mean new data, not new code.

What counts as missing data? I let the API's own values decide. It uses
"unknown" for missing values and "n/a" for values that don't apply, like a
droid's hair color. It uses "none" as a real answer, like a bald character's
hair. The app shows the first two for what they are and treats "none" as
data. It also copes with numbers written with commas (Jabba weighs "1,358"),
with ranges (a starship's crew of "30-165"), and with a planet literally
named "unknown," which it treats as an unknown homeworld rather than a place.

Can a planet measure zero? No. Six planets have a diameter of "0," and the
planet named "unknown" also takes zero hours to turn and zero days to orbit.
Planets aren't black holes, so the app treats a zero diameter, rotation
period, or orbital period as unknown.

What is Luke's species? Unknown, because the data doesn't say. Thirty-two
of the 82 characters, Luke among them, have no species, and the record for
Humans doesn't list him. The wireframe shows him as Human, and most of the 32
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

Rooibos follows The Elm Architecture, also called Model-View-Update. One
immutable model holds the app's state. A view function turns that model into
what's on screen. An update function takes each message, such as a key press or
a finished download, and returns a new model, sometimes with a command for the
runtime to carry out. The runtime draws the screen and runs commands in the
background.

The model starts with the API's JSON. The app parses it into immutable
classes (`Character`, `Planet` and the rest) and cleans up the data's quirks
on the way in. A small Domain Model, in Martin Fowler's sense from *Patterns of Enterprise
Application Architecture*, holds those records and answers questions about
them, like which films a character appears in. Records keep the API's
links in both directions, so a character lists its films and a film lists its
characters, and they point straight at each other. No kind of record is the
center. Asking who pilots a vehicle is as easy as asking what a character
pilots, which eases the addition of future screens. The records refer to each
other in circles, which is safe because they never change and the cache
stores raw JSON rather than objects. Each screen hands the record it centers
on to its panels.

Loading happens in custom Rooibos commands. They fetch the API's root, then
all the collections at once. They cache the raw responses in the platform's
standard cache directory, found with the
[`etcetera`](https://rubygems.org/gems/etcetera) gem, and build the
domain model away from the interface. The interface hears about it once: the
data loaded, or it failed for a reason it can show. When the cache is more
than a week old, the app shows it anyway and refreshes in the background,
swapping in the new data in one step. If that refresh fails, it keeps the old
data. Only a first launch without a network shows an error.

The screen is made of one module per panel. Every panel takes focus, so
any of them can be driven from the keyboard. Each keeps its own state in its
model. Smaller pieces inside them, like the attributes table, are only views.
The top-level model records which panel has focus. The top-level router turns
keys into intents, so the down arrow and `j` both mean "move down," and hands
each intent to the focused panel.

The brief needed one screen, centered on a character. Because panels are
small modules over a shared domain model, a screen centered on a vehicle, a
planet, or a film would be a new arrangement of panels, most of them reused,
and a choice at the top of which screen to show. Existing panels would need
navigation added, like the Characters list has now.

## Choices and tradeoffs

A web app would have been easier for most reviewers to run and for most
teams to inherit. It would also have competed with Wookieepedia and lost. I
chose the option with a reason to exist, and I accepted that fewer people can
run it. A niche audience with no competition beats losing on the open web.

Building on my own libraries cuts both ways. I know them deeply, they fit
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
Enter to choose a character would double the keystrokes for browsing and
keep two cursors in the model. Scrolling a long panel needs focus anyway, so
every panel can take it.

Only panels that take focus keep state. The other panels, and the pieces
inside every panel, are View-only modules.

The layout is meant for a reasonably large terminal, and a small window will be
cramped. Responsive design is possible with RatatuiRuby, but was deemed
out-of-scope for a few hours.

Rooibos recommends against stateful RatatuiRuby widgets, so the app keeps
selection in the model and uses the widget's default scrolling behavior.

There is no Domain-Driven Design here, and no hexagonal architecture. In my
Skills Assessment I recommended both for a legacy enterprise CMS.
They pay for themselves in large systems with many teams and shifting
requirements. This is a read-only viewer for a few hundred records that
rarely, if ever, change.

## Tests & Testing

I wrought tests before the code they cover.

The tests run with the linter, or alone:

```sh
mise x -- bundle exec rake
mise x -- bundle exec rake test
```

When a change to the screen is intended, regenerate the snapshots with
`UPDATE_SNAPSHOTS=1 mise x -- bundle exec rake test` and read the diff before
committing.

Integration tests talk to a real local HTTP server as a mock, instead of
mock objects, as Rooibos's own HTTP tests do. The suite never touches the
network. Tests that need HTTP talk to a local server that replays recorded
responses from the real API.

Update functions are pure, so unit tests call them directly and check the
model and command they return, with no terminal involved. Snapshot tests run
the real app in a headless terminal for the screens worth seeing. Each
snapshot is named for the example it shows: Luke selected, a search for
"sky," a search with no matches, a first launch without a network. Read
together, they describe the app.

## With more time

1. Add a responsive UI that works with screens as small as 80 columns wide and
24 rows high.
2. Add image support to RatatuiRuby, and then to this application.
3. Add screens to browse each collection, and links between them.
4. Improve accessibility, with respect for `NO_COLOR` and a
   non-interactive (CLI) mode.
5. Add mouse support.

## How I used AI

I use three words for how code comes to exist. Code I wrote, I typed by
hand, with nothing generated. Code I wrought, an AI agent generated while I
iterated with it, and I reviewed every change before committing it, so I own
every diff. Code I requested, an agent built with little or no review from
me, the way a dark factory runs without lights.

I wrought this repository. I could have written it. But my Skills Assessment
was light on AI, and I wrote it rather than wrought it, so this exercise was my
chance to show the other half of how I work.

The workflow is committed as an agent skill, in the open
[Agent Skills](https://agentskills.io) format, at
`.agents/skills/human-in-the-ralph-loop/`. A [Ralph
loop](https://venturebeat.com/technology/how-ralph-wiggum-went-from-the-simpsons-to-the-biggest-name-in-ai-right-now)
lets an agent run until the work is done. Mine keeps a human in it. The agent
builds one small behavior at a time, test first, and stops twice in every
cycle: once for me to review the failing test, and once for me to review the
implementation before it commits. When something important is unclear, it
asks instead of assuming. So the agent's work had to meet behavior I had already
specified, and nothing was committed until I had read it. Nothing in the skill
is specific to this app, so a team could adopt it as it stands.

I planned with the agent too, which required plenty of iteration of its own.
This README.md file, for example, was generated based upon a conversation, then
re-generated based on feedback, then extensively hand-edited, then agent-edited,
with manual review between each step.

RatatuiRuby and Rooibos were both wrought, while `etcetera` was requested.
I treat the latter like any other third-party gem for which I haven't read the
source code.

`AGENTS.md` holds what the skill leaves out: this project's conventions for
coding agents, along with the facts about the data and the libraries that
they are likely to get wrong.

## Maintaining it

Start with `AGENTS.md`. (The fact that `AGENTS.md` motivated so many teams to
write their first onboarding documentation that a new human team member also
benefits from is a subject for a blog post.) `AGENTS.md` is short, and it covers
the vocabulary, the data's quirks, and how the tests are written.

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
