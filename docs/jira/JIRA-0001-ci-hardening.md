# JIRA-0001 — Publish verified CI evidence and stabilize the build agent

## Story

As a portfolio reviewer or engineer, I want the repository to show verified CI results and use a predictable build image so that I can assess the project quickly and reproduce its validation with confidence.

## Background

Azure DevOps build `20261113.1` completed successfully from `main` at commit `8cc4f99b`. The run completed 13 tests with a 100% pass rate and validated the Docker image build. Azure DevOps also warned that the `ubuntu-latest` label will migrate to Ubuntu 26, so the pipeline should pin a known image.

## Acceptance criteria

1. The README displays the Azure DevOps build status for `main`.
2. The README documents the verified Milestone 1 CI outcome.
3. `docs/validation.md` records build `20261113.1`, 13 of 13 passing tests, and successful Docker validation.
4. The Azure Pipelines agent image is pinned to `ubuntu-24.04`.
5. The pipeline continues to install Python 3.12 dependencies, publish JUnit results, and build the Docker image.
6. No Azure deployment, AI model integration, authentication, or automated remediation is represented as complete.

## Technical notes

- Repository: `avinashpadaki1/stackloom-incident-copilot`
- Pipeline: `stackloom-incident-copilot`
- Source branch: `main`
- Evidence date: November 12, 2026 (America/Toronto)
- Azure DevOps build ID: `34`

## Definition of done

- Changes are committed on `feature/JIRA-0001-ci-hardening` with the Jira ID in the commit message.
- The feature branch is available for review without modifying `main` directly.
- A branch pipeline run confirms the pinned agent image and existing validation steps.
