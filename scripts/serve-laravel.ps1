param(
    [int]$Port = 8000,
    [string]$HostAddress = '0.0.0.0'
)

$ErrorActionPreference = 'Stop'

$laravelRoot = Resolve-Path (Join-Path $PSScriptRoot '..\keuangan-app')

# Baris "[laravel] memulai ..." dan "[laravel] siap ..." dipakai tasks.json
# sebagai beginsPattern / endsPattern. Keduanya harus baris terpisah, kalau
# tidak VS Code tidak pernah menganggap task background ini siap.
Write-Host "[laravel] memulai di http://${HostAddress}:$Port"

$listening = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
if ($listening) {
    Write-Host "[laravel] siap di http://127.0.0.1:$Port (port $Port sudah dipakai, memakai server yang sudah jalan)"
    # Jangan langsung keluar: selama task ini hidup, VS Code tahu prasyaratnya
    # masih terpenuhi dan tidak membatalkan launch Flutter.
    while (Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue) {
        Start-Sleep -Seconds 5
    }
    exit 0
}

if (-not (Get-Command php -ErrorAction SilentlyContinue)) {
    Write-Host "[laravel] PHP tidak ditemukan di PATH. Pastikan PHP sudah terpasang dan masuk PATH."
    exit 1
}

Set-Location -LiteralPath $laravelRoot

php artisan serve --host=$HostAddress --port=$Port
