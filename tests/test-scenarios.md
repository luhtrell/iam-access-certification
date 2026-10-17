# IAM Access Certification - Test Scenarios

## Purpose
Verify that the access audit identifies expected findings and that
review decisions are validated correctly.

All test identities and access records are fictional.

## Test Cases

| ID | Scenario | Expected Result |
|----|----------|-----------------|
| T01 | Approved role assigned to active employee | No finding |
| T02 | Role not approved for employee job title | UnauthorizedRole finding |
| T03 | Access assigned to terminated employee | TerminatedEmployeeAccess finding |
| T04 | Assignment references unknown employee ID | UnknownEmployee finding |
| T05 | Finding has no review decision | MissingDecision |
| T06 | Review decision is neither Approve nor Revoke | InvalidDecision |
| T07 | Review decision has no reviewer or justification | IncompleteReview |
| T08 | Duplicate review decisions exist for one finding | DuplicateDecisions |

## Current Baseline
The initial sample dataset contains 10 assignments and is expected
to produce two findings:
- E1001 / Finance_Approver: UnauthorizedRole
- E1005 / CRM_Read: TerminatedEmployeeAccess

## Test Method
Run the relevant PowerShell script with controlled sample data,
compare the actual result to the expected result, and record whether
the test passed.

## Limitations
These tests use local CSV data and do not connect to a production
identity provider or change real account permissions.
