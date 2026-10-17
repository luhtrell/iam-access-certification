$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path $PSScriptRoot -Parent
$FindingsPath = Join-Path $ProjectRoot "reports\access-findings.csv"
$ValidationPath = Join-Path $ProjectRoot "reports\review-validation.csv"
$TrailPath = Join-Path $ProjectRoot "reports\audit-trail.csv"

foreach ($Path in @($FindingsPath, $ValidationPath)) {
    if (-not (Test-Path $Path)) {
        throw "Required report not found: $Path"
    }
}

$Findings = @(Import-Csv $FindingsPath)
$Reviews = @(Import-Csv $ValidationPath)

$Trail = foreach ($Finding in $Findings) {
    $Review = @(
        $Reviews | Where-Object {
            $_.EmployeeID -eq $Finding.EmployeeID -and
            $_.Role -eq $Finding.Role
        }
    ) | Select-Object -First 1

    [PSCustomObject]@{
        EmployeeID = $Finding.EmployeeID
        Name = $Finding.Name
        Role = $Finding.Role
        FindingType = $Finding.FindingType
        Severity = $Finding.Severity
        Decision = $Review.Decision
        Reviewer = $Review.Reviewer
        ValidationStatus = $Review.ValidationStatus
        Justification = $Review.Justification
        TrailGeneratedDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    }
}

$Trail = @($Trail)
$Trail | Export-Csv -Path $TrailPath -NoTypeInformation -Encoding UTF8

Write-Host "`nIAM Audit Trail" -ForegroundColor Cyan
$Trail | Format-Table EmployeeID, Role, Severity, Decision, ValidationStatus -AutoSize
Write-Host "`nAudit trail saved to: $TrailPath"
