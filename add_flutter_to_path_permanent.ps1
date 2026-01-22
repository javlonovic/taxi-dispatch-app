# Script to permanently add Flutter to PATH
# Run this as Administrator for system-wide PATH, or as regular user for user PATH

$flutterPath = "C:\Users\Prodigy\Downloads\flutter_windows_3.35.5-stable\flutter\bin"
$flutterBin = $flutterPath

Write-Host "Adding Flutter to PATH permanently..." -ForegroundColor Cyan
Write-Host "Flutter bin path: $flutterBin" -ForegroundColor Yellow
Write-Host ""

# Check if already in PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -like "*$flutterBin*") {
    Write-Host "Flutter is already in PATH!" -ForegroundColor Green
    exit 0
}

# Add to User PATH (doesn't require admin)
try {
    $newPath = $currentPath + ";$flutterBin"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "✓ Flutter added to User PATH successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Note: You need to restart PowerShell/terminal for changes to take effect." -ForegroundColor Yellow
    Write-Host "Or run this command in your current session:" -ForegroundColor Yellow
    Write-Host "`$env:Path += `";$flutterBin`"" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Failed to add Flutter to PATH: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "You can manually add it:" -ForegroundColor Yellow
    Write-Host "1. Press Win + X and select 'System'" -ForegroundColor White
    Write-Host "2. Click 'Advanced system settings'" -ForegroundColor White
    Write-Host "3. Click 'Environment Variables'" -ForegroundColor White
    Write-Host "4. Under 'User variables', select 'Path' and click 'Edit'" -ForegroundColor White
    Write-Host "5. Click 'New' and add: $flutterBin" -ForegroundColor White
    Write-Host "6. Click OK on all dialogs" -ForegroundColor White
}

