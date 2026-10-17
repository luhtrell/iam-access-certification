param(
    [string]$ReviewFile = "sample-review-decisions.csv"
)
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path $PSScriptRoot -Parent
$FindingsPath = Join-Path $ProjectRoot "reports\access-findings.csv"
$ReviewsPath = Join-Path $ProjectRoot "reviews\$ReviewFile"
$OutputPath = Join-Path $ProjectRoot "reports\review-validation.csv"

foreach ($Path in @($FindingsPath, $ReviewsPath)) {
    if (-not (Test-Path $Path)) {
        throw "Required file not found: $Path"
    }
}

$Findings = @(Import-Csv $FindingsPath)
$Reviews = @(Import-Csv $ReviewsPath)

$Validation = foreach ($Finding in $Findings) {
    $Matches = @(
        $Reviews | Where-Object {
            $_.EmployeeID -eq $Finding.EmployeeID -and
            $_.Role -eq $Finding.Role
        }
    )

    if ($Matches.Count -eq 0) {
        $Status = "MissingDecision"
        $Decision = ""
        $Reviewer = ""
        $Justification = ""
    }
    elseif ($Matches.Count -gt 1) {
        $Status = "DuplicateDecisions"
        $Decision = ($Matches.Decision -join "; ")
        $Reviewer = ($Matches.Reviewer -join "; ")
        $Justification = "Multiple review records exist for this finding."
    }
    else {
        $Review = $Matches[0]
        $Decision = $Review.Decision
        $Reviewer = $Review.Reviewer
        $Justification = $Review.Justification

        if ($Decision -notin @("Approve", "Revoke")) {
            $Status = "InvalidDecision"
        }
        elseif ([string]::IsNullOrWhiteSpace($Reviewer) -or
                [string]::IsNullOrWhiteSpace($Justification)) {
            $Status = "IncompleteReview"
        }
        else {
            $Status = "DecisionRecorded"
        }
    }

    [PSCustomObject]@{
        EmployeeID = $Finding.EmployeeID
        Name = $Finding.Name
        Role = $Finding.Role
        FindingType = $Finding.FindingType
        Decision = $Decision
        Reviewer = $Reviewer
        ValidationStatus = $Status
        Justification = $Justification
    }
}

$Validation = @($Validation)

$Validation | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8

Write-Host "`nAccess Review Validation" -ForegroundColor Cyan
$Validation | Format-Table EmployeeID, Role, Decision, ValidationStatus -AutoSize
Write-Host "`nReport saved to: $OutputPath"
