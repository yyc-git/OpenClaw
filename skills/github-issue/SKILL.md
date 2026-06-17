---
name: "github-issue"
description: "Create, list, comment on GitHub issues via API with PAT auth"
---

# GitHub Issue Management Skill

Create, list, and comment on GitHub issues using the GitHub REST API.

## Requirements

- GitHub Personal Access Token (PAT) with `public_repo` or `repo` scope
- Token stored in env variable: `GITHUB_TOKEN` or `GH_TOKEN`
- Or configured via `git config --global github.token`

## Tools

### 1. Create Issue

```powershell
# Via curl (native Windows + auth header)
$headers = @{
    "Accept" = "application/vnd.github.v3+json"
    "Authorization" = "token $env:GITHUB_TOKEN"
}
$body = @{
    title = "Issue title"
    body = "Issue body markdown"
    labels = @("bug", "impact:session-state")
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.github.com/repos/OWNER/REPO/issues" `
    -Method Post -Headers $headers -Body $body -ContentType "application/json"
```

### 2. List Issues

```powershell
$headers = @{
    "Accept" = "application/vnd.github.v3+json"
    "Authorization" = "token $env:GITHUB_TOKEN"
}
Invoke-RestMethod -Uri "https://api.github.com/repos/OWNER/REPO/issues?state=open&per_page=10" `
    -Method Get -Headers $headers
```

### 3. Add Comment

```powershell
$headers = @{
    "Accept" = "application/vnd.github.v3+json"
    "Authorization" = "token $env:GITHUB_TOKEN"
}
$body = @{ body = "Comment text" } | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.github.com/repos/OWNER/REPO/issues/ISSUE_NUMBER/comments" `
    -Method Post -Headers $headers -Body $body -ContentType "application/json"
```

## Usage Pattern

When asked to create an issue:

1. If no GITHUB_TOKEN is set, ask the user to provide one
2. Write the issue body to a temp file for reference
3. Use Invoke-RestMethod to POST to the GitHub API
4. Return the issue URL on success

## Error Handling

- 401: Token missing or invalid → ask user to provide a valid PAT
- 403: Rate limited or insufficient scope → inform user
- 422: Validation error → fix body format and retry

## Configuration

Store the token in environment for persistence:
```powershell
[Environment]::SetEnvironmentVariable("GITHUB_TOKEN", "ghp_xxx", "User")
```
Or add to OpenClaw env config.
