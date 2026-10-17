
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path $PSScriptRoot -Parent
$TestScript = Join-Path $PSScriptRoot "Test-ReviewDecisions.ps1"

$TestFiles = @(
    "sample-review-decisions.csv",
    "test-duplicate-decisions.csv",
    "test-incomplete-review.csv",
    "test-invalid-decision.csv",
    "test-missing-decision.csv"
)

Write-Host "`nIAM Access Certification - Test Suite" -ForegroundColor Cyan
Write-Host "====================================="

$Results = foreach ($TestFile in $TestFiles) {
    $ReviewPath = Join-Path $ProjectRoot "reviews\$TestFile"

    if (-not (Test-Path $ReviewPath)) {
        [PSCustomObject]@{
            Test       = $TestFile
            Result     = "FAIL"
            Details    = "Test file not found"
        }
        continue
    }

    try {
        & $TestScript -ReviewFile $TestFile | Out-Null

        [PSCustomObject]@{
            Test       = $TestFile
            Result     = "PASS"
            Details    = "Script executed successfully"
        }
    }
    catch {
        [PSCustomObject]@{
            Test       = $TestFile
            Result     = "FAIL"
            Details    = $_.Exception.Message
        }
    }
}

$Results | Format-Table -AutoSize

$Failed = @($Results | Where-Object { $_.Result -eq "FAIL" }).Count
$Passed = @($Results | Where-Object { $_.Result -eq "PASS" }).Count

Write-Host "`nPassed: $Passed | Failed: $Failed" -ForegroundColor Cyan
