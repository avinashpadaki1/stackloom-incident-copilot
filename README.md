# StackLoom Incident Copilot

[![Azure DevOps Build](https://dev.azure.com/facon1/stackloom-incident-copilot/_apis/build/status/stackloom-incident-copilot?branchName=main)](https://dev.azure.com/facon1/stackloom-incident-copilot/_build/latest?definitionId=34&branchName=main)

Milestone 1 — working local incident lab for an Azure AI engineering portfolio.

**Implemented:** FastAPI API, browser UI, five synthetic scenarios, evidence-linked rule-based investigations, three runbooks, tests, Dockerfile and Azure DevOps CI YAML.

**Not yet implemented:** AI model calls, MCP server, real deployment/log retrieval, Azure infrastructure, authentication and automated remediation. No Azure costs are incurred by running the local demo.

## Verified CI baseline

Azure DevOps build `20261113.1` validated Milestone 1 from `main` at commit `8cc4f99b`: 13 of 13 tests passed, JUnit results were published, and the Docker image build completed successfully. See [`docs/validation.md`](docs/validation.md) for the evidence and current validation limits.

## Quick start — Windows PowerShell
Install Python 3.12, then open a terminal in this folder:

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
.\.venv\Scripts\python.exe -m pytest -q
.\.venv\Scripts\python.exe -m uvicorn app.main:app --reload
```

Open http://127.0.0.1:8000 and click **Investigate scenario**. API documentation: http://127.0.0.1:8000/docs. Stop with Ctrl+C. No activation or PowerShell policy change is needed.

## Linux / WSL / macOS

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements-dev.txt
.venv/bin/python -m pytest -q
.venv/bin/python -m uvicorn app.main:app --reload
```

## Optional Docker

```bash
docker build -t stackloom-incident-copilot:local .
docker run --rm -p 127.0.0.1:8000:8000 stackloom-incident-copilot:local
```

The container runs as a non-root user. This unauthenticated milestone is for local use.

## Azure DevOps setup
The pipeline is connected to this GitHub repository and runs from `/azure-pipelines.yml`. It installs dependencies, runs tests, publishes JUnit results and builds the container. It does not push images or deploy resources.

## Demo script
1. Investigate missing configuration; inspect E1 and E2 and the runbook.
2. Investigate dependency timeout; note that its underlying cause is unconfirmed.
3. Investigate release regression; note that it is a hypothesis.
4. Select insufficient evidence; confirm the investigator abstains.
5. Select healthy; confirm there is no proposed recovery.

## Next milestone
Deploy separate sample and investigation services using Bicep and Azure DevOps, then add real telemetry. Choose Azure region and model only after checking subscription availability and quota. Configure cost alerts and request limits before model integration.

See `docs/architecture.md` and `docs/adr/0001-local-baseline.md`.

## References
- https://fastapi.tiangolo.com/tutorial/testing/
- https://learn.microsoft.com/en-us/azure/devops/pipelines/ecosystems/customize-python
