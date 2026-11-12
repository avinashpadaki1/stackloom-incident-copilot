# ADR 0001: Establish a reproducible investigation baseline
Status: Accepted for milestone 1

## Context
We need repeatable incidents and an honest baseline before evaluating an AI investigator.

## Decision
Use FastAPI and immutable synthetic fixtures. Select scenarios per request rather than changing shared application state. Keep the lab health endpoint independent of simulated failures. Match known error codes to curated runbooks. Explicitly label the output as rule-based, not AI. Unclassified failures must return insufficient evidence.

## Consequences
The demo is cheap, deterministic and easy to test. It does not yet demonstrate real telemetry retrieval or causal reasoning. No authentication, persistence, model, MCP server, Azure deployment or remediation is implemented. Keep this version local. Remote operation requires authentication, rate limiting and a review of exposed endpoints.

## Next decision
Separate the sample workload from the investigation service on Azure, use managed identities and federated pipeline authentication, then implement read-only MCP tools and model evaluation.
