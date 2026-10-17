param(
    [Parameter(Mandatory = $true)]
    [string]$FindingID,

    [Parameter(Mandatory = $true)]
    [ValidateSet("Open", "In Progress", "Closed")]
    [string]$Status,

    [string]$Owner,

    [string]$Notes
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$TrackerPath = Join-Path $ProjectRoot "reports\remediation-tracker.csv"

if (-not (Test-Path $TrackerPath)) {
    throw "Remediation tracker not found. Run Update-RemediationTracker.ps1 first."
}

$Rows = @(Import-Csv $TrackerPath)

if ($Rows.Count -eq 0) {
    throw "The remediation tracker contains no findings."
}

$Matches = @($Rows | Where-Object { $_.FindingID -eq $FindingID })

if ($Matches.Count -ne 1) {
    throw "Expected exactly one finding with ID '$FindingID'; found $($Matches.Count)."
}

$Finding = $Matches[0]

if ($Status -eq "Closed" -and [string]::IsNullOrWhiteSpace($Notes)) {
    throw "Closure requires Notes documenting the completed remediation and evidence."
}

if ($Status -eq "Closed" -and
    [string]::IsNullOrWhiteSpace($Finding.CompletedDate)) {
    $Finding.CompletedDate = (Get-Date -Format "yyyy-MM-dd")
}

if ($Status -ne "Closed") {
    $Finding.CompletedDate = ""
}

if (-not [string]::IsNullOrWhiteSpace($Owner)) {
    $Finding.Owner = $Owner
}

if (-not [string]::IsNullOrWhiteSpace($Notes)) {
    $Finding.Notes = $Notes
}

$Finding.Status = $Status
$Finding.LastUpdated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$Rows | Export-Csv -Path $TrackerPath -NoTypeInformation -Encoding UTF8

Write-Host "`nRemediation status updated" -ForegroundColor Cyan
$Finding | Select-Object FindingID, EmployeeID, Role, Status, Owner, DueDate, CompletedDate, Notes |
    Format-List
Write-Host "Tracker saved to: $TrackerPath"
