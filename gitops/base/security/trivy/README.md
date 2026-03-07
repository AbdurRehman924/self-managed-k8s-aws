# Trivy Vulnerability Scanning

## Overview
Trivy Operator continuously scans container images for vulnerabilities and generates reports.

## Current Security Posture

### Critical Vulnerabilities Summary (as of Feb 12, 2026)

| Service | Critical | High | Medium | Low | Status |
|---------|----------|------|--------|-----|--------|
| emailservice | 9 | 42 | 79 | 13 | 🔴 Action Required |
| loadgenerator | 9 | 43 | 85 | 13 | 🔴 Action Required |
| recommendationservice | 9 | 42 | 74 | 13 | 🔴 Action Required |
| frontend | 4 | 41 | 57 | 10 | 🟡 Review Needed |
| checkoutservice | 3 | 14 | 51 | 9 | 🟡 Review Needed |
| redis-cart | 0 | 0 | 0 | 0 | ✅ Clean |

### Top Critical CVEs

1. **CVE-2025-15467** (OpenSSL)
   - Impact: Remote code execution via CMS parsing
   - Fix: Upgrade to openssl 3.0.14-1~deb12u2

2. **CVE-2024-37371** (krb5)
   - Impact: GSS message token handling vulnerability
   - Fix: Upgrade to krb5 1.20.1-2+deb12u2

3. **CVE-2024-45491/45492** (libexpat)
   - Impact: Integer overflow/wraparound
   - Fix: Upgrade to libexpat 2.5.0-1+deb12u1

4. **CVE-2025-6965** (SQLite)
   - Impact: Integer truncation
   - Fix: Upgrade to sqlite 3.40.1-2+deb12u1

## Commands

### View All Vulnerability Reports
```bash
kubectl get vulnerabilityreports -n hipster-shop -o wide
```

### Inspect Specific Service
```bash
kubectl get vulnerabilityreport <report-name> -n hipster-shop -o yaml
```

### View Only Critical Vulnerabilities
```bash
kubectl get vulnerabilityreport <report-name> -n hipster-shop -o yaml | grep -A 10 "CRITICAL"
```

### Check Trivy Operator Logs
```bash
kubectl logs -n security deployment/trivy-operator
```

## Remediation Strategy

1. **Immediate**: Update base images to latest patched versions
2. **Short-term**: Implement automated image scanning in CI/CD
3. **Long-term**: Establish vulnerability management process with SLAs

## Best Practices

- ✅ Scan images before deployment
- ✅ Use minimal base images (Alpine when possible)
- ✅ Regularly update dependencies
- ✅ Monitor vulnerability reports continuously
- ✅ Set up alerts for new critical CVEs
