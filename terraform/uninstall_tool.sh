#!/bin/bash

# Stop all services
sudo systemctl stop jenkins docker
sudo systemctl disable jenkins docker

# Remove Jenkins completely
sudo apt-get remove --purge jenkins -y
sudo apt-get remove --purge jenkins* -y
sudo rm -rf /var/lib/jenkins
sudo rm -rf /var/log/jenkins
sudo rm -rf /etc/default/jenkins
sudo rm -rf /usr/share/jenkins
sudo rm -f /etc/systemd/system/jenkins.service
sudo rm -f /usr/lib/systemd/system/jenkins.service

# Remove Jenkins repository and keys
sudo rm -f /etc/apt/sources.list.d/jenkins.list
sudo rm -f /usr/share/keyrings/jenkins*
sudo apt-key del 7198F4B714ABFC68 2>/dev/null

# Remove Docker
sudo apt-get remove --purge docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc -y
sudo rm -rf /var/lib/docker
sudo rm -rf /etc/docker

# Remove Trivy
sudo apt-get remove --purge trivy -y
sudo rm -f /etc/apt/sources.list.d/trivy.list

# Remove AWS CLI
sudo snap remove aws-cli

# Remove Helm
sudo snap remove helm

# Remove Java (optional - only if you want to reinstall)
sudo apt-get remove --purge openjdk-11-jdk openjdk-17-jdk openjdk-21-jdk -y

# Remove leftover dependencies
sudo apt-get autoremove --purge -y
sudo apt-get autoclean

# Remove Jenkins user and group
sudo userdel -r jenkins 2>/dev/null
sudo groupdel jenkins 2>/dev/null

# Clean apt cache
sudo apt-get clean

# Update package list
sudo apt update

echo "========================================="
echo "All Jenkins-related packages removed!"
echo "System is ready for fresh installation"
echo "========================================="