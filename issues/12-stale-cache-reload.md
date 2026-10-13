# Stale cache: a week-old cache shows at once and reloads behind it

Estimate: 30 minutes

A cache older than seven days is still good enough to show. The app
reloads it in the background and never shows the error screen while any
cache exists.

- [x] A cache older than 7 days shows immediately, with "Reloading" as the status word, in blue like Loading
- [x] A load from the cache never rewrites it, so the files' modification time says when the data arrived
- [x] The new data swaps in with one message. (No test of its own: every `Finished` replaces the data in one Update, and every snapshot after a first launch shows it clearing the status word.)
- [x] A failed or malformed background reload leaves the cache files as they were. (Only the malformed one has a test: a failed download has nothing to write.)
- [x] A failed background reload keeps the old data and shows a brief error as the status word, in red like Error
- [x] A reload (`r` or F5) that fails while characters are on screen keeps them, the same as a failed background reload. This closes a gap issue 11 accepted: since its reload skips the cache, a reload without a network shows the error screen.
