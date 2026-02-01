Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

dart format --set-exit-if-changed .
flutter analyze
flutter test
