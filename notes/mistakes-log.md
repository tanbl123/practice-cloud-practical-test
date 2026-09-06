# Mistakes and Weak Areas Log

Anything answered wrongly, half-remembered, or confused goes here so it can be
re-drilled in a later session. Claude: check this file at the start of every
session and re-test these before moving on.

| Date | Module | What went wrong | Correct answer | Re-tested? |
|------|--------|-----------------|----------------|------------|
| 2026-09-04 | 9 | Cognito lab: put the **full** domain into `COGNITO_DOMAIN_STR`, producing a doubled hostname (`...amazoncognito.com.auth.us-east-1.amazoncognito.com`) and `DNS_PROBE_FINISHED_NXDOMAIN` on login | `COGNITO_DOMAIN_STR` takes the **prefix only** (e.g. `us-east-1dozamunkd`); the app appends `.auth.<region>.amazoncognito.com`. Same trap as `CLOUDFRONT_DISTRO_STR` (prefix) vs `BASE_NODE_SERVER_STR` (full URL) | no |
