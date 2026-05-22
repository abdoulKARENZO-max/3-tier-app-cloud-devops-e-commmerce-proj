#!/bin/bash

# Update system
sudo apt update -y

# Install Java
sudo apt install -y openjdk-21-jdk wget curl

# Download and install Jenkins directly (most reliable method)
wget https://get.jenkins.io/debian-stable/jenkins_2.541.1_all.deb
sudo dpkg -i jenkins_2.541.1_all.deb
sudo apt-get install -f -y

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Docker
sudo apt install -y docker.io
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins

# Install Trivy
sudo apt install -y wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt update -y
sudo apt install -y trivy

# Install AWS CLI
sudo snap install aws-cli --classic

# Install Helm
sudo snap install helm --classic

# Restart Jenkins to apply group changes
sudo systemctl restart jenkins

# Wait for Jenkins to fully start
sleep 30

# Output the initial password
echo "========================================="
echo "Jenkins Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "========================================="