# JIRA-0004 pipeline controls

This implementation extends the repository pipeline standard with a dedicated deployment entry pipeline, reusable stage/job/step templates, immutable image publication, Bicep validation and `what-if`, Azure DevOps Environments, smoke-test evidence, rollback, and guarded teardown.

## Control mapping

| Control | Implementation |
|---|---|
| Build once | ACR build produces one image tagged with the full Git SHA |
| No committed credentials | Workload identity federation and protected variables |
| Review infrastructure changes | Bicep compilation, validation, and `what-if` precede deployment |
| Environment history | Deployment jobs target `stackloom-dev` |
| Bounded blast radius | Workload resources share `rg-stackloom-dev-cac` |
| Verify release | Retried HTTPS `/health` smoke test with published response |
| Roll back safely | Previous healthy revision is retained and traffic restoration is attempted on failure |
| Control destructive actions | Separate manual pipeline, exact confirmation phrase, expected-subscription check, protected environment |
| Cost visibility | Monthly resource-group-filtered budget and short log retention |

Reference implementations remain:

- <https://github.com/JFolberth/TheYAMLPipelineOne>
- <https://github.com/microsoft/code-with-engineering-playbook>
