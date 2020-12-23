# Jenkins On AWS

This repo aims to give a fault-tolerant, highly available, automated Jenkins multi-node install on AWS. Persistent storage is handled by EFS, so data is available even if the Jenkins leader goes down. The stack uses FARGATE and can optionally be setup to use SSL with your chosen Subdomain.

## Installation

### Prerequisites

#### Docker

If you do not have access to a pre-built version of the Docker image or you wish to add to/modify the default ECS nodes, then you must rebuild the image from source and upload to a docker registry. This must be done from a \*NIX machine for propper compilation, swapping out `{{docker repository}}` and `{{image name}}` with the respective values.

```bash
docker build -t {{docker repository}}/{{image name}}:latest .
docker push {{docker repository}}/{{image name}}:latest
```

#### SSL

If you wish to setup SSL and a Subdomain for the Jenkins instance, then you will first need to request a certificate and verify DNS via the [AWS Certificate Manager](https://console.aws.amazon.com/acm/home). Enter the required Subdomain (e.g. jenkins<span>.sage.</span>com or \*.sage.com). You will need access to make DNS entries on the domain chosen. Once the domain is verified, copy the `ARN` of the generated certificate for later use.

### Creating the Jenkins stack via the CloudFormation Template

1. Enter a stack name.
2. Enter/Modify the ECS Parameters:
   1. If you built the Docker image from source then reference the container in the `MasterDockerImage` parameter.
   2. Set the ECS `CPU` and `Memory` allocations for the Jenkins leader. This can only be changed by recreating the stack, so should be allocated accordingly.
3. Set the `JenkinsUsername` parameter. This will be the default admin username used for Jenkins.
4. Enter the SSL Parameters (**_Optional_**):
   1. If you do not wish to setup SSL and a Subdomain for Jenkins at this time, then make sure that `EnableSSL` is set to false and you can leave the remaining options blank.
   2. If setting-up a Subdomain/SSL, then change `EnableSSL` to true, paste in the `Certificate ARN` generated earlier, and enter the chosen Subdomain (prefixed by `https://`).
5. Click `Next` (x2)
6. Accept the required AWS Capabilities
7. Click `Create Stack`

### Accessing Jenkins

Once the stack creation has completed, the DNS name of the Jenkins host is displayed within the `Outputs` tab. If you did not enter a Subdomain, then you can access Jenkins via this DNS name.

If you did enter a Subdomain, then you will need to copy this DNS name (the text itself, copying the link address will not work) and create a new `CNAME` entry in your DNS provider, with the DNS name generated entered as the `target` and the subdomain (e.g. `jenkins`) set as the `Name/Route`. You can now access Jenkins via the Subdomain entered previously.

#### Logging in ior the first time

When accessing Jenkins for the first time, you will be required to login using the Jenkins user created earlier. You can access the password for this user via the [AWS Secrets Manager](https://console.aws.amazon.com/secretsmanager/home).

Once logged in, you can configure Jenkins as required (e.g. creating additional users/config). If you wish to ensure that creation has been successful, there is a default Jenkins job, `test-default-agents`. This job will run 3 _different_ worker nodes, with a successful build ensuring that stack creation was successful.
