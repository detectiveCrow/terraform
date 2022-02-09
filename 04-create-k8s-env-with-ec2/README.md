## Terraform

### init infra

```
# in 'terraform/'

terraform apply -auto-approve
```

### connect using public key

```
ssh -i "~/.ssh/aws/aws_key" ubuntu@[ip address of instance]
```

### destroy infra

```
terraform destroy -auto-approve
```

## Ansible

### init kubernetes cluster

```
# in 'ansible/'

export ANSIBLE_HOST_KEY_CHECKING=false

# install dependencies
ansible-playbook -i ../terraform/kube_hosts kube_dependencies.yaml

# initialize kubernetes cluster
ansible-playbook -i ../terraform/kube_hosts kube_master.yaml

# join worker node to cluster
ansible-playbook -i ../terraform/kube_hosts kube_workers.yaml
```

## Refer to

- https://www.techcrumble.net/2020/01/building-a-kubernetes-cluster-on-aws-with-terraform-ansible-and-gitlab-ci-cd/
- https://gitlab.com/arunalakmal/TCAWSKubeDeploy/-/tree/master
- https://digitalvarys.com/install-kubernetes-cluster-with-kubeadm-and-ansible-ubuntu/
- https://medium.com/@pierangelo1982/install-docker-with-ansible-d078ad7b0a54
- https://digitalvarys.com/install-kubernetes-cluster-with-kubeadm-and-ansible-ubuntu/#Step_3_Installing_Kubernetes_Binaries
- https://harshitdawar.medium.com/launching-a-multi-node-kubernetes-cluster-using-ansible-4a63a542e8af