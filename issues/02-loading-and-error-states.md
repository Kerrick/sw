# Loading and error states: a first launch without a network

Estimate: 25 minutes

The download is all or nothing. While it runs, the user sees a loading
screen. If it fails, they see what went wrong and can try again.

- [ ] A loading screen while the download runs
- [ ] An HTTP error status shows a meaningful error with a retry key
- [ ] A malformed JSON response shows a meaningful error with a retry key
- [ ] A timeout or cancellation (a `nil` message) is handled apart from HTTP errors
- [ ] Retry downloads again
