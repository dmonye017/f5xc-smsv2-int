# Instructor Demo: Deploying F5 SMSv2 CE site in AWS (ClickOps) & Terraform Automation

## Instructor Brief:
This demo will show how to deploy an F5 SMSv2 CE site in AWS using the F5XC Console as a starting point, and then using the AWS Console to complete the deployment. 
As you may already be aware, the Legacy AWS VPC Site Deployment is no longer supported in F5XC, and the new F5XC SMSv2 CE Site type is now the recommended option for Customer Edge deployments. 
This change has significantly altered the way CE sites are deployed. The customer now has a greater degree of responsibility for deploying and managing their CE configurations. 
The F5XC platform no longer accepts the use of AWS credentials to orchestrate CE deployments. As a result, the customer must now have access to their own existing AWS infrastructure, in order to essentially "drop" the CE site into their existing AWS environment. 
The expectation remains that the customer's AWS environment will already be configured with the prequisites including the following:
- **1. The customer must have access to the AWS Console and be able to create resources in their AWS account.**
- **2. An existing VPC with at least two subnets (One Public and one Private) in the same region as the F5XC CE site.**
- **3. The VPC must have an Internet Gateway attached to it, and the Public subnet must have a route to the Internet Gateway.**
- **4. Route tables must be configured for the subnets accordingly.**

In the absence of the above prerequisites, the AWS infrastructure will need to be provisioned to support the F5XC CE site deployment or it will fail. 
The F5XC platform will not be able to deploy the CE site into the customer's AWS environment, as it no longer supports the use of AWS credentials for orchestration if the prerequisites are not met.

## Deployment Steps

### 1. Create a Secure Mesh Site V2 site object in F5XC Console
- Log into your F5 Distributed Cloud tenant
- In the F5 Distributed Cloud Console, select the **Multi-Cloud Network Connect** workspace and go to **Site Management** > **Secure Mesh Sites v2**
- Click **Add Secure Mesh Site**
- Create a smsv2 site object using the following details:
  - Name: **test-smsv2-ce**
  - Provider: **AWS**
  - Orchestration Mode: **Not Managed by F5XC** (Notice that this is the only option available. You are entirely responsible for provisioning the resources required to deploy the CE site in your AWS environment)
  - High Availability: **Disable**
  - Leave all other settings as default
- Click **Add Secure Mesh Site**

These are the default settings for the CE site and they are usually enough to get the CE site deployed in AWS. However, if you want to customize the CE site deployment, you can do so by changing the settings in the CE site object. You may want to discuss some of the other available settings in case questions arise. Look out for the following options:
- **Regional Edge Selection**
  This controls which F5XC RE your CE site will connect to for its control plane and data plane tunnels.
  The default is Geo-proximity (the CE dynamically connects to the nearest RE based on geography and latency).
  You can choose a specific RE if a customer has strict Data Sovereignty requirements.
- **Tunnel Type**
  Controls which encapsulation protocol is used for the tunnels between the CE and F5 REs.
  IPSec is the standard option but be aware that choosing IPSec without opening UDP Port 500/4500 on your AWS security group for     the CE will mean that your CE will never complete registration. It will sit there until it times out, so ensure those ports are    open in the security group.
- **Offline Survivability**
  This resilience feature ensures that the CE will continue operating even when it loses connectivity to the F5XC control plane      (when/if the tunnels go offline). If enabled, the CE caches its last-known configuration and continues to forward traffic,         enforce security policies and operate load balancers. Useful for deployments where the network connectivity is unreliable or       flaky! Not necessary for cloud deployments where connectivity is highly reliable.
- **Site to Site Connectivity**
  The settings here control how this CE site can communicate with other CE sites through the F5XC fabric. you can achieve this by    using the **Site Mesh Group** to create a mesh group where its inside (SLI) network is connected to other CE sites' inside         networks via encrypted tunnels through the RE backbone. The Datacenter cluster group is for connecting multiple CE sites that      share a common network or serve as a redundant gateway for the same Datacenter. 
- **Network Firewall**
  Enables L3/L4 network firewall functionality, where the CE can apply stateful firewall rules to traffic traversing the CE node     directly. This is separate from the L7 WAAP capabilities applied at the HTTP LB level. 

