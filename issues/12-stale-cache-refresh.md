# Stale cache: a week-old cache shows at once and refreshes behind it

Estimate: 30 minutes

A cache older than seven days is still good enough to show. The app
refreshes it in the background and never shows the error screen while any
cache exists.

- [ ] A cache older than 7 days shows immediately, with "Refreshing" as the status word
- [ ] The new data swaps in with one message
- [ ] A failed refresh keeps the old data and shows a brief error as the status word
