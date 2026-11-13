# Azure dev deployment and teardown

## Purpose

JIRA-0004 adds an initial Azure deployment slice for the current single-service application. It creates a low-idle-cost dev environment, publishes an immutable image, deploys it to Azure Container Apps, verifies `/health`, and keeps the prior healthy revision available for rollback.

The two-service investigation/sample split in ADR 0002 remains a separate implementation gate. This pipeline does not claim that the complete ADR topology is already implemented.

## Azure DevOps prerequisites

Create a pipeline from `/azure-pipelines-deploy.yml` and a separate pipeline from `/azure-pipelines-destroy.yml`.

Use these protected pipeline variables in both pipelines as applicable:

| Variable | Secret | Purpose |
|---|---:|---|
| `EXPECTED_SUBSCRIPTION_ID` | Yes | Prevent deployment or deletion through the wrong service-connection scope |
| `BUDGET_CONTACT_EMAIL` | Yes | Budget alert recipient; required only by the deployment pipeline |

Do not commit either value to YAML. The Azure Resource Manager service connection is `sc-stackloom-azure-dev` and uses automatic workload identity federation.

Create Azure DevOps environments named:

- `stackloom-dev`
- `stackloom-dev-destroy`

Protect `stackloom-dev-destroy` with a manual approval/check. For the first deployment, also protect `stackloom-dev` or run the newly created pipeline manually and review the `what-if` output before approving mutation. After the first validated deployment, the deploy pipeline is configured to run on relevant changes merged to `main`.

The first run may display a resource authorization prompt. Permit only the named service connection and environments used by this pipeline.

## Required Azure permissions

The federated service connection must be able to:

- create the resource group and subscription-scoped budget;
- deploy Container Registry, Log Analytics, Application Insights, managed identity, Container Apps environment, and Container App resources;
- build and push an image in ACR;
- create the runtime identity's `AcrPull` assignment;
- delete the subscription budget and dev resource group when teardown is approved.

Creating role assignments requires `Microsoft.Authorization/roleAssignments/write`. Azure `Contributor` does not include that permission. Bootstrap with the narrowest practical combination of resource deployment permission and Role Based Access Control Administrator or User Access Administrator, then reduce scope after the assignment model is established.

## Deployment flow

1. Compile both Bicep entry points.
2. Verify the service connection selected the protected expected subscription.
3. Validate the subscription deployment and run `what-if`.
4. Create/update the resource group, CA$20 monthly budget, ACR Basic, observability resources, managed identity, and Container Apps environment.
5. Build the Docker image in ACR with the full Git commit SHA.
6. Capture the currently healthy Container Apps revision.
7. Deploy the new immutable revision.
8. Retry `https://<app-fqdn>/health` and publish the response as pipeline evidence.
9. If the smoke test fails and a previous healthy revision exists, reactivate it and route 100% of traffic back to it.

Budget notifications are alerts, not hard spending caps.

## Cost controls

- Container Apps min replicas: 0
- Container Apps max replicas: 1
- Azure Container Registry: Basic
- Log Analytics retention: 30 days
- One shared resource group for billable workload resources
- Monthly budget notifications at 80% actual and 100% forecast

Scale-to-zero avoids active replica compute charges while idle, but ACR storage, log ingestion/retention, and other resource usage can still incur charges until resources are removed.

## Teardown

Run the destroy pipeline manually and enter exactly:

`DELETE-STACKLOOM-DEV`

The pipeline verifies the expected subscription, deletes the subscription-scoped budget, deletes `rg-stackloom-dev-cac`, waits for Azure to finish, and confirms the resource group no longer exists.

Deleting the resource group stops future usage charges for resources in that group after deletion completes. It does not cancel or refund charges already incurred. Some Azure services retain soft-deleted metadata for a recovery period; verify Cost Management after teardown and check for resources created outside the intended resource group.

## Post-deployment checks

- Open the Container App FQDN and confirm the browser UI loads.
- Confirm `/health` reports `healthy`.
- Confirm the deployed revision image tag equals the Git commit SHA.
- Confirm the sample failure endpoints remain synthetic and do not affect the health probe.
- Confirm the budget exists and has the intended notification recipient.
- Confirm Log Analytics retention is 30 days.
- Record the successful Azure DevOps run and deployed revision in project validation evidence.
