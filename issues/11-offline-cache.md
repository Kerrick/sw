# Offline cache: the second launch needs no network

Estimate: 30 minutes

The raw JSON is cached on disk, so a parsing fix applies without a new
download.

- [x] Raw responses go under the `etcetera` user cache directory, pointed at a temp directory by the environment in tests
- [x] A fresh cache means no network at all
- [x] `r` and F5 reload now, even when the cache is fresh. No `--refresh` flag: once the app is open, a keystroke does the same. Accepted gap: until issue 12's last item, a reload without a network shows the error screen, though a cache exists.
