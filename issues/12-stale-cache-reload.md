# Stale cache: a week-old cache shows at once and reloads behind it

Estimate: 30 minutes

A cache older than seven days is still good enough to show. The app
reloads it in the background and never shows the error screen while any
cache exists.

- [x] A cache older than 7 days shows immediately, with "Reloading" as the status word, in blue like Loading
- [x] A load from the cache never rewrites it, so the files' modification time says when the data arrived
- [ ] The new data swaps in with one message
- [ ] A failed or malformed background reload leaves the cache files as they were
- [ ] A failed background reload keeps the old data and shows a brief error as the status word, in red like Error
- [x] A reload (`r` or F5) that fails while characters are on screen keeps them, the same as a failed background reload. This closes a gap issue 11 accepted: since its reload skips the cache, a reload without a network shows the error screen.
