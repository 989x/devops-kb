---
title: "Wasabi Upload File (PutObject)"
tags: [wasabi, s3, upload, putobject, javascript]
type: guide
status: stable
created: 2026-04-25
related:
  - "[[wasabi_connect_examples]]"
  - "[[wasabi_presigner_guide]]"
---

# Wasabi Upload File (PutObject)

ตัวอย่างการ upload file ขึ้น Wasabi bucket ด้วย `PutObjectCommand` ทั้ง AWS SDK v2 และ v3

---

## Prerequisites

- มี S3Client ที่ configured กับ Wasabi endpoint แล้ว → ดู `[[wasabi_connect_examples]]`
- มี bucket และ IAM policy ที่อนุญาต `s3:PutObject` → ดู `[[wasabi_policy]]`

---

## Steps

### Example 1 — AWS SDK v2 (`s3.upload`)

> Source: [Wasabi Hot Storage: Pros/Cons and how to use it with Javascript — itnext.io](https://itnext.io/wasabi-pros-cons-and-how-to-use-with-javascript-fa528c3779a2)

```js
// Full documentation: https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html#upload-property

var filePath = '/tmp/myFile.txt';
var params = {
    Bucket: bucketName,
    Key: path.basename(filePath),
    Body: fs.createReadStream(filePath)
};

var options = {
    partSize: 10 * 1024 * 1024, // 10 MB
    queueSize: 10
};

s3.upload(params, options, function (err, data) {
    if (!err) {
        console.log(data); // successful response
    } else {
        console.log(err); // an error occurred
    }
});
```

### Example 2 — AWS SDK v3 (`PutObjectCommand`)

> Source: [How to upload file into Wasabi bucket with s3 api with node.js? — Stack Overflow](https://stackoverflow.com/questions/58622647/how-to-upload-file-into-wasabi-bucket-with-s3-api-with-node-js)

```js
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3"

await client.send(new PutObjectCommand({
    Bucket: "<BUCKET_NAME>",
    Key: "object-key",
    Body: <whatever is being put>
}))
```