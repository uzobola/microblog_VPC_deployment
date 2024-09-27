

![Copy of WorkLoad4NetworkDiagramFinal](https://github.com/user-attachments/assets/5dc7921c-6b73-40ad-8657-585029367f65)



### PURPOSE
The purpose of this workload is to establish a more robust and secure deployment infrastructure for our MicroBlog Flask web application, using AWS resources, Jenkins for continuous integration and deployment, and Nginx for serving the application. 
It aims to achieve the following objectives:

1. **Infrastructure Provisioning**: Deploy applications to servers in a more robust and secure infrastructure by separating the deployment environment from the production environment. 

2. **Application Deployment**: Automate deployment using Jenkins, which runs the application build and test phases before deploying to the servers.

3. **Reverse Proxy Configuration**: Use Nginx as a reverse proxy server to manage incoming web traffic.

4. **Security and Accessibility**: Maintain security through key-based SSH authentication and properly configured security groups, while ensuring the application is accessible over the internet.

5. **Monitoring**: Using NodeExporter, Prometheus and Grafana as our monitoring tools to collect and visualize metrics from the application for performance analysis and troubleshooting.


### Steps and Their Importance

1. **Cloning the Repository**
   - Cloning the `microblog_VPC_deployment` repository to GitHub ensures we have the most up-to-date application code and deployment scripts. It ensures that all changes are tracked and versions are managed appropriately as collaboration happens. 
     As the SCM, it also facilitates integration with automation tools in our CI/CD pipeline, e.g., Jenkins.
   - **Importance**: Version control enables collaboration and continuous integration, making it easier to automate deployment.
   
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
   
 **Setting Up the Servers**: The creation of the separate servers facilitates the deployment of the application in a three-tier architecture, which  enhances organization and performance.
   - **Jenkins**: This server automates the CI/CD processes.
   - **Web Server**: Hosts Nginx and serves as a reverse proxy., forwarding traffic to the application server.
   - **Application Server**: Runs the Flask application using Gunicoern, handling the business logic.
   - **Security Groups Configuration**: Properly configuring security groups and allowing specific ports for access ensures that only legitimate traffic is allowed, protecting against unauthorized access.
**Importance**: Separating servers based on their roles provides flexibility and improves security.
  
