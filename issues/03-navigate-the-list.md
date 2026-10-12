# Navigate the list: from Ackbar down to Luke

Estimate: 20 minutes

The user moves through the character list from the keyboard, and Selected
Character follows the highlight. There is no separate "select" step, as in
lazygit: browsing stays one keystroke per character.

- [ ] Characters is the default panel, focused at launch, with a highlighted border
- [ ] Down arrow and `j` map to `:move_down`; up arrow and `k` to `:move_up`; Selected Character follows
- [ ] A list taller than the panel scrolls, with selection and scroll window kept in the model
- [ ] Home and `g` jump to the first character; End and `G` to the last
- [ ] Enter, Space, PgUp/PgDn, and Ctrl-D/Ctrl-U stay unbound
