param(
    [string]$Workspace = "$env:USERPROFILE\.openclaw\workspace"
)

$ErrorActionPreference = "Stop"

try {
    Set-Location $Workspace

    # Check for changes
    $status = git status --porcelain
    if (-not $status) {
        Write-Output "No changes to sync"
        exit 0
    }

    # Add all files
    git add -A 2>&1 | Out-Null

    # Commit
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    git commit -m "auto-sync: $timestamp" 2>&1 | Out-Null

    # Push
    git push origin master 2>&1

    Write-Output "Synced to GitHub at $timestamp"
}
catch {
    Write-Output "Sync failed: $_"
    exit 1
}
