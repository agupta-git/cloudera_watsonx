# Processing real-time unstructured data with GenAI using Cloudera and IBM watsonx.ai

## Overview
Cloudera and IBM have partnered to create an industry-leading, enterprise-grade data and AI services using open source ecosystems — all designed to achieve faster data and analytics at scale.

The purpose of this article is to showcase a reusable data pipeline using Cloudera's [DataFlow](https://www.cloudera.com/products/dataflow.html) & [Data Warehouse](https://www.cloudera.com/products/data-warehouse.html), and IBM's [watsonx.ai](https://www.ibm.com/products/watsonx-ai).

## Design
![image](https://github.com/agupta-git/cloudera_watsonx/assets/2523891/7e73114b-6e09-492e-84fa-5789da47ebed)

**Design Explanation:**
- Based on the incoming documents in AWS S3 bucket, NiFi prepares the input for all the watsonx.ai models.
- NiFi calls watsonx.ai model (granite-13b-instruct-v1) to Extract the key fields in the document. See the sample IBM watsonx.ai prompt below.

  ![image](/assets/watsonx_extract.png)
  
- NiFi calls watsonx.ai model (granite-13b-chat-v1) to Summarize the information in the document. See the sample IBM watsonx.ai prompt below.

  ![image](/assets/watsonx_summary.png)

- NiFi calls watsonx.ai model (granite-13b-instruct-v1) to generate an Email with all the necessary information, for the user who submitted the document. See the sample IBM watsonx.ai prompt below.

  ![image](/assets/watsonx_email.png)
  
- Using the generated response, NiFi prepares and sends an email to the user.
- NiFi stores all the responses from the model invocations in AWS S3 bucket, which are eventually read by the Hive table in Data Warehouse.

## Implementation
### Prerequisites
- A Cloudera Data Platform (CDP) Public Cloud environment on Amazon Web Services (AWS). If you don't have an existing environment, follow instructions here to set one up - [CDP/AWS Quick Start Guide](https://docs.cloudera.com/cdp-public-cloud/cloud/aws-quickstart/topics/mc-aws-quickstart.html).
- [IBM Cloud account](https://www.ibm.com/cloud).
- Get IAM Token from IBM
  1. Create IBM API Key [here](https://cloud.ibm.com/iam/apikeys).
  2. Get Token - ```curl -X POST 'https://iam.cloud.ibm.com/identity/token' -H 'Content-Type: application/x-www-form-urlencoded' -d 'grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=_<YOUR_API_KEY>_'```
     > Note that this token expires in one hour.
---
### Step #1 - Setup Cloudera DataFlow (CDF)
- Go to CDF user interface, and ensure CDF service is enabled in your CDP environment.
- In Catalog, import the following flow definition - [Cloudera_Watsonx_Flow.json](/Cloudera_Watsonx_Flow.json)
- Select imported flow, click on Deploy, select the Target Environment and begin the deployment process.
- During the deployment, it's going to ask about the following parameters that this NiFi Flow requires to function:
  - **s3_access_key** - Ensure that AWS IAM user you're using, has "AmazonS3FullAccess" permissions. Visit [Understanding and getting your AWS credentials](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html) for help if required.
  - **s3_secret_access_key** - same instructions as s3_access_key.
  - **s3_bucket** - AWS S3 bucket name. Eg: iceberg-presto.
  - **s3_input_path** - Subdirectory in AWS S3 bucket in which you're staging your input data. Eg: data/claim.
  - **s3_output_path** - Subdirectory in AWS S3 bucket in which you're storing your output data. Eg: data/watsonx_response.
  - **watsonx_model_url** - IBM Watsonx.ai model URL. Eg: https://us-south.ml.cloud.ibm.com/ml/v1-beta/generation/text?version=2023-05-29.
  - **watsonx_bearer_token** - IBM's IAM Token that you retrieved earlier in the prerequisites.
- Extra Small NiFi node size is enough for this data ingestion.
- After deployment is done, you would be able to see the flow in Dashboard.
- All NiFi Flow parameters can be updated while the flow is running, from Deployment Manager. As soon as you Apply Changes, running processors that are impacted by the Parameter changes will automatically be restarted.

![image](/assets/IMG-NiFi_1.png)

![image](/assets/IMG-NiFi_2.png)

---
### Step #2 - Setup Cloudera Data Warehouse (CDW)
- Go to CDW user interface. Ensure CDW service is activated in your CDP environment, and a Database Catalog & a Virtual Warehouse compute cluster are available for use.
- In Hue editor, execute [query.sql](/query.sql). This query creates an external table that points to your S3 Bucket's output path. **Please change AWS S3 location in the query before executing it.**
- After the query execution is successful, you will see ```model_response``` table under default database.

---
### Step #3 - Execute
1. Ensure your Cloudera Watsonx NiFi flow is started. If it's not, do the following to start it -- CDF Dashboard >> Deployment Manager >> Action >> Start Flow.
2. Drop files in your S3 Bucket's input path. A couple of sample input files are provided in ```assets``` directory for reference.

![image](/assets/IMG-S3_Input.png)

3. After a few seconds, notice the output in your S3 Bucket's output path.

![image](/assets/IMG-S3_Output.png)

4. You can also go in Hue and query the table - ```SELECT * FROM default.model_response;```.

![image](/assets/IMG-Hue_Output.png)

5. In the end, this NiFi flow sends out a notification email to the user.

![image](/assets/IMG-Email.png)

---
