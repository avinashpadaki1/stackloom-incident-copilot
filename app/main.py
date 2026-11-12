"""Local incident lab. Fixtures are synthetic; no external systems are contacted."""
from pathlib import Path
from uuid import uuid4
from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse, JSONResponse
from pydantic import BaseModel
from typing import Literal

ROOT = Path(__file__).resolve().parent
app = FastAPI(title="StackLoom Incident Copilot", version="0.1.0")
Scenario = Literal["healthy", "bad-config", "dependency-down", "release-regression", "unknown"]

CASES = {
    "healthy": (200, "OK", "Request completed", "v1.0.0"),
    "bad-config": (503, "CONFIG_MISSING", "Required setting ORDERS_TABLE is missing", "v1.1.0"),
    "dependency-down": (503, "DEPENDENCY_TIMEOUT", "Inventory dependency exceeded the 2000ms timeout", "v1.0.0"),
    "release-regression": (500, "RELEASE_EXCEPTION", "Unhandled order mapping exception in v1.1.0", "v1.1.0"),
    "unknown": (500, "UNCLASSIFIED", "Request failed; diagnostic detail unavailable", "v1.1.0"),
}
RULES = {
    "CONFIG_MISSING": ("Configuration failure", "Validate ORDERS_TABLE against the known-good configuration before restoring it.", "configuration.md"),
    "DEPENDENCY_TIMEOUT": ("Dependency timeout observed; underlying cause unconfirmed", "Check dependency health and connectivity before considering a retry.", "dependency.md"),
    "RELEASE_EXCEPTION": ("Release regression suspected", "Compare v1.1.0 with the last working release; validate rollback compatibility before any rollback.", "release.md"),
}

class Investigation(BaseModel):
    scenario: Scenario

@app.get("/")
def home():
    return FileResponse(ROOT / "static" / "index.html")

@app.get("/health")
def health():
    return {"status": "healthy", "service": "stackloom-incident-copilot", "mode": "synthetic-rule-based"}

@app.get("/api/scenarios")
def scenarios():
    return {"scenarios": list(CASES), "data_source": "synthetic"}

@app.get("/api/sample/orders")
def orders(scenario: Scenario = "healthy"):
    status, code, message, release = CASES[scenario]
    return JSONResponse(status_code=status, content={"code": code, "message": message, "release": release, "synthetic": True})

@app.get("/api/runbooks/{name}")
def runbook(name: str):
    if name not in {rule[2] for rule in RULES.values()}:
        raise HTTPException(status_code=404, detail="Runbook not found")
    return {"name": name, "content": (ROOT.parent / "runbooks" / name).read_text()}

@app.post("/api/investigate")
def investigate(request: Investigation):
    status, code, message, release = CASES[request.scenario]
    evidence = [
        {"id": "E1", "source": "synthetic sample response", "detail": f"HTTP {status}: {code}: {message}"},
        {"id": "E2", "source": "synthetic release fixture", "detail": f"Deployed release: {release}"},
    ]
    rule = RULES.get(code)
    if status == 200:
        finding, next_step, book = "No failure observed", "No recovery action required.", None
    elif rule:
        finding, next_step, book = rule
    else:
        finding, next_step, book = "Insufficient evidence", "Collect detailed logs and dependency health before drawing a conclusion.", None
    return {"investigation_id": str(uuid4()), "mode": "rule-based baseline (not AI)", "scenario": request.scenario,
            "finding": finding, "evidence_refs": ["E1", "E2"], "evidence": evidence,
            "next_step": next_step, "runbook": f"/api/runbooks/{book}" if book else None,
            "recovery_executed": False, "data_source": "synthetic"}
