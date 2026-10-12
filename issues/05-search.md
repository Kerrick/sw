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
- [ ] Search is a bordered box in a three-row title area, numbered `[1]`, and Characters is numbered `[2]`; the status line moves to the title area's third row on every screen, with its labels dimmed and its keys not
- [x] `2` focuses Characters (no test drives it until a third panel takes focus)
- [x] The list's keys work only while Characters has focus
- [ ] The status line lists the focused panel's keys, with the global ones after them
- [ ] Each keystroke filters the list live; Search bubbles the query to the root, which forwards it to Characters
- [ ] When the highlighted character stops matching, the highlight moves to the first match
- [ ] The list's keys move through the matches only
- [ ] A reload keeps the search
- [x] Backspace deletes the query's last character, and does nothing to an empty query
- [x] Cmd-Backspace, or Ctrl-U, clears the query
- [x] Ctrl and Alt chords don't type into the query
- [ ] Enter keeps the filter and focuses the searched list
- [ ] Esc clears the filter and focuses the default panel
- [ ] Tab and Shift-Tab keep the filter and move focus on
- [ ] Ctrl-C quits from Search and F5 reloads from it; `q`, `r`, digits, and Space type into it
- [ ] Pasted text goes into the query
- [ ] A search with no matches says "No characters match …"
- [ ] The cursor is drawn with `tui.cursor`
- [ ] Search shows its own key help and hides the global `r: Reload  q: Quit`, because those keys type into it
