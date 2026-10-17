
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path $PSScriptRoot -Parent
$FindingsPath = Join-Path $ProjectRoot "reports\access-findings.csv"
$ReviewsPath = Join-Path $ProjectRoot "reports\review-validation.csv"
$TrackerPath = Join-Path $ProjectRoot "reports\remediation-tracker.csv"

foreach ($Path in @($FindingsPath, $ReviewsPath)) {
    if (-not (Test-Path $Path)) {
        throw "Required input file not found: $Path"
    }
}

$Findings = @(Import-Csv $FindingsPath)
$Reviews = @(Import-Csv $ReviewsPath)

# Load existing tracker so reruns preserve remediation progress.
$Existing = @{}
if (Test-Path $TrackerPath) {
    foreach ($Item in (Import-Csv $TrackerPath)) {
        $Existing[$Item.FindingID] = $Item
    }
}

$Tracker = foreach ($Finding in $Findings) {
    $FindingID = "$($Finding.EmployeeID)|$($Finding.Role)|$($Finding.FindingType)"

    $Review = $Reviews |
        Where-Object {
            $_.EmployeeID -eq $Finding.EmployeeID -and
            $_.Role -eq $Finding.Role
        } |
        Select-Object -First 1

    $Decision = if ($Review) { $Review.Decision } else { "PendingReview" }
    $Reviewer = if ($Review) { $Review.Reviewer } else { "" }
    $Justification = if ($Review) { $Review.Justification } else { "" }

    if ($Existing.ContainsKey($FindingID)) {
        $Previous = $Existing[$FindingID]
        $Status = $Previous.Status
        $Owner = $Previous.Owner
        $DueDate = $Previous.DueDate
        $CompletedDate = $Previous.CompletedDate
        $Notes = $Previous.Notes
    }
    else {
        $Status = "Open"
        $Owner = "IAM Operations"
        $DueDate = (Get-Date).AddDays(14).ToString("yyyy-MM-dd")
        $CompletedDate = ""
        $Notes = ""
    }

    [PSCustomObject]@{
        FindingID       = $FindingID
        EmployeeID      = $Finding.EmployeeID
        Name            = $Finding.Name
        Role            = $Finding.Role
        FindingType     = $Finding.FindingType
        Severity        = $Finding.Severity
        Decision        = $Decision
        Reviewer        = $Reviewer
        Justification   = $Justification
        RemediationAction = if ($Decision -eq "Revoke") {
            "Revoke assigned access"
        }
        elseif ($Decision -eq "PendingReview") {
            "Obtain access review decision"
        }
        else {
            "Confirm required follow-up"
        }
        Status          = $Status
        Owner           = $Owner
        DueDate         = $DueDate
        CompletedDate   = $CompletedDate
        Notes           = $Notes
        LastUpdated     = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }
}

$Tracker = @($Tracker)
$Tracker | Export-Csv -Path $TrackerPath -NoTypeInformation -Encoding UTF8

Write-Host "`nRemediation tracker updated." -ForegroundColor Cyan
Write-Host "Findings tracked: $($Tracker.Count)"
Write-Host "Report saved to: $TrackerPath"

if ($Tracker.Count -gt 0) {
    $Tracker |
        Format-Table EmployeeID, Role, Decision, Status, Owner, DueDate -AutoSize
}
