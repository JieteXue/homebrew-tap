# JieteXue Homebrew Tap

## cdt

```sh
brew install JieteXue/tap/cdt
```

Enable in zsh after your existing completion setup:

```sh
eval "$(command cdt init zsh)"
```

Project: [JieteXue/cdt](https://github.com/JieteXue/cdt).
Homebrew automatically downloads the precompiled Apple Silicon or Intel package.
Installing cdt does not require Go and does not compile the project on your Mac.
Installation never edits `.zshrc`.

## Maintaining releases

1. Run the cdt unit tests, zsh PTY tests, and CI before tagging a release.
2. Push a new immutable version tag. The cdt release workflow tests both native
   architectures, then publishes binary archives and `checksums.txt`.
3. Update both architecture URLs and SHA-256 values in `Formula/cdt.rb`.
4. Run `brew audit --strict JieteXue/tap/cdt`, install the precompiled package, and run
   `brew test JieteXue/tap/cdt` before committing and pushing the formula.

MIT licensed.
