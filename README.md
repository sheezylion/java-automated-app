# **Automated CI/CD Pipeline for Java App Deployment on Apache Tomcat (AWS EC2)**

## Overview

This project implements an automated CI/CD pipeline that builds a Java web application into a WAR file and deploys it to Apache Tomcat on AWS EC2 using Jenkins.

The goal is to remove manual deployments, reduce errors, and provide visibility into build and deployment results.

## What Problem This Solves 

Before this project:

- Deployments were manual

- Engineers had to SSH into servers

- Builds were inconsistent


After this project:

- Builds and deployments are automated

- Every push triggers the pipeline

- Deployments are repeatable and traceable

- Slack alerts provide immediate feedback

## Architecture 

- GitHub – Source code & webhook trigger

- Jenkins EC2 – CI/CD pipeline (build + deploy)

- Tomcat EC2 – Application runtime

- Slack – Deployment notifications

- Jenkins and Tomcat communicate over private IP using SSH.

### **Step 1: Provision Infrastructure (Terraform)**

Created two EC2 instances:

- Jenkins server

- Tomcat server

Configured security groups:

- Jenkins: SSH (22), UI (8080)

- Tomcat: SSH + 8080 only from Jenkins

- Increased Jenkins disk size to avoid build failures

Command

```
terraform init
terraform plan
terraform apply
```
<img width="722" height="555" alt="Screenshot 2026-01-15 at 17 28 04" src="https://github.com/user-attachments/assets/3dd43178-662e-49b2-b5c6-5b34fb5e55eb" />

Result

- Two EC2 instances running

- Public IPs available for Jenkins UI

- Private IP used for Tomcat access

<img width="1433" height="442" alt="Screenshot 2026-01-16 at 03 57 30" src="https://github.com/user-attachments/assets/599caf5e-6e35-4a71-b3ae-f69934c4b1ad" />

### **Step 2: Configure Servers (Ansible)**

**Jenkins Server Configuration**

Installed and configured:

- Java 11 (Amazon Corretto)

- Jenkins

- Maven

- Git

<img width="988" height="467" alt="Screenshot 2026-01-15 at 21 20 12" src="https://github.com/user-attachments/assets/107e35bb-ebc3-4b16-be9b-8d93852dd4e5" />


Verified:

- Jenkins service running

- Jenkins UI accessible on port 8080

<img width="971" height="573" alt="Screenshot 2026-01-15 at 21 20 58" src="https://github.com/user-attachments/assets/6fa4a272-de3b-4a5a-92b9-3385b05dab40" />

<img width="988" height="844" alt="Screenshot 2026-01-15 at 21 22 12" src="https://github.com/user-attachments/assets/17927f25-f8a0-4ded-be33-f23588f80d40" />


**Tomcat Server Configuration**

Installed and configured:

- Java 11

- Apache Tomcat 9

- systemd service for Tomcat

Verified:

- Tomcat running as a service
- Accessible locally and via private IP

<img width="851" height="438" alt="Screenshot 2026-01-16 at 04 01 52" src="https://github.com/user-attachments/assets/56285303-4c49-4b4f-8c7b-620d0941dafc" />

<img width="820" height="860" alt="Screenshot 2026-01-16 at 04 02 46" src="https://github.com/user-attachments/assets/d42fca44-2573-4a13-a978-8caa58b1957a" />


### **Step 3: Prepare the Java Application**

Converted project to a Maven WAR application

- Added pom.xml

- Added a servlet using javax.servlet (Tomcat 9 compatible)

- Ensured WAR builds successfully

Local verification

```
mvn clean package
```

Result:

```
target/java-auto-app.war
```

<img width="1019" height="417" alt="Screenshot 2026-01-16 at 04 05 01" src="https://github.com/user-attachments/assets/30f7be5c-ab6e-4060-a4df-6bd9f3a65dae" />


### **Step 4: Configure Jenkins Job**

**Jenkins Configuration**

Installed required plugins:

- Git

- Maven

- SSH Agent

- Slack Notification

Configured tools:

- JDK

- Maven

<img width="1578" height="893" alt="Screenshot 2026-01-15 at 21 34 26" src="https://github.com/user-attachments/assets/e9f41525-cc01-4b66-a789-b989037aa65c" />

<img width="1499" height="905" alt="Screenshot 2026-01-15 at 21 34 46" src="https://github.com/user-attachments/assets/9fb6197e-5787-4fe5-bdbe-5b77ed28bdbb" />


Added credentials:

- SSH private key for Tomcat

- Slack webhook URL

<img width="1591" height="778" alt="Screenshot 2026-01-15 at 22 03 33" src="https://github.com/user-attachments/assets/d4f88450-d54e-4c70-adc5-63c437cfbed2" />

<img width="1600" height="536" alt="Screenshot 2026-01-15 at 22 46 36" src="https://github.com/user-attachments/assets/254ef383-1a5a-4a73-aee7-f0dc85b051c2" />

### **Step 5: GitHub Webhook Setup**

Created GitHub webhook pointing to:

```
http://<jenkins-ip>:8080/github-webhook/
```

Result

- Any push to main triggers Jenkins automatically

<img width="1452" height="923" alt="Screenshot 2026-01-15 at 22 57 23" src="https://github.com/user-attachments/assets/494a36ff-b44a-4680-b215-c51232a19e6f" />

### **Step 6: Jenkins Pipeline (CI/CD)**
Pipeline Stages

1. Checkout

- Pulls latest code from GitHub

2. Build WAR

- Runs mvn clean package

- Fails early if build errors occur

3. Deploy to Tomcat

- Copies WAR to Tomcat via SSH

- WAR auto-expands in webapps

<img width="1008" height="881" alt="Screenshot 2026-01-16 at 03 11 24" src="https://github.com/user-attachments/assets/e35c8e02-b66e-455a-b4ab-775ad2c76be4" />


4. Post Actions

- Sends Slack notification on success or failure

<img width="1675" height="885" alt="Screenshot 2026-01-16 at 03 11 32" src="https://github.com/user-attachments/assets/67d398a1-070c-403a-8a67-b38a0b64bf6f" />


### **Step 7: Slack Notifications**
What happens

- Pipeline start → Slack message

- Build failure → Slack alert

- Successful deployment → Slack confirmation

<img width="1638" height="953" alt="Screenshot 2026-01-16 at 04 17 44" src="https://github.com/user-attachments/assets/c9ec4f64-42cb-49f1-bef9-8d1cb884766f" />


### **Step 8: Deployment Verification**
On Tomcat Server
```
ls /opt/tomcat/webapps
```
<img width="606" height="186" alt="Screenshot 2026-01-16 at 04 14 34" src="https://github.com/user-attachments/assets/15001997-0197-4284-b32d-7b4554919b18" />


Application Test

```
curl http://<tomcat-ip>:8080/java-auto-app/hello
```

<img width="601" height="79" alt="Screenshot 2026-01-16 at 04 15 54" src="https://github.com/user-attachments/assets/218eea52-c25e-4b85-97e0-d96ca963644e" />

Browser response

<img width="1010" height="595" alt="Screenshot 2026-01-16 at 03 33 02" src="https://github.com/user-attachments/assets/f791d415-8dde-463e-ad62-07bfef37ac99" />


### **What We Achieved**

- Fully automated CI/CD pipeline

- WAR-based Java application deployment

- Secure server-to-server deployment

- No manual SSH during deployment

- Immediate feedback via Slack

- Infrastructure and configuration fully reproducible


