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
Go is required to build the formula, not to run the installed program.
Installation never edits `.zshrc`.

## Maintaining releases

1. Run the cdt unit tests, zsh PTY tests, and CI before tagging a release.
2. Publish a new immutable version tag and GitHub release.
3. Update `Formula/cdt.rb` with the source archive URL and SHA-256.
4. Run `brew audit --strict JieteXue/tap/cdt`, install from source, and run
   `brew test JieteXue/tap/cdt` before committing and pushing the formula.

MIT licensed.
