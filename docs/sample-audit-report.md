# IAM Access Certification — Sample Audit Report

## 1. Executive Summary

This simulated identity and access governance review evaluated assigned roles against approved access criteria and checked for access retained by terminated employees.

The sample dataset produced two findings: one unauthorized role assignment and one terminated employee with an assigned role.

## 2. Findings Overview

| Finding | Severity | Identity | Assigned Role |
|---|---|---|---|
| Unauthorized role | Medium | Jordan Lee (E1001) | Finance_Approver |
| Terminated employee access | High | Jamie Patel (E1005) | CRM_Read |

## 3. Finding Details

### Finding 1 — Unauthorized Finance Approver Role

- **Identity:** Jordan Lee (E1001)
- **Role:** Finance_Approver
- **Severity:** Medium
- **Evidence:** The role is not listed as approved for the employee's department and job title.
- **Risk:** Unapproved financial privileges could allow actions beyond the employee's authorized responsibilities.
- **Recommended action:** Verify the employee's business responsibilities and approved-role matrix. Remove the role if authorization cannot be established, and record the decision and evidence.

### Finding 2 — Access Retained by Terminated Employee

- **Identity:** Jamie Patel (E1005)
- **Role:** CRM_Read
- **Severity:** High
- **Evidence:** The employee is marked as terminated but still has an assigned role.
- **Risk:** Retained access may permit access to organizational or customer information after employment ends.
- **Recommended action:** Confirm the termination status, revoke the assigned access through the appropriate identity system, verify removal, and preserve the remediation evidence.

## 4. Validation Results

The project's access review validation reported five passing test cases and zero failures. The test cases covered the sample review decisions, duplicate decisions, incomplete reviews, invalid decisions, and missing decisions.

The audit summary reported:
- Total findings: 2
- High-severity findings: 1
- Medium-severity findings: 1
- Unauthorized roles: 1
- Terminated employee access findings: 1
- Duplicate decisions: 0
- Invalid decisions: 0

## 5. Remediation Tracking

The findings are recommendations for action, not proof that access has already been removed. A production workflow should record the responsible owner, remediation deadline, approval or revocation decision, completion timestamp, and verification evidence.

## 6. Scope and Limitations

This is a simulated portfolio exercise using fictional identities and access records. It does not connect to a production identity provider or revoke real access. Findings and review decisions should be independently verified before any real-world remediation.

## 7. Evidence Files

Generated project evidence is available in the `reports/` directory:
- `access-findings.csv`
- `audit-summary.csv`
- `audit-trail.csv`
- `review-validation.csv`
- `test-results.csv`
