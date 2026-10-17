$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path $PSScriptRoot -Parent
$EmployeesPath = Join-Path $ProjectRoot "data\employees.csv"
$ApprovedRolesPath = Join-Path $ProjectRoot "data\approved_roles.csv"
$AssignmentsPath = Join-Path $ProjectRoot "data\access_assignments.csv"
$ReportsPath = Join-Path $ProjectRoot "reports"
$FindingsPath = Join-Path $ReportsPath "access-findings.csv"

foreach ($Path in @($EmployeesPath, $ApprovedRolesPath, $AssignmentsPath)) {
    if (-not (Test-Path $Path)) {
        throw "Required input file not found: $Path"
    }
}

New-Item -Path $ReportsPath -ItemType Directory -Force | Out-Null

$Employees = Import-Csv $EmployeesPath
$ApprovedRoles = Import-Csv $ApprovedRolesPath
$Assignments = Import-Csv $AssignmentsPath

$EmployeeLookup = @{}
foreach ($Employee in $Employees) {
    $EmployeeLookup[$Employee.EmployeeID] = $Employee
}

$ApprovedRoleLookup = @{}
foreach ($Rule in $ApprovedRoles) {
    $Key = "$($Rule.Department)|$($Rule.JobTitle)|$($Rule.ApprovedRole)"
    $ApprovedRoleLookup[$Key] = $true
}

$Findings = foreach ($Assignment in $Assignments) {
    $Employee = $EmployeeLookup[$Assignment.EmployeeID]

    if (-not $Employee) {
        [PSCustomObject]@{
            EmployeeID = $Assignment.EmployeeID
            Name = "Unknown employee"
            Role = $Assignment.Role
            FindingType = "UnknownEmployee"
            Severity = "High"
            Details = "Assignment references an employee missing from the employee dataset."
        }
        continue
    }

    if ($Employee.Status -eq "Terminated") {
        [PSCustomObject]@{
            EmployeeID = $Employee.EmployeeID
            Name = $Employee.Name
            Role = $Assignment.Role
            FindingType = "TerminatedEmployeeAccess"
            Severity = "High"
            Details = "Employee is terminated but still has an assigned role."
        }
        continue
    }

    $Key = "$($Employee.Department)|$($Employee.JobTitle)|$($Assignment.Role)"

    if (-not $ApprovedRoleLookup.ContainsKey($Key)) {
        [PSCustomObject]@{
            EmployeeID = $Employee.EmployeeID
            Name = $Employee.Name
            Role = $Assignment.Role
            FindingType = "UnauthorizedRole"
            Severity = "Medium"
            Details = "Role is not listed as approved for this department and job title."
        }
    }
}

$Findings = @($Findings)

$Findings | Export-Csv -Path $FindingsPath -NoTypeInformation -Encoding UTF8

Write-Host "`nIAM Access Audit Complete" -ForegroundColor Cyan
Write-Host "Assignments reviewed: $($Assignments.Count)"
Write-Host "Findings detected: $($Findings.Count)"
Write-Host "Report saved to: $FindingsPath"

if ($Findings.Count -gt 0) {
    $Findings | Format-Table EmployeeID, Name, Role, FindingType, Severity -AutoSize
}
