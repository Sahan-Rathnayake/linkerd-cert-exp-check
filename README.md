# Linkerd-cert-exp-check
Linkerd Control Plane TLS Credential Expiration Check and Alerting for AWS EKS using AWS SNS

## INTRODUCTION
Linkerd implements mutual Transport Layer Security (mTLS) and for that it requires TLS Certificates, which are automatically generated by Control Plane TLS Credentials. Linkerd does not manage automatic rotation of Control Plane TLS Credentials. But it can be achieved using [Cert Manager or other 3rd Party Software like Vault](https://linkerd.io/2.9/tasks/automatically-rotating-control-plane-tls-credentials/).

 But in case if it does not work properly Control Plane TLS Credentials will expire and the resolution will be to remove Linkerd and perform a clean installation. The purpose of this project is to be notified prior to expiration, making the user aware of upcoming expiration and allowing a [manual rotation](https://linkerd.io/2.9/tasks/manually-rotating-control-plane-tls-credentials/) in case if automatic rotation is not working / not implemented.

 ## PRE-REQUISITES
 * Access to an EKS Cluster with Linkerd
 * Privileges to create IAM OIDC Provider, IAM Role, IAM Policy, and SNS Topic and Subscription
 * kubectl

 ## STEPS
 1. Create a SNS [Topic](https://docs.aws.amazon.com/sns/latest/dg/sns-create-topic.html) with [Subscription](https://docs.aws.amazon.com/sns/latest/dg/sns-create-subscribe-endpoint-to-topic.html).
 2. Create an IAM [Policy](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_create.html) and replace policy.json content with [this content](./AWS/Policy.json). Replace `Resource` value with the Topic ARN created in step 1.
 3. Add EKS [cluster as an OIDC provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html).
 4. Create an IAM [Role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-custom.html) and replace **Custom trust policy** content with [this content](./AWS/TrustPolicy.json). Replace `Federated` value with the OIDC provider ARN and replace keys in `StringEquals` condition with the OIDC provider created in step 3.
 5. Clone the repository.
 6. Replace `eks.amazonaws.com/role-arn` in [here](./K8s/ServiceAccount.yaml) value with the Role ARN created in step 4.
 7. Replace `schedule` value in [here](./K8s/CronJob.yaml) to specify when Kubernetes should run the CronJob.
 8. Replace `-t` flag value of `command` in [here](./K8s/CronJob.yaml) with the Topic ARN created in step 1.
 9. Replace `-e` and `-p` flag value palceholders of `command` in [here](./K8s/CronJob.yaml).
 10. Check cluster config using `kubectl config current-context` and if needed, switch config using `kubectl config use-context <context-name>`.
 11. Navigate to the ***linkerd-cert-exp-check/K8s*** directory.
 12. Execute `kubectl apply -f .` to create ServiceAccount, Role, RoleBinding, and CronJob in the desired cluster.

 ## NOTES
 * If Linkerd is not installed in `linkerd`, replace `namespace` value in all [K8s](./K8s/) files and [here](./AWS/TrustPolicy.json). (All resource will be created in that namespace)
 * It is possible to have the CronJob and the ServieAccount in a separate namespace, given that `namespace` value is changed accordingly in [CronJob.yaml](./K8s/CronJob.yaml), [ServiceAccount.yaml](./K8s/ServiceAccount.yaml), [RoleBinding.yaml](./K8s/RoleBinding.yaml), and [here](./AWS/TrustPolicy.json).
 * To make changes to flags in `command` of the CronJob, alter the [script](./scripts/cert-exp-check.sh) and rebuild the image using [Dockerfile](./Dockerfile). Propagate the changes to [CronJob.yaml](./K8s/CronJob.yaml).
