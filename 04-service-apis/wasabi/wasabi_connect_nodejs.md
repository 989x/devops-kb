---
title: "Connect to Wasabi — SDK Examples"
tags: [wasabi, s3, nodejs, java, python, sdk, connection]
type: guide
status: stable
created: 2025-04-25
related:
  - "[[ts_connect]]"
  - "[[wasabi_guideline]]"
  - "[[wasabi_policy]]"
---

# Connect to Wasabi — SDK Examples

รวม code examples การเชื่อมต่อ Wasabi S3-compatible storage ผ่าน AWS SDK หลาย runtime

## Prerequisites

- มี Wasabi Access Key และ Secret Key พร้อมใช้งาน
- ทราบ endpoint และ region ของ bucket ที่ต้องการเชื่อมต่อ (ดู [[wasabi_guideline]])
- ติดตั้ง AWS SDK ตาม runtime ที่ใช้งาน

## Steps

### Node.js — AWS SDK v3 (@aws-sdk/client-s3)

> Source: [How to set credentials in AWS SDK v3 JavaScript](https://stackoverflow.com/questions/68264237/how-to-set-credentials-in-aws-sdk-v3-javascript) · [How to upload file into Wasabi bucket with s3 api with node.js](https://stackoverflow.com/questions/58622647/how-to-upload-file-into-wasabi-bucket-with-s3-api-with-node-js)

ใช้ `S3Client` พร้อม `credentials` และ `endpoint` ชี้ไปที่ Wasabi

```js
const { S3Client, GetObjectCommand } = require("@aws-sdk/client-s3");

const client = new S3Client({
  region: "<REGION>",
  credentials: {
    accessKeyId: "<ACCESS_KEY>",
    secretAccessKey: "<SECRET_KEY>"
  },
  endpoint: {
    url: "https://s3.<REGION>.wasabisys.com"
  }
});

(async () => {
  const response = await client.send(
    new GetObjectCommand({ Bucket: "<BUCKET_NAME>", Key: "<OBJECT_KEY>" })
  );
  console.log(response);
})();
```

### Node.js — AWS SDK v2 (aws-sdk)

> Source: [Wasabi Hot Storage: Pros/Cons and how to use it with Javascript](https://itnext.io/wasabi-pros-cons-and-how-to-use-with-javascript-fa528c3779a2)

```js
var AWS = require('aws-sdk');

var wasabiEndpoint = new AWS.Endpoint('s3.wasabisys.com');
var s3 = new AWS.S3({
  endpoint: wasabiEndpoint,
  accessKeyId: "<ACCESS_KEY>",
  secretAccessKey: "<SECRET_KEY>"
});
```

### Java — AWS SDK v2

> Source: [How do you configure the endpoint for Amazon S3 by using the AWS SDK V2?](https://stackoverflow.com/questions/68005239/how-do-you-configure-the-endpoint-for-amazon-s3-by-using-the-aws-sdk-v2)

ใช้ `endpointOverride` ใน builder เพื่อชี้ไปที่ Wasabi endpoint

```java
URI myURI = new URI("<WASABI_ENDPOINT>");

Region region = Region.US_EAST_1;
S3Client s3 = S3Client.builder()
    .region(region)
    .endpointOverride(myURI)
    .build();
```

### Python — boto3

> Source: [The AWS Access Key Id you provided does not exist in our records](https://stackoverflow.com/questions/68415772/the-aws-access-key-id-you-provided-does-not-exist-in-our-records-aws)

```python
import boto3

s3 = boto3.client(
  's3',
  endpoint_url='https://s3.<REGION>.wasabisys.com',
  aws_access_key_id="<ACCESS_KEY>",
  aws_secret_access_key="<SECRET_KEY>"
)

s3.put_object(Body="<FILE_PATH>", Bucket="<BUCKET_NAME>", Key="<OBJECT_KEY>")
```

> **หมายเหตุ:** `endpoint_url` ต้องระบุ region ให้ตรงกับ bucket เสมอ เช่น `us-east-1`, `us-east-2`  
> การใช้ `https://s3.wasabisys.com` โดยไม่ระบุ region อาจทำให้เกิด `InvalidAccessKeyId` error

## Troubleshooting

ดู [[ts_connect_endpoint]]

## References

- [AWS SDK v3 — S3Client credentials](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/clients/client-s3/modules/credentials.html)
- [AWS SDK v2 — endpointOverride (Java)](https://sdk.amazonaws.com/java/api/latest/software/amazon/awssdk/core/client/builder/SdkClientBuilder.html#endpointOverride-java.net.URI-)