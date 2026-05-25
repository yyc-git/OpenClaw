# openclaw-backup-sync: 一键备份 workspace 到 Git
param(
    [string]$RepoUrl,
    [switch]$PushOnly,
    [switch]$CloneOnly,
    [string]$CloneUrl
)

$workspace = "$env:USERPROFILE\.openclaw\workspace"

if ($CloneOnly -and $CloneUrl) {
    Write-Host "=== 从 $CloneUrl 克隆 workspace ==="
    git clone $CloneUrl $workspace
    Write-Host "完成！"
    exit
}

if (-not (Test-Path "$workspace\.git")) {
    if (-not $RepoUrl) {
        Write-Host "错误: 需要提供 -RepoUrl 来初始化 Git 仓库"
        exit 1
    }
    Write-Host "=== 初始化 Git 仓库 ==="
    Set-Location $workspace
    git init
    git add .
    git commit -m "sync: backup $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    git remote add origin $RepoUrl
    git push -u origin main
    Write-Host "完成！"
    exit
}

Set-Location $workspace
Write-Host "=== 同步到 Git ==="
git add .
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "无变更，跳过"
    exit
}
git commit -m "sync: backup $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push
Write-Host "同步完成！"
