# Flutter PATH Setup Script
# This script helps you find Flutter or add it to PATH

Write-Host "=== Flutter PATH Setup ===" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is already accessible
$flutterCheck = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutterCheck) {
    Write-Host "✓ Flutter is already in PATH!" -ForegroundColor Green
    Write-Host "Location: $($flutterCheck.Source)" -ForegroundColor Green
    flutter --version
    exit 0
}

Write-Host "Flutter not found in PATH. Searching for Flutter installation..." -ForegroundColor Yellow
Write-Host ""

# Common Flutter installation locations
$commonPaths = @(
    "$env:LOCALAPPDATA\Android\flutter",
    "C:\src\flutter",
    "$env:USERPROFILE\flutter",
    "C:\flutter",
    "D:\flutter",
    "$env:ProgramFiles\flutter"
)

$foundFlutter = $null

foreach ($path in $commonPaths) {
    $flutterPath = Join-Path $path "bin\flutter.bat"
    if (Test-Path $flutterPath) {
        $foundFlutter = $path
        Write-Host "✓ Found Flutter at: $path" -ForegroundColor Green
        break
    }
}

if ($foundFlutter) {
    $flutterBin = Join-Path $foundFlutter "bin"
    Write-Host ""
    Write-Host "To use Flutter in this session, run:" -ForegroundColor Yellow
    Write-Host "`$env:Path += `";$flutterBin`"" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To add Flutter to PATH permanently:" -ForegroundColor Yellow
    Write-Host "1. Press Win + X and select 'System'" -ForegroundColor White
    Write-Host "2. Click 'Advanced system settings'" -ForegroundColor White
    Write-Host "3. Click 'Environment Variables'" -ForegroundColor White
    Write-Host "4. Under 'User variables', select 'Path' and click 'Edit'" -ForegroundColor White
    Write-Host "5. Click 'New' and add: $flutterBin" -ForegroundColor White
    Write-Host "6. Click OK on all dialogs" -ForegroundColor White
    Write-Host ""
    
    $addToPath = Read-Host "Add Flutter to PATH for this session? (Y/N)"
    if ($addToPath -eq 'Y' -or $addToPath -eq 'y') {
        $env:Path += ";$flutterBin"
        Write-Host "✓ Flutter added to PATH for this session" -ForegroundColor Green
        Write-Host ""
        flutter --version
    }
} else {
    Write-Host "✗ Flutter not found in common locations" -ForegroundColor Red
    Write-Host ""
    Write-Host "To install Flutter:" -ForegroundColor Yellow
    Write-Host "1. Download Flutter SDK from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
    Write-Host "2. Extract to a location (e.g., C:\src\flutter)" -ForegroundColor White
    Write-Host "3. Add the flutter\bin directory to your PATH" -ForegroundColor White
    Write-Host ""
    Write-Host "Or if you know where Flutter is installed, run:" -ForegroundColor Yellow
    Write-Host "`$env:Path += `";C:\path\to\flutter\bin`"" -ForegroundColor Cyan
}

