# JIRA-0002 — Define the Azure deployment architecture

## Story

As a platform engineer, I want an Architecture Decision Record for the StackLoom Azure deployment so that infrastructure, identity, delivery, telemetry, cost, and operational decisions are understood before implementation begins.

## Background

Milestone 1 established and validated a deterministic local incident lab. Milestone 2 will deploy the workload to Azure and introduce real telemetry. The deployment design must remain inexpensive, reproducible, observable, and secure while keeping Azure OpenAI, MCP integration, and automated remediation outside this implementation step.

## Scope

- Select the Azure compute, registry, telemetry, identity, and infrastructure-as-code approach.
- Define the CI/CD path from GitHub through Azure DevOps to Azure.
- Define ingress, health validation, image tagging, rollback, cost controls, and teardown expectations.
- Include Mermaid diagrams for the target architecture and deployment sequence.
- Record alternatives and their trade-offs.

## Out of scope

- Provisioning Azure resources.
- Creating or modifying Azure DevOps service connections.
- Azure OpenAI or other model integration.
- MCP server implementation.
- Authentication for public users.
- Automated or self-healing remediation.
- Production availability or disaster-recovery commitments.

## Acceptance criteria

1. A new ADR is stored under `docs/adr` and references this Jira story.
2. The ADR identifies the decision status, context, drivers, selected architecture, alternatives, consequences, risks, and implementation gates.
3. The target architecture is shown using a valid Mermaid flowchart.
4. The deployment and verification process is shown using a valid Mermaid sequence diagram.
5. The design uses Bicep, Azure Container Registry, Azure Container Apps, Application Insights, Log Analytics, managed identity, and workload identity federation.
6. Container images use immutable commit-based tags rather than relying on `latest`.
7. The design defines health checks, smoke tests, rollback, least-privilege access, cost controls, and teardown.
8. The ADR clearly separates the initial Azure deployment from later AI, MCP, and remediation milestones.

## Definition of done

- Story and ADR are committed on `ADR/JIRA-0002-azure-deployment-architecture`.
- The commit message starts with `JIRA-0002`.
- `main` is not modified directly.
- The documentation is ready for pull-request review before infrastructure implementation starts.
