detect-changes Job:

    This job checks if specific directories (terraform/ and helloworld/) have changes using git diff between the previous commit (github.event.before) and the current commit (github.sha).
    Outputs (terraform_changed and helm_changed) are set based on the result of these checks.

terraform Job:

    Depends on the detect-changes job.
    Includes a conditional if statement: if: ${{ needs.detect-changes.outputs.terraform_changed == 'true' }}.
    Only runs if changes are detected in the terraform/ directory.

helm Job:

    Depends on both the detect-changes and terraform jobs (to ensure terraform completes if it was triggered).
    Includes a conditional if statement: if: ${{ needs.detect-changes.outputs.helm_changed == 'true' }}.
    Runs only when changes are detected in the helloworld/ directory.

Workflow Overview

The workflow automates the following:

    Detects changes in three key areas: terraform, helloworld (Helm charts), and hello-world-app (application code).
    Runs jobs based on detected changes:
        docker-build: Builds and pushes a Docker image to Amazon ECR if hello-world-app changes.
        terraform: Applies Terraform changes if terraform files change.
        helm: Deploys or updates the Helm release if Helm charts change or if the Terraform job succeeded.