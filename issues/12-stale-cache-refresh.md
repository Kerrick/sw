# Stale cache: a week-old cache shows at once and refreshes behind it

Estimate: 30 minutes

A cache older than seven days is still good enough to show. The app
refreshes it in the background and never shows the error screen while any
cache exists.

- [ ] A cache older than 7 days shows immediately, with "Refreshing" as the status word, in blue like Loading
- [ ] A load from the cache never rewrites it, so the files' modification time says when the data arrived
- [ ] The new data swaps in with one message
- [ ] A failed or malformed refresh leaves the cache files as they were
- [ ] A failed refresh keeps the old data and shows a brief error as the status word, in red like Error
- [ ] A reload (`r` or F5) that fails while characters are on screen keeps them, the same as a failed refresh
