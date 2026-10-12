# Search: "sky" finds Luke, Anakin, and Shmi Skywalker

Estimate: 40 minutes

Typing narrows the list as you go. Search works like lazygit's filter: Enter
keeps the filter and goes to the list it searched; Esc clears it and goes to
the screen's default panel.

- [ ] `3` or `/` focuses Search
- [ ] Each keystroke filters the list live; Search bubbles the query to the root, which forwards it to Characters
- [ ] Enter keeps the filter and focuses the searched list
- [ ] Esc clears the filter and focuses the default panel
- [ ] Tab and Shift-Tab keep the filter and move focus on
- [ ] Ctrl-C quits from Search and F5 reloads from it; `q`, `r`, digits, and Space type into it
- [ ] Pasted text goes into the query
- [ ] A search with no matches says "No characters match …"
- [ ] The cursor is drawn with `tui.cursor`
- [ ] Status-line key help follows focus, alongside the global `r: Reload  q: Quit`, which Search hides because those keys type into it
