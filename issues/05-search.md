# Search: "sky" finds Luke, Anakin, and Shmi Skywalker

Estimate: 40 minutes

Typing narrows the list as you go. Search works like lazygit's filter: Enter
keeps the filter and goes to the list it searched; Esc clears it and goes to
the screen's default panel.

This is the first story with a second focusable panel, so the list's keys
must work only while Characters has focus, and the status line must list the
focused panel's keys.

While these are the only two panels that take focus, `2` can never move
focus. In Search, digits type into the query, and from the list, `2` names
the panel that already has focus. Decide whether to bind it anyway, so the
numbers never move when a third panel takes focus (recommended), or leave it
unbound until then.

- [x] `1` or `/` focuses Search
- [x] `/` does nothing while the download is under way
- [x] Search is a bordered box in a three-row title area, numbered `[1]`, and Characters is numbered `[2]`; the status line moves to the title area's third row on every screen, with its labels dimmed and its keys not
- [x] `2` focuses Characters (no test drives it until a third panel takes focus)
- [x] The list's keys work only while Characters has focus
- [x] The status line lists the focused panel's keys, with the global ones after them
- [x] Each keystroke filters the list live; Search bubbles the query to the root, which forwards it to Characters
- [x] When the highlighted character stops matching, the highlight moves to the first match
- [x] The list's keys move through the matches only
- [ ] A reload keeps the search
- [x] Backspace deletes the query's last character, and does nothing to an empty query
- [x] Cmd-Backspace, or Ctrl-U, clears the query
- [x] Ctrl and Alt chords don't type into the query
- [x] Enter keeps the filter and focuses the searched list
- [x] Esc clears the filter and focuses the default panel
- [x] Esc in the list clears an active search too
- [x] Key help shows `esc: Clear search` in Search, and in the list only while a search is active
- [x] Tab and Shift-Tab keep the filter and move focus on
- [x] Ctrl-C quits from Search and F5 reloads from it; `q`, `r`, digits, and Space type into it
- [x] Pasted text goes into the query
- [x] A paste drops its trailing line break
- [x] A search with no matches says "No match for" over the query
- [ ] The cursor is drawn with `tui.cursor`
- [x] Search shows its own key help and hides the global `r: Reload  q: Quit`, because those keys type into it
