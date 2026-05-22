terraform init -reconfigure
ssh-keygen -t rsa -b 4096 -f terra-key -N ""

# Destroy the partial resources created before errors djdjdj
terraform destroy -auto-approve

# Then reapply cleanly and  # it will pick up where it left off
terraform apply -auto-approve