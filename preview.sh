#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# Prefer the Ruby installed for this project over macOS's system Ruby.
if [[ -x .preview/ruby/bin/ruby ]]; then
  export PATH="$PWD/.preview/ruby/bin:$PATH"
fi

if ! command -v ruby >/dev/null || ! ruby -e 'exit(Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.1") ? 0 : 1)'; then
  echo "A newer Ruby is required. See the local preview setup in README.md." >&2
  exit 1
fi

export BUNDLE_PATH="$PWD/.preview/gems"
export BUNDLE_USER_HOME="$PWD/.preview/bundle"
if [[ -z "${SSL_CERT_FILE:-}" && -f /etc/ssl/cert.pem ]]; then
  export SSL_CERT_FILE=/etc/ssl/cert.pem
fi

if ! bundle check >/dev/null 2>&1; then
  bundle install
fi

exec bundle exec jekyll serve --livereload --host 127.0.0.1 "$@"
