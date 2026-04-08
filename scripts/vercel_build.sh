#!/usr/bin/env bash
# Vercel Linux build: Flutter is not preinstalled; clone stable SDK then build web.
set -euo pipefail

cd "$(dirname "$0")/.."

if command -v flutter >/dev/null 2>&1; then
  flutter config --enable-web >/dev/null
  flutter pub get
  exec flutter build web --release
fi

FLUTTER_ROOT="${FLUTTER_ROOT:-$HOME/flutter_stable}"
if [[ ! -x "$FLUTTER_ROOT/bin/flutter" ]]; then
  echo "Installing Flutter SDK (stable)..."
  rm -rf "$FLUTTER_ROOT"
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_ROOT"
fi

export PATH="$FLUTTER_ROOT/bin:$PATH"
flutter config --enable-web >/dev/null
flutter pub get
flutter build web --release
