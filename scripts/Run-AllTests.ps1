$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path $PSScriptRoot -Parent
$Validator = Join-Path $PSScriptRoot "Test-ReviewDecisions.ps1"
$OutputPath = Join-Path $ProjectRoot "reports\review-validation.csv"

$Tests = @(
    @{
        File = "sample-review-decisions.csv"
        Expected = @{
            E1001 = "DecisionRecorded"
            E1005 = "DecisionRecorded"
        }
    },
    @{
        File = "test-duplicate-decisions.csv"
        Expected = @{
            E1001 = "DuplicateDecisions"
            E1005 = "MissingDecision"
        }
    },
    @{
        File = "test-incomplete-review.csv"
        Expected = @{
            E1001 = "IncompleteReview"
            E1005 = "MissingDecision"
        }
    },
    @{
        File = "test-invalid-decision.csv"
        Expected = @{
            E1001 = "InvalidDecision"
            E1005 = "MissingDecision"
        }
    },
    @{
        File = "test-missing-decision.csv"
        Expected = @{
            E1001 = "DecisionRecorded"
            E1005 = "MissingDecision"
        }
    }
)

$Passed = 0
$Failed = 0

foreach ($Test in $Tests) {
    Write-Host "`nTesting $($Test.File)..." -ForegroundColor Cyan

    try {
        & $Validator -ReviewFile $Test.File

        $Results = @(Import-Csv $OutputPath)
        $Errors = @()

        foreach ($EmployeeID in $Test.Expected.Keys) {
            $ExpectedStatus = $Test.Expected[$EmployeeID]
            $ActualRows = @(
                $Results | Where-Object { $_.EmployeeID -eq $EmployeeID }
            )

            if ($ActualRows.Count -ne 1) {
                $Errors += "$EmployeeID`: expected one result, found $($ActualRows.Count)"
            }
            elseif ($ActualRows[0].ValidationStatus -ne $ExpectedStatus) {
                $Errors += "$EmployeeID`: expected $ExpectedStatus, got $($ActualRows[0].ValidationStatus)"
            }
        }

        if ($Errors.Count -eq 0) {
            Write-Host "PASS: $($Test.File)" -ForegroundColor Green
            $Passed++
        }
        else {
            Write-Host "FAIL: $($Test.File)" -ForegroundColor Red
            $Errors | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
            $Failed++
        }
    }
    catch {
        Write-Host "FAIL: $($Test.File) - $($_.Exception.Message)" -ForegroundColor Red
        $Failed++
    }
}

Write-Host "`n========== TEST SUMMARY ==========" -ForegroundColor Cyan
Write-Host "Passed: $Passed" -ForegroundColor Green
Write-Host "Failed: $Failed" -ForegroundColor $(if ($Failed -gt 0) { "Red" } else { "Green" })

if ($Failed -gt 0) {
    throw "One or more tests failed."
}

Write-Host "`nAll tests passed." -ForegroundColor Green
