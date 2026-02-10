# Custom Container Deployment

This example deploys a Web App running a custom Docker container via the `site_config.application_stack.docker` configuration.

It demonstrates how to specify a Docker image name, registry URL, and image tag for container-based App Service deployments. This approach is useful when you need full control over the runtime environment or want to deploy a pre-built container image.

The example uses `kind = "webapp"` with a container-based application stack.
