<#
Create a Pull Request via the GitHub API.
Usage (recommended):
  # set token in env (powershell session)
  $env:GITHUB_TOKEN = 'ghp_...'
  .\scripts\create_pr_api.ps1 -Owner 'nikolaini-byte' -Repo 'Escape-from-tarkov-promo-code-manager' -Head 'my-feature' -Base 'main'

It will default to the repo and branch names used in this project; you can override via parameters.

Security note: prefer setting GITHUB_TOKEN as an environment variable and never paste it into chat.
You must create a token with 'repo' scope (for private repos) or minimal 'public_repo' for public.
#>
param(
  [string]$Owner = 'nikolaini-byte',
  [string]$Repo = 'Escape-from-tarkov-promo-code-manager',
  [string]$Head = 'my-feature',
  [string]$Base = 'main',
  [string]$Title = 'feat: demo mode + refactor logic to src/logic.js, add tests & CI',
  [string]$Body = $(
@'
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
  )
)

function Get-Token {
  if($env:GITHUB_TOKEN -and $env:GITHUB_TOKEN.Trim() -ne ''){ return $env:GITHUB_TOKEN }
  Write-Host 'GITHUB_TOKEN not found in environment. You can create one at https://github.com/settings/tokens (no scopes needed for public repos, use repo/public_repo as appropriate).' -ForegroundColor Yellow
  $sec = Read-Host -AsSecureString 'Enter your GitHub Personal Access Token (input hidden)'
  $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
  try{ return [Runtime.InteropServices.Marshal]::PtrToStringAuto($ptr) } finally{ [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
}

$token = Get-Token
if(-not $token){ Write-Error 'No token provided, aborting.'; exit 1 }

$uri = "https://api.github.com/repos/$Owner/$Repo/pulls"
$bodyObj = @{ title = $Title; head = $Head; base = $Base; body = $Body }
$json = $bodyObj | ConvertTo-Json -Depth 6

$headers = @{
  Authorization = "token $token"
  'User-Agent' = 'create-pr-script'
}

try{
  $resp = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $json -ContentType 'application/json' -ErrorAction Stop
  Write-Host "Pull request created: $($resp.html_url)" -ForegroundColor Green
}catch{
  Write-Error "Failed to create PR: $($_.Exception.Message)"
  if ($_.Exception.Response) {
    try{ $text = $_.Exception.Response.GetResponseStream() | % { $_ } } catch{}
  }
  exit 1
}
