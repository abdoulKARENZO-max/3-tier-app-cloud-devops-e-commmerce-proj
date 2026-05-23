#!/bin/bash
set -e  # Exit on any error

echo "========================================="
echo "Starting Jenkins Server Setup"
echo "========================================="

# Update system
sudo apt update -y
sudo apt upgrade -y

# Install Java (Jenkins requires 25)
sudo apt install -y openjdk-25-jdk wget curl

# Verify Java
java -version

# Install Jenkins via official apt repo
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
  sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y
sudo apt install -y jenkins

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Add users to docker group
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins

# Install Trivy
sudo apt install -y wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
  sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | \
  sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt update -y
sudo apt install -y trivy

# Verify Trivy
trivy --version

# Install AWS CLI
sudo snap install aws-cli --classic

# Install Helm
sudo snap install helm --classic

# Install kubectl
sudo snap install kubectl --classic

# Restart Docker and Jenkins to apply group changes
sudo systemctl restart docker
sudo systemctl restart jenkins

# Wait for Jenkins to fully start
echo "Waiting for Jenkins to start..."
until sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null; do
    sleep 5
    echo "Still waiting..."
done

echo "========================================="
echo "Jenkins Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "========================================="
echo "Jenkins URL: http://$(curl -s ifconfig.me):8080"
echo "Setup complete!"