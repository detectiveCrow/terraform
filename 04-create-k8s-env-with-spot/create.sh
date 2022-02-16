# 디렉토리 변경
cd ./terraform

# 인프라 생성
terraform apply -auto-approve

# 대기
sleep 30

# 디렉토리 변경
cd ../ansible

# 키 확인 무시하도록 설정
export ANSIBLE_HOST_KEY_CHECKING=false

# dependency 설치
ansible-playbook -i ../terraform/kube_hosts kube_dependencies.yaml

# 마스터 노드에 Initialize
ansible-playbook -i ../terraform/kube_hosts kube_master.yaml

# 워커 노드를 클러스터에 Join
ansible-playbook -i ../terraform/kube_hosts kube_workers.yaml