### 2. Generate Node Token for the CE Site
- Click the **Action icon** on the newly created CE site object and select **Generate Node Token**. This will generate a node token that you will need to use to deploy the CE site in your AWS environment.
- Click **Copy cloud-init**.
- Paste the copied cloud-init script into a text editor and save it for later use. You will need this script to deploy the CE site in your AWS environment.

Once the SMSv2 CE site object is created and Node Token is generated, you will need to switch to the **AWS Console** to continue the deployment process.

### 3. Deploy the CE Instance in AWS
For the purposes of this demo, we will be using an existing AWS environment to deploy the CE site. However, ensure the students know that they will need to provision the required AWS resources in their own AWS environment in order to successfully deploy the CE site. It is clear that some knowledge of AWS is required to ensure the students understand what resources are needed and how to configure them. 
Use the following steps to deploy the CE site using the existing AWS infrastructure in our AWS tenant. You may want to discuss some of the other available settings in case questions arise. 

- Log into the **AWS Console** (this will depend on the assigned AWS account for the class). The **XXXXXXXXGS_Training_02** tenant is used for this demo. 
-  Navigate to the **AWS Marketplace** and select **Manage subscriptions**. You should see the **F5 Distributed Cloud Customer Edge (BYOL)** subscription (As a customer, you will need to subscribe to this product in order to deploy the CE site    in your AWS environment. You must search for it through **Discover Products** in the AWS Marketplace and subscribe to it by accepting the terms and conditions. Once you have subscribed to the product, you will be able to deploy it in your      AWS environment).
- Select **Launch** to deploy the CE site in your AWS environment. You will be redirected to the **Launch F5 Distributed Cloud Customer Edge (BYOL)** page. You will need to choose a launch method.
- Select **Launch from EC2 Console** option and confirm you are set to the latest, stable version. Also confirm the region is set to **US East (N. Virginia)**. 
- Click **Launch from EC2** to continue. You will be redirected to the **Launch an Instance** page in the EC2 Console.
- Enter the following details in the **Launch an Instance** page:
  - **name**: **test-smsv2-ce**
  - **instance type**: **t3.xlarge** (instance type can be changed based on the expected traffic load for the CE site)
  - **Key pair**: **xxxx-smsv2-key** (Select the key pair you want to use to access the CE site instance. You will need to create a key pair if you do not have one already).
    You can also use any of the existing key pairs, since this is a demo. You will need this key pair to access the CE site instance in your AWS environment)
  - **Network Settings**: Click **Edit** and select the following options:
    - **VPC**: **WAAP-training-VPC** (Select the VPC you want to deploy the CE site in).
    - **Subnet**: **juice-shop-subnet** (Select the public subnet you want to deploy the CE site in. This can also be **subnet-public1-us-east-1a** depending on your preference.
    - **Auto-assign Public IP**: **Disable**.
    - **Firewall (security groups)**: Click **select existing security group** and select **juiceshop-sg** (This security group has been pre-configured to allow access to the CE site instance from the Internet. You can also create your own               security group and configure it accordingly).
  - **Configure Storage**: You can leave the default storage settings as is. The default storage size for the **t3.xlarge** instance is 79 GB, which is sufficient for most CE site deployments. However, you can increase the storage size if you          expect to have a large amount of traffic or data on the CE site.
  - **Advanced Details**:
    - Scroll all the way down to the **User data - optional** section and paste in the **Node Token** you copied earlier. This script will configure the CE site instance with the necessary settings to connect to the nearest F5XC REs and              register the CE as part of the deployment process.
  - Click **Launch Instance**

### 4. Verify the CE Site Deployment
- Once the CE site instance is launched, you can verify that it is running by checking the **Instances** page in the EC2 Console. You should see the **test-smsv2-ce** instance in the list of instances. The instance state should be **running**    and the status checks should show **2/2 checks passed**.
- However, the CE site instance will not be operational until it has successfully connected to the F5XC REs and completed the registration process.
  In its current state, It will **not** be able to do this because it does not yet have a public IP address assigned to the instance. We need to generate an **Elastic IP address** and associate it with the Network interface that the CE site      instance is using.
- Navigate to **EC2 > Instances > test-smsv2-ce** and click on the **Networking** tab. Scroll down to the **Network interfaces** section and click on the **eni-xxxxxxxxxxxx** link. This will take you to the **Network Interface** page for the     CE instance.
- Note the **Network Interface ID** by copying it to your clipboard. You will need this ID to associate the Elastic IP address with the CE site instance.
- Navigate to **EC2 > Network & Security > Elastic IPs** and select the **f5xc-ce-eip** checkbox
- Click **Actions** and select **Associate Elastic IP**. 
- In the **Associate Elastic IP address** page, select **Network interface** and paste in the **Network Interface ID** you copied earlier.
- Click the empty field under **Private IP address** and select the private IP address of the CE site instance.
- Click **Associate** to associate the Elastic IP address with the CE site instance.
- Go back to the **EC2 > Instances page**, select the **test-smsv2-ce** instance anc click **Instance state**. 
- Select **Reboot instance** and confirm the action by clicking **Reboot**.

### 5. Verify the CE Site Instance is Operational
- After the instance has rebooted, wait a few minutes and then switch over to your F5 Distributed Cloud Account.
- Navigate to **Multi-Cloud Network Connect** > **Site Management** > **Secure Mesh Sites v2**. 
- You should notice that the **Site Admin State** has changed to **Provisioning** once the CE site instance has successfully connected to the F5XC REs. 
- It will transition from **Provisioning** --> **Upgrading** --> **Online** during the process.
- The estimated time for the CE site to complete the deployment process is about 15 - 20 minutes. You can monitor the progress of the deployment by checking the **Status** column in the **Secure Mesh Sites v2** page. Once the deployment is       complete, the **Site Admin State** will change to **Online**.

### 6. Automate the Deployment of the Student CE Sites using Terraform
Owing to the complexity of the CE site deployment process, it is recommended that the CE sites that will be used during the training be deployed using Terraform. 
We will provide documentation on how to deploy the SMSv2 CE site through the F5XC Console and AWS Console (ClickOps) and also through Terraform. Students can use those resources to deploy the CE into their own AWS environments. 
For this training, automating the deployment process will ensure that the CE sites are deployed in a consistent manner and will also save time during training delivery. 
The following steps are to be performed by the **Instructor only** and will show how to deploy the student CE sites using Terraform.

#### 6a. Clone the GitHub repository containing the Terraform configuration files for the CE site deployment
Clone the following GitHub repository to your local machine:
```
git clone https://github.com/dmonye017/f5xc-smsv2-int.git 
```
### 6b. Generate API P12 file for the F5XC API
- Log into your F5 Distributed Cloud tenant and navigate to **Administration** > **Credentials**
- Click **Add Credentials** and provide details for the following:
  - **CredentialName**: **instructor-api-creds**
  - **Credential Type**: **API Certificate**
  - **Password**: **XXXXXXXX**
  - **Confirm Password**: **XXXXXXXX**
  - **Expiry Date**: **MM-DD-YYYY**
- Click **Download**

Please note the Password you entered when creating the API Certificate. You will need to export the value to your Terminal environment to facilitate authentication with the F5XC API using the P12 file.
Copy the downloaded P12 file into the **same directory** where you will be running the Terraform configuration. 
You will need to update the **f5xc_api_p12_file** variable in the **students.auto.tfvars** file with the path to the P12 file.

### 6c. Export the F5XC API P12 file password to your Terminal environment
Switch back to the terminal window from Step 6a and run the following command to export the password:
```
export VES_P12_PASSWORD="XXXXXXXXX"
```
Ensure that you replace **XXXXXXXXX** with the password you entered when creating the API Certificate in Step 6b. This will allow Terraform to authenticate with the F5XC API using the P12 file.

#### 6d. Review the Terraform configuration files and make any necessary changes as required. The following files are included in the repository:
- **main.tf**: This file contains the main Terraform configuration for deploying the CE site in AWS.
- **variables.tf**: This file contains the variable definitions for the Terraform configuration.
- **outputs.tf**: This file contains the output definitions for the Terraform configuration.
- **students.auto.tfvars**: This file contains the variable values for the student CE site deployments. You will need to update this file with the appropriate values for your AWS environment and the student CE site deployments. The following     are the variable values that you will need to update:
  - **aws_region**: The AWS region in which the CE site will be deployed.
  - **aws_az**: The AWS availability zone in which the CE site will be deployed.
  - **ce_ami_id**: The AMI ID for the CE site instance that will be deployed.
  - **instance_type**: The instance type for the CE site instance that will be deployed.
  - **volume_size**: The volume size for the CE site instance that will be deployed.
  - **ssh_key_name**: The SSH key name for the CE site instance that will be deployed.
  - **f5xc_api_p12_file**: The path to the F5XC API P12 file that will be used to authenticate with the F5XC API.
  - **f5xc_api_url**: The URL for the F5XC API that will be used to authenticate with the F5XC API.
  - **students**: A map of student names to their respective VPC and subnet CIDR blocks. You will need to update this map with the appropriate values for your AWS environment and the student CE site deployments. The following are the variable      values that you will need to update:
    - **vpc_cidr**: The CIDR block for the VPC in which the CE site will be deployed.
    - **slo_subnet_cidr**: The CIDR block for the SLO subnet (public) in which the CE site will be deployed.
    - **sli_subnet_cidr**: The CIDR block for the SLI subnet (private) in which the CE site will be deployed.
- **providers.tf**: This file contains the provider configuration for the Terraform configuration.
- **f5xc-smsv2.tf**: This file contains the Terraform configuration for generating the Node Token and creating the F5XC SMSv2 CE site object in F5 Distributed Cloud.

### 6e. Before Initializing the Terraform Configuration
  - Ensure that you have the appropriate permissions to create resources in your AWS environment.
  - Terraform is installed on your local machine.
  - AWS CLI installed and configured with the appropriate credentials to access your AWS environment.
  - F5XC API P12 file and URL for authenticating with the F5XC API.
  - If deploying outside of **us-east-1** in AWS, Locate AMI ID for your region by navigating to **AWS Marketplace > Manage Subscriptions > F5 Distributed Cloud CE BYOL** and click launch instance. select Launch on EC2 console and view the         list of AMIs per region on the AMI details section. Once the AMI ID is identified, enter this in the **ami_id** variable for the **students.auto.tfvars** file.
  - Depending on the number of students registered to attend the class, the Instructor can modify the **students.auto.tfvars** file to only have the specific number of students. 

### 6f. Initialize the Terraform Configuration
Open a terminal and navigate to the directory where you cloned the GitHub repository.
Run the following command to initialize the Terraform configuration:
```
terraform init
```
This command will download the necessary provider plugins and initialize the Terraform configuration.

### 6h. Plan the Terraform Configuration
Run the following command to plan the Terraform configuration:
```
terraform plan
```
This command will show you the resources that will be created, modified, or destroyed by the Terraform configuration. Review the output to ensure that the resources will be created as expected.

### 6i. Apply the Terraform Configuration
Run the following command to apply the Terraform configuration:
```
terraform apply
```
This command will create the resources in your AWS environment and deploy the CE site. You will be prompted to confirm the action. Type **yes** and press **Enter** to proceed with the deployment. The deployment process may take several minutes to complete. You can monitor the progress of the deployment by checking the output in the terminal.

### 6j. Verify the CE Site Deployment
Once the deployment is complete, you can verify that multiple CE sites have been successfully deployed by checking the **Secure Mesh Sites v2** page in the F5 Distributed Cloud Console. You should see multiple CE site objects with the names corresponding to the student names defined in the **students.auto.tfvars** file. The **Site Admin State** for each CE site should be **Online** once the deployment is complete.

### 7. Destroying the CE Sites
After the Administering Apps in XC training is completed, you must destroy the CE sites that were deployed using Terraform by running the following command:
```
terraform destroy -auto-approve
```
Before you run this command, ensure that all other objects created in the F5XC Console during the course have been deleted. This command will destroy all the resources that were created by the Terraform configuration only and remove the CE site objects from the F5 Distributed Cloud Console. The destruction process may take several minutes to complete. You can monitor the progress of the destruction by checking the output in the terminal.









