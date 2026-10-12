# Walking skeleton: browse every character's name

Estimate: 35 minutes

The thinnest slice through every layer. The app downloads the dataset from
the API, lists every character by name, and lays out the wireframe's boxes.
Only the list and the Selected Character box have content yet.

The records are characters (`Character`) everywhere but the loader, which
maps the API's `people`.

- [x] Record the root and six collections from swapi.info as fixtures (ask before touching the live API)
- [x] A local `TCPServer` test helper serves the fixtures
- [x] `exe/sw` fetches the root, then the collections in parallel, and lists all 82 names alphabetically
- [x] The wireframe layout: title, list, Selected Character showing the highlighted name, and empty Films, Starships, and Vehicles boxes
- [ ] A status line: a slot on the left for one status word, and key help for the focused panel filling the rest
- [ ] `q` and Ctrl-C quit
- [x] End-to-end test: against the fixture server, the list shows Ackbar
- [ ] CI runs `bundle exec rake` on Linux, macOS, and Windows on every push
