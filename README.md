# Cloudera & Watsonx.ai Demo

## Use Case
TODO
## Design
![image](https://github.com/agupta-git/cloudera_watsonx/assets/2523891/55df9922-0675-424b-9494-d5afcd7392ae)

## Implementation
### Prerequisites
- A Cloudera Data Platform (CDP) Public Cloud environment on Amazon Web Services (AWS). If you don't have an existing environment, follow instructions here to set one up - [CDP/AWS Quick Start Guide](https://docs.cloudera.com/cdp-public-cloud/cloud/aws-quickstart/topics/mc-aws-quickstart.html).
- [IBM Cloud account](https://www.ibm.com/cloud).
- Get IBM's IAM Token
  1. Create IBM API Key [here](https://cloud.ibm.com/iam/apikeys).
  2. Get Token - ```curl -X POST 'https://iam.cloud.ibm.com/identity/token' -H 'Content-Type: application/x-www-form-urlencoded' -d 'grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=_<YOUR_API_KEY>_'```
---
### Step #1 - Cloudera DataFlow (CDF)
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
    > Note that this token expires every hour.
- Extra Small NiFi node size is enough for this data ingestion.
- After deployment is done, you would be able to see the flow in Dashboard.
- All NiFi Flow parameters can be updated while the flow is running, from Deployment Manager. As soon as you Apply Changes, running processors that are impacted by the Parameter changes will automatically be restarted.

![image](/assets/NiFi_1.png)

![image](/assets/NiFi_2.png)

---
### Step #2 - Cloudera Data Warehouse (CDW)

---
