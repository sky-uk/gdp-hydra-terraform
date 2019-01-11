# Docker Registries

## Independent Registries

To ensure there is isolation between providers and that each provider is individually resilient the Hydra module will provision a docker registry within each provider. 

It will also provision push credentials for each registry and return them as part of the outputs for the module.

The following outputs can be used to access the individual docker registries.

| Name | Description |
|------|-------------|
| acr_url | The URL of the docker registry for Azure clusters |
| acr_username | The username for the docker registry for Azure clusters |
| acr_password | The password for the docker registry for Azure clusters |
| gcr_url | The URL of the docker registry for GCP clusters |
| gcr_credentials | JSON credentials file for the docker registry for GCP clusters |

You can use these outputs as part of your terraform script to configure CI or other functionality. It is possible that some changes in the configuration could cause a re-build of the registries so it would make sense to try and automate the downstream configuration if possible. There is a [terraform provider](https://github.com/mrolla/terraform-provider-circleci) for CircleCI that could be useful for updating environment variables.

## Automatic local registry injection

To enable easy deployment there is a mutating webhook deployed by hydra into each cluster that will inspect any new deployment objects and re-write the container names to match the local registry. To enable this you just need to name your image using the format `cluster.local/path/to/image` and the webhook will replace this with the configured registry.

You can find out more about this here [Mutating Admissions Controller](https://github.com/lawrencegripper/MutatingAdmissionsController)
