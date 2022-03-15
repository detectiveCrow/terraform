# Install Terraform

## Linux - Fedora

### Install dnf config-manager to manage your repositories.
```
sudo dnf install -y dnf-plugins-core
```

### Use dnf config-manager to add the official HashiCorp Linux repository.
```
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
```

### Install.
```
sudo dnf -y install terraform
```

# Verify the installation

```
terraform -help
```