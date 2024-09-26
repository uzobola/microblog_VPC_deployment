#!/bin/bash
#This script set up the server so that has all of the dependencies that the application needs,
# Clones the GH repository, 
# Installs the application dependencies from the requirements.txt file as well as [gunicorn, pymysql, cryptography], 
# Sets ENVIRONMENTAL Variables, flask commands, 
# And finally the gunicorn command that will serve the application IN THE BACKGROUND

# Clone GitHub repository
echo "Cloning Git Repository"
echo 
git clone https://github.com/uzobola/microblog_VPC_deployment.git
echo " Repository successfully cloned "

# Navigate into the cloned repository
echo " Navigating to Application directory" 
cd microblog_VPC_deployment
pwd 
sleep 2

# Create the Python virtual environment
echo " Creating Python Environment"
python3.9 -m venv venv

# Activate the Python virtual environment
source venv/bin/activate

# Install any dependencies
echo " Installing dependencies"
pip install -r requirements.txt
pip install gunicorn pymysql cryptography

# Set the environment variable
export FLASK_APP=microblog.py
echo " App Environmental Variable Set"

# Set up the database
flask db upgrade
sleep 2
echo "Database Set "

# Compile translations
flask translate compile


# Run the application in the background
nohup bash -c "source venv/bin/activate && gunicorn -b :5000 -w 4 microblog:app" &
echo "Running application in the background"

