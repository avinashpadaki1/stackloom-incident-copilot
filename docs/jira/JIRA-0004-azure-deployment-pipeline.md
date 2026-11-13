# JIRA-0004: Provision and deploy the StackLoom dev environment

## Story

As a StackLoom engineer, I want a secure and repeatable Azure deployment pipeline so that the tested incident-copilot image can be deployed, verified, rolled back, and removed without maintaining long-lived credentials or uncontrolled cloud resources.

## Business value

This story turns the Milestone 1 application into a reproducible Azure-hosted portfolio workload while keeping cost, identity, evidence, and teardown behavior explicit.

## Scope

- Provision the dev resource group and platform resources with modular Bicep.
- Deploy through Azure DevOps service connection `sc-stackloom-azure-dev`.
- Use workload identity federation; do not commit Azure credentials or account identifiers.
- Create Azure Container Registry Basic, Log Analytics, Application Insights, a Container Apps environment, and a user-assigned managed identity.
- Grant the runtime identity `AcrPull` at registry scope.
- Build the image in ACR and tag it with the full Git commit SHA.
- Deploy one externally accessible Container App with min replicas 0 and max replicas 1.
- Validate Bicep and run `what-if` before mutation.
- Verify `/health` after deployment and restore traffic to the previous revision if verification fails.
- Create a monthly CA$20 subscription budget filtered to the dev resource group. Supply the recipient through protected pipeline variable `BUDGET_CONTACT_EMAIL`.
- Provide a separately triggered teardown pipeline with an explicit confirmation guard.
- Publish operational instructions and identify the permissions needed by the service connection.

## Deployment defaults

| Input | Value |
|---|---|
| Azure DevOps service connection | sc-stackloom-azure-dev |
| Authentication | Workload identity federation |
| Region | Canada Central |
| Environment | dev |
| Resource group | rg-stackloom-dev-cac |
| Project prefix | stackloom |
| Monthly budget | CA$20 |
| Budget notification | Protected pipeline variable |
| Log retention | 30 days |
| Container Apps scaling | min 0, max 1 |

## Acceptance criteria

1. Pull requests validate the existing application and deployment YAML remains reviewable through stage/job/step separation.
2. The deployment pipeline uses `sc-stackloom-azure-dev` and verifies that the federated connection selected the intended subscription.
3. Bicep compiles and the pipeline runs subscription validation and `what-if` before deployment.
4. No password, service-principal secret, registry admin credential, personal email, subscription identifier, or connection string is committed.
5. The built image is identified by `Build.SourceVersion`; `latest` is never deployed.
6. The public app returns HTTP 200 from `/health` after deployment.
7. A failed smoke test attempts to restore traffic to the previously active healthy revision.
8. The resource group is the ownership and teardown boundary for billable workload resources.
9. Teardown cannot run without the exact confirmation phrase `DELETE-STACKLOOM-DEV`.
10. Deployment and teardown instructions state that deletion stops future resource usage charges after Azure completes deletion, but does not erase charges already incurred.
11. Budget alerts are treated as notifications, not spending caps.
12. The pipeline structure follows the repository pipeline standard and the referenced Microsoft ISE engineering guidance.

## Security and permission notes

The Azure DevOps service connection needs permission to deploy resources at the subscription/resource-group scope used by the templates. Because the template creates an `AcrPull` role assignment for the runtime identity, the connection also needs `Microsoft.Authorization/roleAssignments/write` at the target scope (for example, User Access Administrator or Role Based Access Control Administrator combined with resource deployment permissions). Use the narrowest scope supported by the initial bootstrap process.

## Out of scope

- Azure OpenAI, model credentials, MCP tools, and automated remediation.
- Production or multi-region deployment.
- Custom domain, private endpoints, WAF, and end-user authentication.
- Splitting the current synthetic sample API into a second independently deployable service.
- A production SLO or disaster-recovery design.

## Definition of done

- Bicep, deployment YAML, teardown YAML, and operations documentation are committed on a JIRA-linked branch.
- The pull request explains prerequisites, security, cost behavior, validation, rollback, and teardown.
- CI succeeds.
- A human performs and records the first approved dev deployment before relying on automatic deployments from `main`.
