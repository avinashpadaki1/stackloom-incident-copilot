# JIRA-0003 — Refactor CI pipeline to ISE-aligned templates

## Story

As a platform engineer, I want the StackLoom CI pipeline organized into reusable Azure DevOps YAML templates so that pipeline behavior is maintainable, reviewable, consistent, and ready to support future deployment stages.

## Background

The current pipeline successfully runs 13 tests and validates the Docker build, but all tasks are embedded in one entry YAML file. The agreed references recommend a thin entry pipeline, stage/job/step template composition, PR validation, repeatable builds, explicit evidence publishing, and clear documentation of remaining engineering controls.

## References

- `JFolberth/TheYAMLPipelineOne` for Azure DevOps template composition and naming patterns.
- `microsoft/code-with-engineering-playbook` for ISE Engineering Fundamentals covering CI/CD, testing, security, source control, observability, and review practices.

## Scope

- Preserve the existing Python 3.12 tests, JUnit publishing, and Docker build validation.
- Replace embedded pipeline tasks with stage, job, and step templates.
- Parameterize the agent image, Python version, requirements path, test results, Dockerfile, image repository, and immutable image tag.
- Add clean, shallow repository checkout and bounded job execution.
- Compile Python sources before tests to catch syntax failures early.
- Keep PR and `main` validation enabled.
- Document the ISE alignment assessment and known gaps.

## Out of scope

- Azure deployment or service connections.
- Publishing container images.
- Bicep validation and deployment.
- Adding third-party security tools.
- Claiming code coverage without collecting coverage data.
- Changing GitHub branch-protection settings.

## Acceptance criteria

1. `azure-pipelines.yml` is a thin entry pipeline with no embedded build or test tasks.
2. Pipeline logic is decomposed into stage, job, and step templates under `pipelines/`.
3. The pipeline continues to run for pull requests targeting `main` and commits to `main`.
4. Tests and container validation run as separate jobs.
5. Test results publish even when tests fail, and missing result files fail the build.
6. The container validation tag uses the Git commit SHA instead of `latest`.
7. Jobs use clean, shallow checkouts and explicit timeouts.
8. A pipeline standards document maps implemented controls and identifies controls that remain outside this change.
9. The feature branch pipeline passes all existing tests and Docker validation.

## Definition of done

- Changes are committed on `feature/JIRA-0003-ise-pipeline-refactor`.
- The commit message starts with `JIRA-0003`.
- `main` remains unchanged until pull-request approval.
- The PR description references this story and the two engineering sources.
