---
name: human-in-the-ralph-loop
description: Build software one small behavior at a time with test-driven development, stopping for a human's approval twice per cycle, after writing the failing test and before committing. Use when implementing features, issues, or checklist items in this repository, when asked to work through GitHub issues, or when the user mentions TDD, test review, implementation review, human-in-the-loop, or the Ralph loop.
---

# Human in the Ralph Loop

A Ralph loop runs an agent until the work is done. This one keeps a human in
it. You build one small behavior per cycle, stop twice per cycle for review,
and ask instead of assuming when something important is unclear. You never
proceed past a gate on your own.

The project's `AGENTS.md` overrides this skill wherever they conflict. It
also holds the project's commands, conventions, testing approach, and
definition of done; this skill refers to them rather than repeating them.

## Before the first cycle

Read `AGENTS.md` and `README.md` in full, and whatever they tell you to read
first. Run the project's setup and its full check, and confirm both pass
before changing anything. If they don't, stop and report it.

## The cycle

A cycle delivers one behavior: one thing a user or a test can observe.
"Parse comma-separated numbers" is one behavior. "Build the domain model" is
not.

### 1. Choose

Take the next unchecked item from the current issue. Say which issue and
item you're on. The issue's checklist is the test list (Beck): add to it
when you think of a case, and never silently drop one. If an item is too big
for one failing test, split it and say how. If an item has no observable
behavior, don't force a test for it. Say so and ask whether to drop the item or
tick it with a note.

A feature issue starts with one failing end-to-end test, named after the
issue's key example (Freeman and Pryce; Adzic). It stays red while the
unit-level cycles beneath it make it pass. Each unit beneath it is a full
cycle of its own, with its own failing test and its own TEST REVIEW.
Approval of the end-to-end test, or of any one test, is not approval to
build the units beneath it. Never write the tests for several units at
once, never write several tests for a unit at once, and never write the code
for a unit test the reviewer hasn't approved.

### 2. Research

Before you propose a design or a test, read the dependency's guides and
API documentation for the area this behavior touches. Read its source only
where the docs are thin. Then read the closest example or test in that
dependency that does something similar, and follow its pattern. Note the
file paths; you'll cite them at the gates.

### 3. Write the failing test

Write the smallest test that pins down the behavior. Say which equivalence
class, boundary, decision-table row, or state transition it covers that no
earlier test does (Tarlinder). Run it and watch it fail for the right
reason: the behavior is missing. An undefined class or method is a right
reason when it's the one the test is about. A typo, a wrong path, a missing
`require` for code that exists, or a bug in the test is not. Write no
production code before the gate, not even an empty class. A test that passes
on arrival, because earlier code already does the job, is not a red run. Prove
it isn't vacuous by temporarily breaking the code and watching it fail, then
restore the code. Break it as mutation testing would: one small, plausible
fault (a changed operator, an off-by-one, a dropped statement) that the test's
own assertion catches, not a crash on the way to it. A test that pins the data
rather than the code needs no mutant: give it an input from the other
equivalence class, outside the repository, and watch it fail. Say so at the
gate. A test that passes on arrival and that no plausible mutant can fail,
because other tests already catch every mutant or the code can't reach the
fault, isn't worth keeping. Tick the item with a note saying why.

### 4. Gate one: TEST REVIEW

You are not ready for this gate until you have run the test and seen it
fail for the right reason. Then post a message that begins with
**TEST REVIEW** and contains:

- the issue and item;
- where the test is, by file and test name;
- why it fails, in a sentence;
- why this case, in the terms of step 3;
- the dependency code or example you'll follow, with paths;
- any pattern the code will newly use or change, by its name in the
  pattern books the project lists (Fowler, the Gang of Four, Meszaros, and
  so on);
- anything in `README.md` or `AGENTS.md` this behavior will make wrong;
- any question to answer before implementing.

End your turn and wait. Do not implement. If the reviewer asks for changes,
make them and post a new TEST REVIEW.

### 5. Implement

Write the least code that makes the test pass: fake it when unsure,
triangulate with another test when the fake would survive, and write the
obvious implementation only when it is obvious (Beck). Code no test asks
for waits for the test that will, however obvious it looks; a snapshot can
ask for layout and wording. A triangulating test is a new test, so it starts
a new cycle and goes to its own TEST REVIEW.
Implement only the test the reviewer approved. Run the full check. Only the
end-to-end test may be red at a gate. If the code would break any other test,
fold the change into the cycle that fixes that test, or split the work so
every other test stays green. If a change breaks more than you expected,
revert to the last green state first. Then make the change easy, and make
the easy change (Beck): a few small steps, each green on its own. When you
expect a change to alter snapshots or other recorded output, regenerate it
yourself and read the diff before the gate. Report anything you didn't
expect.
Fix lint offenses rather than disabling rules. Refactor only while green, and
only within what this cycle touched. Meet the rest of the project's
definition of done.

