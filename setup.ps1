$ErrorActionPreference = "Stop"

Write-Host "== ALM MCP Local Setup ==" -ForegroundColor Cyan

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$examplePath = Join-Path $repoRoot ".vscode\mcp.json.example"
$targetPath = Join-Path $repoRoot ".vscode\mcp.json"

if (-not (Test-Path $examplePath)) {
    throw "Template file not found: $examplePath"
}

Write-Host "Enter shared ALM MCP API key (hidden):" -ForegroundColor Yellow
$secureKey = Read-Host "API Key" -AsSecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
try {
    $apiKey = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
}
finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
}

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    throw "API key is required."
}

$content = Get-Content -Path $examplePath -Raw
$content = $content.Replace("<YOUR_API_KEY_HERE>", $apiKey)

$vscodeDir = Split-Path -Parent $targetPath
if (-not (Test-Path $vscodeDir)) {
    New-Item -Path $vscodeDir -ItemType Directory | Out-Null
}

Set-Content -Path $targetPath -Value $content -Encoding UTF8

Write-Host "Local MCP config created: $targetPath" -ForegroundColor Green
Write-Host "If VS Code does not pick it up immediately, reload the window." -ForegroundColor Green
