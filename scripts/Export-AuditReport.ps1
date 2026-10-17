$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path $PSScriptRoot -Parent

$FindingsPath = Join-Path $ProjectRoot "reports\access-findings.csv"
$ValidationPath = Join-Path $ProjectRoot "reports\review-validation.csv"
$SummaryPath = Join-Path $ProjectRoot "reports\audit-summary.csv"

if (-not (Test-Path $FindingsPath)) {
    throw "Findings report not found. Run Find-AccessViolations.ps1 first."
}

$Findings = @(Import-Csv $FindingsPath)
if (Test-Path $ValidationPath) {
    $Validation = @(Import-Csv $ValidationPath)
}
else {
    $Validation = @()
    Write-Warning "Validation report not found. Validation metrics will be zero."
}

$Summary = @(
    [PSCustomObject]@{
        Metric = "Total Findings"
        Value = $Findings.Count
    }
    [PSCustomObject]@{
        Metric = "High Severity"
        Value = @($Findings | Where-Object Severity -eq "High").Count
    }
    [PSCustomObject]@{
        Metric = "Medium Severity"
        Value = @($Findings | Where-Object Severity -eq "Medium").Count
    }
    [PSCustomObject]@{
        Metric = "Unauthorized Roles"
        Value = @($Findings | Where-Object FindingType -eq "UnauthorizedRole").Count
    }
    [PSCustomObject]@{
        Metric = "Terminated Employee Access"
        Value = @($Findings | Where-Object FindingType -eq "TerminatedEmployeeAccess").Count
    }
        [PSCustomObject]@{
        Metric = "Review Decisions Recorded"
        Value = @($Validation | Where-Object {
            $_.ValidationStatus -eq "DecisionRecorded"
        }).Count
    }
    [PSCustomObject]@{
        Metric = "Incomplete Reviews"
        Value = @($Validation | Where-Object {
            $_.ValidationStatus -eq "IncompleteReview" -or
            $_.ValidationStatus -eq "MissingDecision"
        }).Count
    }
    [PSCustomObject]@{
        Metric = "Duplicate Decisions"
        Value = @($Validation | Where-Object {
            $_.ValidationStatus -eq "DuplicateDecisions"
        }).Count
    }
    [PSCustomObject]@{
        Metric = "Invalid Decisions"
        Value = @($Validation | Where-Object {
            $_.ValidationStatus -eq "InvalidDecision"
        }).Count
    }
)

$Summary | Export-Csv -Path $SummaryPath -NoTypeInformation -Encoding UTF8

Write-Host "`nIAM Audit Summary" -ForegroundColor Cyan
$Summary | Format-Table -AutoSize
Write-Host "Summary saved to: $SummaryPath"
