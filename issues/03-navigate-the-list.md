# Navigate the list: from Ackbar down to Luke

Estimate: 20 minutes

The user moves through the character list from the keyboard, and Selected
Character follows the highlight. There is no separate "select" step, as in
lazygit: browsing stays one keystroke per character.

- [x] End-to-end test: moving down from Ackbar reaches Luke Skywalker
- [x] Characters is the default panel, focused at launch, with a highlighted border
- [x] Down arrow and `j` map to `:move_down`; up arrow and `k` to `:move_up`; Selected Character follows
- [x] A list taller than the panel scrolls to keep the selection visible
- [x] Home and `g` jump to the first character; End and `G` to the last
- [x] Enter, Space, PgUp/PgDn, and Ctrl-D/Ctrl-U stay unbound (holds by absence; no test drives it)
- [x] The status line lists the list's keys, lazygit-style, in the hotkey style (bold, underlined); CUA keys work but aren't listed
