$ErrorActionPreference = "Stop"

$ReportPath = ".\reports\access-findings.csv"

if (-not (Test-Path $ReportPath)) {
    Write-Error "Findings report not found. Run .\scripts\Find-AccessViolations.ps1 first."
    exit 1
}

$Findings = @(Import-Csv $ReportPath)

$Tests = @(
    @{
        Name = "Unauthorized Finance_Approver role is detected"
        Pass = [bool]($Findings | Where-Object {
            $_.EmployeeID -eq "E1001" -and
            $_.Role -eq "Finance_Approver" -and
            $_.FindingType -eq "UnauthorizedRole"
        })
    },
    @{
        Name = "Terminated employee CRM_Read access is detected"
        Pass = [bool]($Findings | Where-Object {
            $_.EmployeeID -eq "E1005" -and
            $_.Role -eq "CRM_Read" -and
            $_.FindingType -eq "TerminatedEmployeeAccess"
        })
    },
    @{
        Name = "Baseline contains exactly two findings"
        Pass = ($Findings.Count -eq 2)
    }
)

$Passed = 0
$Failed = 0

foreach ($Test in $Tests) {
    if ($Test.Pass) {
        Write-Host "[PASS] $($Test.Name)" -ForegroundColor Green
        $Passed++
    }
    else {
        Write-Host "[FAIL] $($Test.Name)" -ForegroundColor Red
        $Failed++
    }
}

Write-Host ""
Write-Host "Test results: $Passed passed; $Failed failed."

if ($Failed -gt 0) {
    exit 1
}

exit 0
