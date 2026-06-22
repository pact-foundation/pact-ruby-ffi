# script/lib

Shared helpers used by the scripts in `script/`.

- `platforms.rb` — the single source of truth for the native libpact_ffi
  libraries and the gem platforms built from them. Required by both
  `script/download_libs.rb` and the `Rakefile`.
