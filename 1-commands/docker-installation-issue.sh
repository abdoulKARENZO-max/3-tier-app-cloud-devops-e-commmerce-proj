#Reload systemd and restart
sudo systemctl daemon-reload
sudo systemctl stop docker.socket
sudo systemctl stop docker.service
sudo systemctl start docker.service
sudo systemctl status docker.service
#Add Jenkins to Docker Group
# Add jenkins user to docker group
sudo usermod -aG docker jenkins

# Verify
groups jenkins

# Restart Jenkins to apply group changes
sudo systemctl restart jenkins

# Wait for Jenkins to restart
sleep 10

# Test Jenkins can run Docker
sudo -u jenkins docker ps