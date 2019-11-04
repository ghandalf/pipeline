# Create to source specific files in /etc/profile.d/*.sh
# This case is for a no-login shell in Docker container
# Hardcode path are for security reasons

if [ -r /etc/profile.d/sonarqube.sh ]; then . /etc/profile.d/sonarqube.sh; fi
