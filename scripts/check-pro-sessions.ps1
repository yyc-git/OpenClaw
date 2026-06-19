param(
    [int]$LookbackHours = 2
)

$sessionsPath = "$env:USERPROFILE\.openclaw\agents\main\sessions\sessions.json"
$lastCheckFile = "$env:USERPROFILE\.openclaw\tmp_pro_session_check.txt"

if (-not (Test-Path $sessionsPath)) {
    Write-Output "NO_SESSIONS_FILE"
    exit 0
}

# Read last check timestamp
$lastCheck = 0
if (Test-Path $lastCheckFile) {
    $lastCheck = [long](Get-Content $lastCheckFile -Raw).Trim()
}

$now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

try {
    $sessionsJson = Get-Content $sessionsPath -Raw | ConvertFrom-Json
} catch {
    Write-Output "PARSE_ERROR"
    exit 0
}

$proSessions = @()
$newProSessions = @()

$sessionsJson.PSObject.Properties | ForEach-Object {
    $s = $_.Value
    if ($s.model -eq 'deepseek-v4-pro') {
        $updated = [DateTimeOffset]::FromUnixTimeMilliseconds($s.updatedAt).LocalDateTime
        $ageHours = ([DateTime]::Now - $updated).TotalHours
        if ($ageHours -le $LookbackHours) {
            $proSessions += [PSCustomObject]@{
                Key = $_.Name
                Model = $s.model
                Updated = $updated.ToString('HH:mm:ss')
                AgeHours = [math]::Round($ageHours, 1)
                Input = $s.inputTokens
                Output = $s.outputTokens
                Cost = $s.estimatedCostUsd
                Created = [DateTimeOffset]::FromUnixTimeMilliseconds($s.startedAt).LocalDateTime.ToString('HH:mm:ss')
            }
            # Check if this is new since last check
            if ($s.updatedAt -gt $lastCheck) {
                $newProSessions += $_
            }
        }
    }
}

# Save current time for next check
$now | Out-File -FilePath $lastCheckFile -Force

if ($proSessions.Count -eq 0) {
    Write-Output "CLEAN: No Pro sessions found in last $LookbackHours hours"
    exit 0
}

# Build alert message
$alert = "⚠️ Pro 会话检测到！`n"
$proSessions | ForEach-Object {
    $alert += "• [$($_.Created)→$($_.Updated)] 费用: `$$([math]::Round($_.Cost,4)) I:$($_.Input)/O:$($_.Output)`n"
}
$alert += "`n建议检查 Dashboard 是否又被切到了 Pro！"

if ($newProSessions.Count -gt 0) {
    Write-Output "ALERT:$alert"
} else {
    Write-Output "KNOWN: Pro sessions exist but no new ones since last check"
}
exit 0
