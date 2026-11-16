param(
    [int]$Port = 8000,
    [string]$HostAddress = '0.0.0.0'
)

$ErrorActionPreference = 'Stop'

$laravelRoot = Resolve-Path (Join-Path $PSScriptRoot '..\keuangan-app')

$listening = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
if ($listening) {
    Write-Host "Server running on http://127.0.0.1:$Port (port $Port sudah digunakan, server dianggap siap)."
    exit 0
}

if (-not (Get-Command php -ErrorAction SilentlyContinue)) {
    Write-Host "PHP tidak ditemukan di PATH. Pastikan PHP sudah terpasang dan masuk PATH."
    exit 1
}

Write-Host "Menjalankan Laravel di http://$HostAddress`:$Port ..."
Set-Location -LiteralPath $laravelRoot

php artisan serve --host=$HostAddress --port=$Port
