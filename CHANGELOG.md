## [Unreleased]

### Added

- List every Star Wars character by name, downloaded from swapi.info.
- Lay out the screen as the brief's wireframe does, with the highlighted character's name beside the list.
- Quit with q or Ctrl-C.
- Reload the data with r or F5, whether it is loading, failed, or on screen.
- Move through the character list with the arrow keys or j and k, and jump to either end with Home and End or g and G. The character beside the list follows the highlight.
- Start with the character list focused, and show the focused panel with a green border.
- Show the keys you can press under the title, with the list's keys first, dimmed so that status words like Loading and Error stand out.
- Show the vehicles the highlighted character pilots in the Vehicles panel, each with its class, crew and passengers, model, and manufacturer, as the wireframe does.
- Dim any value the data doesn't know, such as a vehicle's unknown passengers or manufacturer.
- Say so in the Vehicles panel, dimmed, when the highlighted character pilots no vehicles.
- Search the characters by name: press / or 1, then type or paste to narrow the list as you go. Say so when nothing matches.
- Keep the search and return to the list with Enter, or clear it with Esc from either place. Backspace deletes a character, and Ctrl-U clears the query.
- Move between Search and the list with Tab and Shift-Tab, keeping the search.
- Type q, r, and the number keys into Search like any other key. Ctrl-C still quits from it, and F5 still reloads.
- Show Search in its own box at the top right, with a cursor blinking after the query while it has focus.
- Number each panel that takes focus in its title, [1] Search and [2] Characters, as its number key.
- List Enter and Esc in the key help while you search, and Esc in the list's key help while a search narrows it.
- Show a loading screen, with a blue Loading status word, while the data downloads.
- Show why the download failed, with a red Error status word, when the first launch has no network or the server answers with an error, with something that isn't JSON, or with data the Datapad can't read.

## [0.1.0] - 2026-10-12

- Initial release
