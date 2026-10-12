# Loading and error states: a first launch without a network

Estimate: 25 minutes

The download is all or nothing. While it runs, the user sees a loading
screen. If it fails, they see what went wrong and can try again.

The status line's status-word slot takes no width while the app is idle and
error-free.

- [x] A first launch without a network shows the reason on an error screen
- [x] A loading screen while the download runs
- [x] An HTTP error status on the root shows a meaningful error with a retry key
- [x] An HTTP error status on a collection shows a meaningful error with a retry key
- [x] A network error on a collection shows a meaningful error with a retry key
- [x] A malformed JSON response on the root shows a meaningful error with a retry key
- [x] Any other exception while loading shows its message with a retry key
- [ ] A malformed JSON response on a collection shows a meaningful error with a retry key
- [ ] A timeout or cancellation (a `nil` message) is handled apart from HTTP errors
- [x] Retry downloads again
- [ ] Panels don't draw until data arrives; remove the `selected&.name.to_s` fallback
