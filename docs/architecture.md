# Architecture and roadmap

## Implemented
Browser -> FastAPI -> synthetic incident fixtures and curated runbooks.
The investigator returns evidence references and a deterministic recommendation.
No external calls, credentials or cloud resources are required.

## Planned Azure architecture (not deployed)
Browser -> authenticated investigation API on Container Apps.
Investigation API -> model endpoint and read-only MCP tools.
MCP tools -> deployment history, Azure Monitor and runbook storage.
A separate sample workload generates real failures and telemetry.
GitHub -> Azure DevOps CI -> container registry -> Container Apps through Bicep.

## Acceptance gates
1. Local: scenario tests pass, unknown failures are not overclaimed.
2. Azure: reproducible Bicep deployment, health checks, scoped identity, teardown procedure and cost alerts.
3. AI: tools return traceable evidence; logs are treated as untrusted data; investigation has time/tool/token limits.
4. Evaluation: held-out incidents, evidence validity, diagnosis accuracy, appropriate abstention, latency and cost per run.
5. Release: access control, rate limits, runbook review, demo video and measured results.

Keep the test fixtures independent of future evaluation holdouts. No self-healing claims until approval-controlled recovery is implemented and tested.
