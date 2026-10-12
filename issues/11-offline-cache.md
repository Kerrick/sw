# Offline cache: the second launch needs no network

Estimate: 30 minutes

The raw JSON is cached on disk, so a parsing fix applies without a new
download.

- [ ] Raw responses go under the `etcetera` user cache directory, pointed at a temp directory by the environment in tests
- [ ] A fresh cache means no network at all
- [ ] `--refresh` downloads now, even when the cache is fresh
