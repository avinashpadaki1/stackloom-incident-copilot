# Pipeline engineering standard

## Purpose

StackLoom pipelines use the Microsoft ISE Engineering Fundamentals as the governing standard and `JFolberth/TheYAMLPipelineOne` as an Azure DevOps YAML composition reference. Reference implementations are adapted to this repository's size and risks; they are not copied without review.

## Template structure

```text
azure-pipelines.yml
pipelines/
  stages/
    ci_stage.yml
  jobs/
    python_validation_job.yml
    container_validation_job.yml
  steps/
    setup_python_steps.yml
    run_python_validation_steps.yml
    build_container_steps.yml
```

The entry pipeline owns triggers and repository-level defaults. Stage templates describe orchestration, job templates define isolated execution boundaries, and step templates contain tasks. Environment deployment templates will be added separately when Milestone 2 infrastructure is implemented.

## ISE alignment assessment

| Control | Status | Evidence or next action |
|---|---|---|
| CI runs for pull requests and `main` | Implemented | PR and CI triggers target `main` |
| Main remains shippable | Implemented for Milestone 1 | Tests and Docker validation must pass before merge |
| Automated tests | Implemented | 13 API and behavior tests with JUnit evidence |
| Repeatable dependency installation | Implemented | Direct dependencies are version-pinned |
| Reusable pipeline templates | Implemented | Entry, stage, job and step separation |
| Clean and bounded jobs | Implemented | Clean shallow checkout and 10-minute timeouts |
| Immutable image identity | Implemented for validation | Image is tagged with `Build.SourceVersion` |
| Container publication and promotion | Deferred | Requires ACR and the Milestone 2 deployment pipeline |
| Replica-environment deployment before release | Deferred | Requires approved Azure dev environment |
| Smoke test and rollback | Deferred | Defined by ADR 0002; implement with deployment pipeline |
| Code coverage measurement | Gap | Add collection and an evidence-based threshold in a separate story |
| Credential and dependency scanning | Gap | Select and configure approved tools in a separate story |
| Branch protection and required reviewers | Repository setting | Configure required PR checks and reviewers in GitHub |
| Observability and trace propagation | Deferred | Milestone 2 application and deployment work |

## Required practices

- Build and validate every pull request.
- Keep secrets and environment-specific credentials out of YAML.
- Use workload identity federation for Azure authentication.
- Build an artifact or image once and promote the same immutable version.
- Publish test, infrastructure, deployment, and smoke-test evidence.
- Use Bicep validation and `what-if` before Azure deployment.
- Deploy through Azure DevOps Environments with approvals appropriate to risk.
- Keep the previous healthy revision available until validation succeeds.
- Document rollback and teardown behavior before deployment.
- Add new controls through Jira-linked branches and pull requests.

## References

- <https://github.com/JFolberth/TheYAMLPipelineOne>
- <https://github.com/microsoft/code-with-engineering-playbook>
- <https://github.com/microsoft/code-with-engineering-playbook/blob/main/docs/engineering-fundamentals-checklist.md>
- <https://github.com/microsoft/code-with-engineering-playbook/tree/main/docs/CI-CD>
