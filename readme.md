# Sentiment & Entity Analyzer Dashboard

[![AWS](https://img.shields.io/badge/AWS-Serverless-orange?style=flat)](https://aws.amazon.com/)
[![Next.js](https://img.shields.io/badge/Next.js-Frontend-blue?style=flat)](https://nextjs.org/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat)](LICENSE)

A web application to upload text files, analyze their **sentiment** and **entities** using **AWS Comprehend**, and visualize results in a friendly dashboard. Built with **Next.js**, **AWS Lambda**, **API Gateway**, **S3**, and **DynamoDB**.

---
<img width="1024" height="1024" alt="k2gwiloupnjffrdwdwal" src="https://github.com/user-attachments/assets/ce1ded61-89b6-45d3-b532-fec9d14ae688" />

## 🚀 Features

- Upload `.txt` files directly from your browser
- Analyze **sentiment** (Positive, Negative, Neutral, Mixed)
- Detect **entities** (people, organizations, locations, etc.)
- Store results in **DynamoDB**
- Serverless architecture with minimal infrastructure management
- Local frontend testing with CORS enabled

---

## 🏗️ Architecture

[Frontend - Next.js]
|
v
[API Gateway - HTTP API]
|
v
[Lambda Function (Python)]

Upload file to S3

Analyze text using AWS Comprehend

Store results in DynamoDB
|
v
[DynamoDB / S3]

---

## ⚙️ Tech Stack

- **Frontend**: Next.js, React, Axios  
- **Backend**: AWS Lambda (Python 3.11)  
- **AWS Services**: API Gateway, Lambda, S3, DynamoDB, Comprehend  
- **Infrastructure as Code**: Terraform  

---

## 📝 Setup

1. **Clone the repository**

bash
git clone https://github.com/your-username/sentiment-dashboard.git
cd sentiment-dashboard
Configure environment variables

Create a .env.local file in the root:

bash
Copy code
NEXT_PUBLIC_API_URL=https://<your-api-id>.execute-api.us-west-2.amazonaws.com/$default/upload
Install dependencies and run the frontend

bash
Copy code
npm install
npm run dev
Open the app
Visit http://localhost:3000 and upload a .txt file.

📂 Sample File for Testing
Create a file.txt with this content:

pgsql
Copy code
Apple Inc. announced the launch of their new iPhone in California yesterday.
Many customers are excited and eagerly waiting in lines, hoping to get the latest model.
However, some tech critics argue that the phone is overpriced and lacks innovative features.
Microsoft released a major update to Windows, which received mixed reviews from users.
Elon Musk commented on Twitter that AI advancements are progressing faster than expected.
🎨 User Interface
Entities are listed with their type (e.g., Revolution (TITLE)).

Sentiment is visualized with a chart component.

Error handling and feedback for failed uploads.

🔧 Terraform Files
lambda.tf: IAM roles, Lambda function, S3 permissions

api.tf: API Gateway setup with CORS, Lambda integration, and routes
<img width="1918" height="919" alt="serverless sentiment" src="https://github.com/user-attachments/assets/070e8c4a-fefa-4d85-8ca4-d3d7eec0b8e7" />

✅ License
This project is licensed under the MIT License.

💡 Notes
Ensure the API Gateway endpoint matches .env.local.

CORS must be enabled in Lambda responses for local development.

AWS credentials must allow Lambda, S3, DynamoDB, and Comprehend access.
