# E2E smoke: локальный API + сценарий клиента (MOB-17)
# Требует: Docker, Flutter SDK

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot

Push-Location $Root
try {
    Write-Host "Starting docker compose..."
    docker compose up -d --build

    $healthUrl = if ($env:API_HEALTH_URL) { $env:API_HEALTH_URL } else { "http://localhost:8080/health" }
    $deadline = (Get-Date).AddMinutes(3)

    Write-Host "Waiting for API at $healthUrl ..."
    while ((Get-Date) -lt $deadline) {
        try {
            $response = Invoke-RestMethod -Uri $healthUrl -Method Get -TimeoutSec 5
            if ($response.status -eq "UP") {
                Write-Host "API is UP"
                break
            }
        } catch {
            Start-Sleep -Seconds 3
        }
    }

    if ((Get-Date) -ge $deadline) {
        throw "API did not become healthy within 3 minutes"
    }

    $env:TEMP = Join-Path $Root ".tmp"
    $env:TMP = $env:TEMP
    New-Item -ItemType Directory -Force -Path $env:TEMP | Out-Null

    Push-Location (Join-Path $Root "mobile")
    flutter test test/e2e/api_smoke_test.dart --dart-define=RUN_E2E=true
    Pop-Location
} finally {
    Pop-Location
}
