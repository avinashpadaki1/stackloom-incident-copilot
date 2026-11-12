# Validation — 2026-11-12

- Python 3.12: 13 API/behavior tests passed using FastAPI TestClient.
- Covered health isolation, five scenario responses, evidence reference validity, runbook retrieval, invalid inputs, unknown runbook rejection, homepage response, unique IDs and request isolation.
- Two dependency deprecation warnings were emitted (pytest/anyio and Starlette/httpx); no test failures.
- Initial test invocation from the parent directory failed to import the app. Running from the project root, as documented, passed.
- Browser interaction and responsive visual testing have not been performed.
- Docker is unavailable in the build workspace; container build remains to be verified by the supplied CI pipeline.
- Azure DevOps pipeline has not been registered or run. No GitHub push or Azure deployment has occurred.
