# StackLoom Incident Copilot

Milestone 1 — working local incident lab for an Azure AI engineering portfolio.

**Implemented:** FastAPI API, browser UI, five synthetic scenarios, evidence-linked rule-based investigations, three runbooks, tests, Dockerfile and Azure DevOps CI YAML.

**Not yet implemented:** AI model calls, MCP server, real deployment/log retrieval, Azure infrastructure, authentication and automated remediation. No Azure costs are incurred by running the local demo.

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

## Publish the source to your private GitHub repository
Create `avinashpadaki1/stackloom-incident-copilot` as a **private** repository. Grant the ChatGPT GitHub connection access if you want assistance pushing/reviewing changes. If pushing yourself to a new, empty repository:

```bash
git init -b main
git add .
git commit -m "Add StackLoom incident lab foundation"
git remote add origin https://github.com/avinashpadaki1/stackloom-incident-copilot.git
git push -u origin main
```

Use your normal GitHub authentication. Do not place tokens in files or commands. If you initialized the remote with a README, clone it and copy these files into the clone instead; do not force push.

## Azure DevOps setup
Create the `StackLoom-Labs` project. In Pipelines, select New pipeline -> GitHub -> this repository -> Existing Azure Pipelines YAML file -> `/azure-pipelines.yml`. Authorize access to this repository. Ensure a Microsoft-hosted parallel job is available. The pipeline installs dependencies, runs tests, publishes JUnit results and builds the container. It does not push images or deploy resources.

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
