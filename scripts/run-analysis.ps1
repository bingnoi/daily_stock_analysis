# 本地执行股票分析（需 Python 3.11 + 已配置 .env）
# 用法: .\scripts\run-analysis.ps1          # 完整分析
#       .\scripts\run-analysis.ps1 -DryRun  # 仅拉数据不调用 AI
#       .\scripts\run-analysis.ps1 -MarketOnly  # 仅大盘复盘

param(
    [switch]$DryRun,
    [switch]$MarketOnly
)

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
if (-not (Test-Path (Join-Path $root "main.py"))) {
    Write-Error "请在项目根目录（含 main.py）下执行，或从 scripts 目录运行."
}
Set-Location $root

# 避免 pip/请求走无效代理
$env:NO_PROXY = "*"
$env:no_proxy = "*"
foreach ($k in @("http_proxy","https_proxy","HTTP_PROXY","HTTPS_PROXY","all_proxy","ALL_PROXY")) {
    if (Get-Item "Env:$k" -ErrorAction SilentlyContinue) { Remove-Item "Env:$k" -ErrorAction SilentlyContinue }
}

if ($DryRun) {
    python main.py --dry-run
} elseif ($MarketOnly) {
    python main.py --market-review
} else {
    python main.py
}