If the change makes `README.md` or `AGENTS.md` wrong, don't edit them. Flag
it at the next gate. Edit them only when the reviewer asks, and change only
what they asked for. Before you edit any document, read all of it, so the
edit fits the whole.

### 6. Gate two: IMPLEMENTATION REVIEW

Post a message that begins with **IMPLEMENTATION REVIEW** and contains:

- whether the full check passed;
- why you made any decision the diff can't explain, if it matters;
- any pattern that changed since the TEST REVIEW, by its book name;
- anything in `README.md` or `AGENTS.md` now out of date;
- any earlier recommendation whose reason no longer holds, and what you'd
  do instead;
- whether you recommend committing now and, only if you do, a suggested
  commit message in the project's format, ending with `Refs #<issue>`, or
  `Closes #<issue>` on the issue's last item;
- the next cycle, in one sentence.

End your turn and wait.

### 7. Commit

Stage and commit only when the reviewer asks; never push. When asked,
stage only the files of the cycles the commit covers, and commit with the
approved message. A refactor gets its own commit, apart from the behavior
around it. The working tree may hold more than the commit will, so run the
full check on exactly what is staged, for example in a copy made with
`git checkout-index -a --prefix=<dir>/`.

A correction that belongs in an earlier unpushed commit goes there as a
`fixup!` commit, folded in with an autosquash rebase. When later commits
touched the same lines, back up the finished work first, stop the rebase at
that commit, make the change as it would have been made then, and resolve
each later conflict as its commit intended. Afterward, run the full check
on every rewritten commit, and confirm the final tree matches the backup.
A decision the reviewer reverses is such a correction. Rewrite the commit
that made it as though the first choice was never made: its code, tests,
recorded output, message, and every note that mentions it.

A commit needs the full check to pass. While an end-to-end test is still
red, a cycle ends at its approved IMPLEMENTATION REVIEW, and the next cycle
begins with no commit. When the last of those cycles turns everything
green, suggest one message covering all of them. Before you do, check off
the item in the issue, or in its file if publishing is deferred, so the
commit includes it. If you can't check it off, say it's ready.
Then begin the next cycle.

## Ask, don't assume

Ask when the answer would change the design, what the user sees, or a name
that will spread through the code. Decide yourself when the choice is local,
cheap to reverse, and settled by `AGENTS.md` or an example, then report it at
the next gate.

Ask about, for example:

- names that will spread: types, collections, messages, intents;
- anything on screen the requirements don't settle: wording, layout,
  colors, key bindings;
- a dependency that doesn't seem to support what the design needs. Don't
  work around it; the team may change the dependency instead;
- data that fits none of the cases `AGENTS.md` describes;
- a new dependency;
- anything that would change `README.md` or `AGENTS.md`.

Decide and report, for example: private helper names, test names, the order
of tests within an item, and small refactors inside this cycle's code.

When you ask, list the options you see and recommend one, so the answer can
be a single word. Questions `AGENTS.md` lists as open must be asked before
you reach them.

## Planning

If there are no issues yet, propose them first. Post a **PLAN REVIEW**: each
issue with a title, a short description, a checklist in which every item is
one cycle, and your estimate, plus the order you'd take them in. Start with a
walking skeleton (Freeman and Pryce). If the plan won't fit the time
available, say so and propose cuts. Flag anything in `README.md` or
`AGENTS.md` the plan would make wrong, as at the gates. Create the issues
only after approval; the reviewer may change the estimates. If the
repository has no remote, ask for one.

Issues are stories: small vertical slices a user can see (Shore). Fold
decisions, technical tasks, and refactors into the stories that need them,
not issues of their own.

The reviewer may defer publishing issues. Then write each one as a file in
the repository, numbered as the issue tracker will number it, to be
committed with the plan. Work from those files as if they were the
issues; commits reference their numbers. Once the issues are published,
delete the files, and suggest a commit that does only that, so only one
copy remains.

## Writing to the reviewer

Every gate message is prose the reviewer must read. Write it the way
Zinsser and Klinkenborg would: short, plain, active sentences, each doing
work. Lead with what needs a decision.

The reviewer reads diffs in their own git tools and sees command output in
the session. Don't paste either into a gate message. Point to files and
tests by name, and say in words what the output showed.

Say only what is new. Don't restate patterns, decisions, or facts the
reviewer has already seen in this conversation, not even to say they still
hold. Omit any checklist item with nothing new to report.

Don't describe what the diff shows: which files changed, what changed in
them, or what you decided. Give a reason only when the diff can't show it
and it matters. Don't describe code you plan to write, unless a question
needs it. Save the details of the next cycle for its own TEST REVIEW.

## When stuck

If a test won't fail for the right reason, or won't pass after two honest
attempts, post a **STUCK** message: what you tried, the exact output, and
what you suspect. Don't loosen an assertion, skip a test, regenerate a
snapshot, or change approach without asking.
