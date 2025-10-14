# Open a prefilled PR page for branch 'my-feature' -> main
# Usage: run this in PowerShell from the repo root: .\scripts\open_pr.ps1

$owner = 'nikolaini-byte'
$repo = 'Escape-from-tarkov-promo-code-manager'
$head = 'my-feature'
$base = 'main'

$title = 'feat: demo mode + refactor logic to src/logic.js, add tests & CI'
$body = @'
Summary
- Adds a non-destructive in-app Demo mode (visual playback of extract → queue → copy → mark-used).
- Extracts core logic into a testable module `src/logic.js` and adds unit tests (`test/logic.test.js`) using Vitest.
- Adds GitHub Actions CI to run `npm test` on push/PR.
- Adds short developer instructions to `README.md`.
- Small UX polish: demo badge for demo rows and an inline favicon to eliminate local 404s.
- Includes a small demo GIF used in the README.

How to test locally
1. npm install && npm test
2. python -m http.server 8000
3. Open http://localhost:8000 and verify Extract/Queue/Demo flows.

Notes
- index.html uses ES modules; serve via a static server (python or http-server).
- Demo is non-persistent; it does not modify LocalStorage.
'@

# URL encode function
function UrlEncode([string]$s) {
  return [System.Uri]::EscapeDataString($s)
}

$u = "https://github.com/$owner/$repo/compare/$base...$head?expand=1&title=$(UrlEncode $title)&body=$(UrlEncode $body)"
Write-Host "Opening PR URL in your browser..."
Start-Process $u
Write-Host "If your browser didn't open, paste this URL into your browser:`n$u"