# Validation — 2026-11-12

## Azure DevOps CI

- Build `20261113.1` (build ID `34`) completed successfully from `main` at commit `8cc4f99b`.
- The pipeline completed in approximately 32 seconds.
- All 13 API and behavior tests passed; Azure DevOps reported a 100% pass rate and no failed or unreported tests.
- JUnit test results were published successfully.
- The Docker image validation step completed successfully.
- The run did not publish an image or deploy Azure resources.

## Test coverage

- Python 3.12: 13 API/behavior tests passed using FastAPI TestClient.
- Covered health isolation, five scenario responses, evidence reference validity, runbook retrieval, invalid inputs, unknown runbook rejection, homepage response, unique IDs and request isolation.
- Two dependency deprecation warnings were emitted (pytest/anyio and Starlette/httpx); no test failures.
- Initial test invocation from the parent directory failed to import the app. Running from the project root, as documented, passed.
- Browser interaction and responsive visual testing remain outstanding.
- Code coverage collection is not configured; the 100% figure shown in Azure DevOps is the test pass rate, not line or branch coverage.
- The source is published to GitHub and CI is active. No Azure application deployment has occurred.
