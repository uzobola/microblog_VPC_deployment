

![Copy of WorkLoad4NetworkDiagramFinal](https://github.com/user-attachments/assets/5dc7921c-6b73-40ad-8657-585029367f65)

---

### PURPOSE
The purpose of this workload is to establish a more robust and secure deployment infrastructure for our MicroBlog Flask web application, using AWS resources, Jenkins for continuous integration and deployment, and Nginx for serving the application. 
It aims to achieve the following objectives:

1. **Infrastructure Provisioning**: Deploy applications to servers in a more robust and secure infrastructure by separating the deployment environment from the production environment. 

2. **Application Deployment**: Automate deployment using Jenkins, which runs the application build and test phases before deploying to the servers.

3. **Reverse Proxy Configuration**: Use Nginx as a reverse proxy server to manage incoming web traffic.

4. **Security and Accessibility**: Maintain security through key-based SSH authentication and properly configured security groups, while ensuring the application is accessible over the internet.

5. **Monitoring**: Using NodeExporter, Prometheus and Grafana as our monitoring tools to collect and visualize metrics from the application for performance analysis and troubleshooting.

---
### Steps and Their Importance

1. **Cloning the Repository**
   - Cloning the `microblog_VPC_deployment` repository to GitHub ensures we have the most up-to-date application code and deployment scripts. It ensures that all changes are tracked and versions are managed appropriately as collaboration happens. 
     As the SCM, it also facilitates integration with automation tools in our CI/CD pipeline, e.g., Jenkins.
   - **Importance**: Version control enables collaboration and continuous integration, making it easier to automate deployment.

---
   
2. **Creating a Custom VPC (Virtual Private Cloud)**
   
Setting up a custom VPC with one Availability Zone (AZ) and both public and private subnets is useful for isolating resources.
   - **Importance**: The public subnet allows access to the internet for the `Web_Server`, while the private subnet provides security for the `Application_Server`.
   -  **Creating a Custom VPC**: This provides a secure isolated network environment. A custom VPC also gives us more control over how we want to configure the network.
   - **Public and Private Subnets**: Separate subnets help to keep sensitive applications or databases off the public internet while exposing necessary resources to the internet through the public subnet.
   - **NAT Gateway**: A NAT Gateway allows our Application_Server` in the private subnet to access the internet without exposing it to internet traffic.
   - **DNS hostnames and Resolution:** Are enabled to allow instances to communicate via DNS names.

**STEPS**
1. On the VPC dashboard, choose "Create VPC".
Select "VPC and more" under "Resources to create".
2. **Configure the VPC**:
    - Name tag: Enter a name for your VPC (e.g., "CustomVPC")
    - IPv4 CIDR block: Enter a CIDR block (e.g., 10.0.0.0/16)
    - IPv6 CIDR block: No IPv6 CIDR block
    - Tenancy: Default
3. **Configure the subnets:**
    - Number of Availability Zones: 1
    - Number of public subnets: 1
    - Number of private subnets: 1
4. **NAT gateways:**
    - Select "1 NAT Gateway"
5. **VPC endpoint:**
    - Leave this unchecked (we don't want any VPC endpoints)
6. **DNS options:**
    - Enable DNS hostnames: Check this box
    - Enable DNS resolution: Check this box
7. **Review and create:**
    - Click "Create VPC"

After the VPC is created:
Auto assign public IPv4 addresses in Public Subnet

1. Go to "Subnets" in the left navigation pane.
2. Select your newly created Public Subnet.
3. In the "Actions" dropdown, select "Edit subnet settings".
4. Ensure  "Enable auto-assign public IPv4 address" is checked.
5. Click "Save changes".

This process will create a VPC with:
- One public subnet
- One private subnet
- An Internet Gateway (automatically attached to the VPC)
- A NAT Gateway in the public subnet
- Route tables for both public and private subnets
- DNS hostnames and DNS resolution enabled

**Setting up the EC2 Instances**
   - **Requirements:**
   - Jenkins instance (Default VPC)
   - Web_Server (Custom VPC -Public subnet)
   - Application_Server (Custom VPC- Private subnet)
   
 **Setting Up the Servers**: Creating separate servers facilitates the deployment of the application in a three-tier architecture, which  enhances organization and performance.
   - **Jenkins**: This server automates the CI/CD processes.
   - **Web Server**: Hosts Nginx and serves as a reverse proxy., forwarding traffic to the application server.
   - **Application Server**: Runs the Flask application using Gunicoern, handling the business logic.
   - **Security Groups Configuration**: Properly configuring security groups and allowing specific ports for access ensures that only legitimate traffic is allowed, protecting against unauthorized access.
**Importance**: Separating servers based on their roles provides flexibility and improves security.


  STEPS
#### Jenkins Server ####
On the EC2 dashboard

- 1. Click on "Launch Instance"
- 2. Name and tags:
    - Name: Jenkins
- 3. Application and OS Images:
    - Choose Ubuntu AMI (free tier eligible)
- 4. Instance type:
    - Select t3.medium
- 5. Key pair:
    - I created a new key pair
- 6. Network settings:
    - VPC: Select the Default VPC
    - Subnet: No preference
    - Auto-assign public IP: Enable
- 7. Create a new security group:
    - Name: Jenkins_SG
    - Description: Security group for Jenkins Server
    - Add the following rules: 
    Type: SSH, (port 22), Source: 0.0.0.0/0 
    Type: HTTP,  (port 80), Source: 0.0.0.0/0
    Type: Custom TCP, (port 8080), Source: 0.0.0.0/0 (Jenkins)
- 8. Configure storage:
    - Keep the default settings
- 9. Advanced details:
    - Leave as default unless you have specific requirements
- 10. Review and launch the instance

After the instance is launched, you'll have a t3.medium EC2 instance named "Jenkins" in the public subnet of your Default VPC, with a security group allowing inbound traffic on ports 22 (SSH) and 80 (HTTP) and 8080(Jenkins).


Install Jenkins on the Server using the installation script  'install-jenkins.sh'

**Important**:Creating SSH keys on the `Jenkins` server and distributing them to `Web_Server` and `Application_Server` ensures a secure connection between the servers. Testing the connection by SSH'ing into the 'Web_Server' from the 'Jenkins' server verifies that the servers can connect without manual intervention and adds the servers to the "list of known hosts”. A  **"known host"** is a remote server that your system recognizes and trusts for SSH connections based on its stored public key. This is important because it helps to ensure secure and verified SSH connections.
 

**Steps to configure the connection**

In the console, connect to the Jenkins  Server
1. Navigate to the  .ssh directory and generate an SSH key pair. 
- cd .ssh/
- ssh-keygen  
2. Copy the contents of the public key file 
3. Connect to the web server and paste the contents to  ~/.ssh/authorized_keys 

Test the connection to the webserver

1. From the Jenkins server 
2. ssh into the web server
3. If prompted about the authenticity of the host, type "yes" and press Enter. This will add the Web_Server to the list of known hosts.

 

#### Web Server ####
On the EC2 dashboard
1. Click on "Launch Instance"
2. Name and tags:
    - Name: Web_Server
3. Application and OS Images:
    - Choose Ubuntu AMI (free tier eligible)
4. Instance type:
    - Select t3.micro
5. Key pair:
    - Select the existing pair or create a new pair
6. Network settings:
    - VPC: Select Custom VPC
    - Subnet: Choose the public subnet
    - Auto-assign public IP: Enable
7. Create a new security group:
    - Name: Web_Server_SG
    - Description: Security group for Web Server
    - Add the following rules: 
    Type: SSH, (port 22), Source: My IP  
    Type: HTTP,  (port 80), Source: Anywhere-IPv4
8. Configure storage:
    - Keep the default settings
9. Advanced details:
    - Leave as default unless you have specific requirements
10. Review and launch the instance

After the instance is launched, you'll have a t3.micro EC2 instance named "Web_Server" in the public subnet of the Custom VPC, with a security group allowing inbound traffic on ports 22 (SSH) and 80 (HTTP).


#### Application Server ####
 On the EC2 dashboard
1. Click on "Launch Instance"
2. Name and tags:
    - Name: Application_Server
3. Application and OS Images:
    - Choose Ubuntu AMI (free tier eligible)
4. Instance type:
    - Select t3.micro
5. Key pair:
    - Select the existing pair or create a new pair
6. Network settings:
    - VPC: Select the Custom VPC
    - Subnet: Choose the private subnet already created
    - Auto-assign public IP: Disable
7. Create Security Group
- Security group name: Application_Server_SG
- Description: Security group for Application Server
- Add the following rules:
a. Type: SSH, Port: 22, Source: Custom, CIDR:10.0.0.0/16
b. Type: Custom TCP, Port: 5000, Source: Custom, CIDR: 10.0.0.0/16s
    - Keep the default setting
8. Review and launch the instance

After the instance is launched, you'll have a t3.micro EC2 instance named "Application_Server" in the private subnet of the Custom VPC, with a security group allowing inbound traffic on ports 22 (SSH) and 5000. Only resources within the VPC can directly reach this instance.

---


**Setting Up NginX on the Web Server**

Installing and configuring NginX to forward traffic from the web server to the application server is necessary for managing web traffic.
   - **Importance**: NginX acts as a reverse proxy, forwarding HTTP requests to the application server's private IP on port 5000. It serves as a middle layer between users and the application server. It handles client requests, improves performance through caching, and forwards requests to the application server. This setup isolates the application server while still ensuring the resources are available to internet traffic.

**Nginx Installation and Configuration**: 

Install
- sudo apt update && sudo apt install nginx


Configuration
The '/etc/nginx/sites-enabled/default file' is the default server configuration file for nginx. The location block values below sets up nginx as a proxy server for forwarding of all incoming requests to the application running on port 5000.

- sudo vim /etc/nginx/sites-enabled/default
- Modify the "sites-enabled/default" file with the following contents ...

location / {
proxy_pass http://<private_IP>:5000;
proxy_set_header Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
- run sudo nginx -t  (This verifies that there are no syntax errors with the changes made to the configuration file are correct.
- Restart nginx :  sudo systemctl restart nginx
 

---

**Creating and Running Deployment Scripts**
   - Two scripts are created:
     - **start_app.sh**: Sets up the application server and starts the Flask application in the background using Gunicorn. It will ensure the server has all the dependencies the application needs. It will clone the GH repository, install the application dependencies from the requirements.txt file and [gunicorn, pymysql, cryptography], set ENVIRONMENTAL Variables, and run necessary commands. running **Gunicorn as the  WSGI Server** helps the Flask application, manage multiple requests efficiently without overloading the server.
     
     - **setup.sh**: Executes the deployment process by SSH’ing into the application server and running `start_app.sh`.
   - **Importance**:
   **Script Automation**: Creating scripts automates the deployment and setup process, ensuring consistent configuration and reducing human error during deployment.

**Question:** What is the difference between running scripts with the source command and running the scripts either by changing the permissions or by using the 'bash' interpreter?

- Running with Source  run the scripts in the current shell. This is recommended because the scripts configure the application environment and we need the configurations to remain accessible in the current shell environment. Changes made persist in the current shell after the script finishes.
- Running the script by changing the permissions and using the bash interpreter both run the script isolated from the current shell environment.


---
**Deployment with Jenkins Pipeline**

**Creating  a multibranch Pipeline**

1. Log into Jenkins
2. Create a Multi-Branch pipeline
- a. Click on “New Item” in the menu on the left of the page
- b. Enter a name for your pipeline
- c. Select “Multibranch Pipeline”
- d. Under “Branch Sources”, click “Add source” and select “GitHub”
- e. Click “+ Add” and select “Jenkins”
- f. Make sure “Kind” reads “Username and password”
- g. Under “Username”, enter your GitHub username
- h. Under “Password” , enter your GitHub personal access token
- i. Click on Add
    
- 3. Connect GitHub repository to Jenkins
- a. Enter the repository HTTPS URL and click "Validate"
- b. Make sure that the "Build Configuration" section says "Mode: by  Jenkinsfile" and "Script Path: Jenkinsfile"
- c. Click "Save" and a build should start automatically

  
**Creating the Jenkinsfile**

A Jenkinsfile is used to automate the build, test, and deployment process.
   - **Importance**: Using a pipeline for CI/CD ensures that any changes to the codebase are automatically tested and deployed, improving the efficiency of the development lifecycle.
   - **Jenkins Pipeline Configuration**: Setting up a Jenkins pipeline provides automation for building, testing, and deploying the application, making the process repeatable and less error-prone.
 
   
**Requirement**
- Create a Jenkinsfile that will 'Build' the application, 
**Build Stage**
-The purpose of the Build stage is to create a consistent environment with all necessary dependencies installed, which can then be used for running tests and other checks before deployment.

**Test Stage***
- Test the application by running a pytest 
- I reused tests from  WL3 tests/unit/test_app.py

**Dependency Test Stage***
- Run the OWASP dependency checker, which checks the application dependencies against a database of known vulnerabilities.

Steps: 
- a. Navigate to "Manage Jenkins" > "Plugins" > "Available plugins" > Search  for “ OWASP Dependency-Check” and install
- b. Then configure it by navigating to "Manage Jenkins" > "Tools" > "Add Dependency-Check > Name: "DP-Check" > check "install automatically" > Add Installer: "Install from [github.com](http://github.com/)" =⇒ Save

![Dependency Check](https://github.com/user-attachments/assets/3aafb09f-81c4-4425-bf70-4389ed3507cb)


***Deploy Stage**
- Deploys the application by SSH'ing into the Web_Server to run "setup.sh" (which would then run "start_app.sh").
Issues encountered in this stage are documented in the "Issues" section below.

![Jenkins Build 1](https://github.com/user-attachments/assets/cb32a7bb-ac13-4bca-b454-a91f49590f2b)


![Application Server Running](https://github.com/user-attachments/assets/1164f943-296f-4002-b35c-9f4e4d4b6dc1)

**Question 1:**  How do you get the scripts onto their respective servers if they are saved in the GitHub Repo? Do you SECURE COPY the file from one server to the next in the pipeline? Do you C-opy URL the file first as a setup? 

- I used SCP to transfer the scripts from the application server to the web server and pushed them to the GitHub repo.

**Question 2:**  In WL3, a method of "keeping the process alive" after a Jenkins stage was completed was necessary. Is it in this Workload? Why or why not?

In this workload, keeping the process alive after the Jenkins stage was completed was not necessary, because:
- The deployment process was separated from the application runtime environment.
- The "start_app.sh" script was run on the application server independently of Jenkins. 
- Jenkins was responsible for deployment, not for running the application. 
- Once deployed, the application ran on its own and continued running after the deployment script finished.


---

**Monitoring with Prometheus and Grafana**

Launch a separate EC2 instance (`Monitoring`) set up to collect metrics from the application server using Node Exporter, Prometheus, and dashboard visualization using Grafana.
 
 **Tools**
 - **Node Exporter:** Collects system metrics and exposes them in a format that Prometheus can use.
 - **Prometheus:** Collects and stores metric data
 - **Grafana:** Provides customizable visualization dashboards.
 
 
**Importance**: These monitoring tools collect application metrics, providing visibility into the application's performance. Monitoring the infrastructure enables the proactive detection of potential issues, which helps ensure high availability and optimal performance."
  
**Detailed steps can be found at** https://github.com/mmajor124/monitorpractice_promgraf.git 

** TLDR; Steps to Configure Node Exporter, Prometheus, and Grafana**
- 1. Launch an EC2 instance:.
- 2. Configure security groups: Allow inbound traffic for SSH(22), HTTP(80), and custom ports for Prometheus, Grafana, and Node Exporter.
- 3. Download, and install Node Exporter on the client we want to monitor (application_server)
- 4. Download and install Prometheus and Grafana on the monitoring system (monitoring server).
- 5. Configure Prometheus: Configure Prometheus to run as a service and monitor the client.
- 6. Configure Grafana
- 7. Integrate Grafana and Prometheus: Log in to Grafana, navigate to Data Sources, and add Prometheus as a data source.
- 8. Import a dashboard:  I imported the Node Explorer dashboard from the Grafana website Dashboards page.
https://grafana.com/grafana/dashboards/1860-node-exporter-full/  


![GrafanaDashboard](https://github.com/user-attachments/assets/d66d9890-ff58-4a61-bcbe-37bca46ae089)

![Prometheus](https://github.com/user-attachments/assets/3ea0fb0f-66cf-4243-9c2f-4b1634bb521d)


----


#### Issues #1 ####

In Jenkins deployment, I faced the issue of the application not running in the background in the "Deploy" stage.

**Solution:**  
- Activate the virtual environment .( again in this stage)
- Use  “nohup” (No hang Up”, so it runs even if the terminal session is closed)
- Starts gunicorn with  the application
- Wrap the command  in a bash -c command ( “bash -c” starts a new bash shell. The flag executes everything that comes within the  “ “ string  as a complete  command”)

*# Run the application in the background*

nohup bash -c "source venv/bin/activate && gunicorn -b :5000 -w 4 microblog:app"  &

**Result:** 
The virtual environment is activated before starting the application and runs it in the background”


#### Issue #2 ####
I could not get node exporter to gather system metrics from the application server to feed to Prometheus. I checked to make sure the security groups and route tables were configured correctly to allow traffic flow. 


**Solution:**
- The root cause of the issue was a misconfigured VPC peering CIDR block in the private subnet of the custom VPC. I had set up VPC peering to allow communication between the default VPC (Jenkins server)  and the Custom VPC ( Web_Server and Application Server).

- I discovered that I had set the destination to the CIDR block of the custom VPC instead of the default VPC so, they could not talk to each other.

**Communication Flow** 
Jenkins server ==>> Web Server (public subnet) ==>> Application Server (private subnet)



#### Issue #3 ####

How to enable  Jenkins to SSH into the "Web_Server" to run "setup.sh" (which would then run "start_app.sh")


**Solution:**
I installed the SSH Agent Plugin

-The SSH Agent plugin allows you to provide SSH credentials to builds via an ssh-agent in Jenkins. This is useful for securely SSHing into servers during the deployment process.

Installation Steps:
- Go to "Manage Jenkins" > "Manage Plugins"
- Click on the "Available" tab
- Search for "SSH Agent"
- Check the box next to "SSH Agent Plugin"
- Click "Install without restart" or "Download now and install after restart"

I chose this solution because adding the private key as a credential through the Jenkins was the recommended secure way to handle SSH keys. 

With security in mind, I learnt that:
    - Jenkins encrypts credentials at rest, providing better security than storing keys in plain text.
    - Access to credentials can be controlled through Jenkins' security settings.



---


## Optimization

#### **Separation of Deployment and Production Environments** ####
   - **Advantages**: By separating the deployment environment (Jenkins, Web_Server) from the production environment (Application_Server), ensures that:
     - Issues in deployment won’t affect the production server.
     - The private subnet isolates the production environment, minimizing exposure to external attacks.
	 - Automation through Jenkins and shell scripts, reduces human errors and ensures a scalable environment. 


#### **Does this Workload Address These Concerns?** ####
   - Yes, this workload sets up an isolated environment where deployment is separated from production. The public and private subnet configuration ensures that the business logic is 
     restricted to the private subnet, while the web server remains accessible to users.
   - In addition, configuring VPC peering allows for secure communication between the deployment and production environments while still maintaining network isolation.

#### **Is this a "Good System"?** ####
   - **Strengths**: The infrastructure is simple, secure, and works for small-scale applications. Introducing more automation to the deployment makes processes faster, more reliable, and less prone to human errors.
   - **Weaknesses**: The infrastructure can be optimized with more AWS components for redundancy, and high availability.

#### **Potential Optimization Ideas** ####
   - **Scaling**: Adding auto-scaling to handle increasing traffic.
   - **Multi-Availability Zones**: Deploying more servers across multiple availability zones for redundancy and high availability.
   - **Load Balancing**: Adding a load Balancer to distribute traffic evenly and reduce single points of failure.
   - **Security**: Adding a web application firewall (WAF) to protect against common attacks.

#### Conclusion ####
While this infrastructure works for small-scale deployments.The suggested optimization would improve security, reliability, and scalability, to better handle the large-scale requirements of real-world production environments.
