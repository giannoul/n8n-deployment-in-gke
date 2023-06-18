
# n8n-deployment-in-gke

This repository uses [Kubestack](https://www.kubestack.com/) in order to:
- set up a GKE cluster
- set up n8n  

## How to
In the file `providers.tf` replace `xxxxx` with the id of your Goocle Cloud Project. Then start the toolbox container:
```
docker run --rm -ti -v $(pwd)/src:/infra --network=host kubestack/framework:v0.17.1-beta.0-gke
```

and inside run the following commands:
```
kbst@8bfeb7772d8a:/infra$ gcloud auth login
kbst@8bfeb7772d8a:/infra$ gcloud projects list
kbst@8bfeb7772d8a:/infra$ gcloud config set project xxxxx
kbst@8bfeb7772d8a:/infra$ gcloud services enable container.googleapis.com cloudresourcemanager.googleapis.com
kbst@8bfeb7772d8a:/infra$ PROJECT=$(gcloud config get-value project)
kbst@8bfeb7772d8a:/infra$ gcloud iam service-accounts create kubestack-automation   --description "SA used for Kubestack Github Actions"   --display-name "kubestack-automation"
kbst@8bfeb7772d8a:/infra$ gcloud projects add-iam-policy-binding ${PROJECT}   --member serviceAccount:kubestack-automation@${PROJECT}.iam.gserviceaccount.com   --role roles/owner
kbst@8bfeb7772d8a:/infra$ gcloud iam service-accounts keys create   ~/.config/gcloud/application_default_credentials.json   --iam-account kubestack-automation@${PROJECT}.iam.gserviceaccount.com
kbst@8bfeb7772d8a:/infra$ gcloud auth activate-service-account --key-file ~/.config/gcloud/application_default_credentials.json
kbst@8bfeb7772d8a:/infra$ terraform workspace new apps ; terraform workspace select apps
kbst@8bfeb7772d8a:/infra$ terraform workspace show
kbst@8bfeb7772d8a:/infra$ git clone https://github.com/n8n-io/n8n-kubernetes-hosting ./manifests
kbst@8bfeb7772d8a:/infra$ cat << EOF > ./manifests/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
metadata:
  name: n8n
resources:
- n8n-claim0-persistentvolumeclaim.yaml
- n8n-deployment.yaml
- n8n-secret.yaml
- n8n-service.yaml
- namespace.yaml
- postgres-claim0-persistentvolumeclaim.yaml
- postgres-configmap.yaml
- postgres-deployment.yaml
- postgres-secret.yaml
- postgres-service.yaml
EOF
kbst@8bfeb7772d8a:/infra$ terraform plan
kbst@8bfeb7772d8a:/infra$ terraform apply
```

After provisioning finishes you may check the application using:
```
kbst@serpent:/infra$ kubectl port-forward pod/`kubectl get pods -n n8n -l service=n8n | tail -n 1 | awk '{print $1}'` -n n8n 5678:5678
```
and navigate to http://localhost:5678.

## Useful links
* https://www.kubestack.com/framework/tutorial/provision-infrastructure/
* https://www.kubestack.com/framework/tutorial/provision-infrastructure/#setup-authentication