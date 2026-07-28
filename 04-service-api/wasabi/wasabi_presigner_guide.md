---
title: "Wasabi Request Presigner"
tags: [wasabi, presigner, s3, signed-url, typescript]
type: guide
status: stable
created: 2026-04-25
related:
  - "[[wasabi_connect_nodejs]]"
  - "[[wasabi_guideline]]"
  - "[[wasabi_presigner_response]]"
---

# Wasabi Request Presigner

คู่มือการสร้าง Signed URL สำหรับเข้าถึง object ใน Wasabi โดยใช้ `@aws-sdk/s3-request-presigner`

---

## Prerequisites

- Node.js project ที่ติดตั้ง `@aws-sdk/client-s3` แล้ว → ดู [[wasabi_connect_nodejs]]
- Environment variables ต่อไปนี้ต้องมีใน `.env`

| Variable | ค่าที่ใส่ |
|----------|----------|
| `WASABI_BUCKET_NAME` | `<BUCKET_NAME>` |
| `WASABI_REGION` | `<REGION>` |
| `WASABI_ENDPOINT` | `<WASABI_ENDPOINT>` |
| `WASABI_ACCESS_KEY` | `<ACCESS_KEY>` |
| `WASABI_SECRET_KEY` | `<SECRET_KEY>` |

---

## Steps

### 1. Install Package

```bash
pnpm i @aws-sdk/s3-request-presigner
```

---

### 2. Setup S3Client และ findImageUrl (middleware)

สร้างไฟล์ middleware สำหรับ initialize S3Client และ export `findImageUrl`

```ts
import {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
  GetObjectRequest,
} from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

dotenv.config();

const bucketName = process.env.WASABI_BUCKET_NAME;
const wasabiRegion = process.env.WASABI_REGION;
const wasabiEndpoint = new URL(process.env.WASABI_ENDPOINT!); // Convert to URL type
const accessKeyId = process.env.WASABI_ACCESS_KEY;
const secretAccessKey = process.env.WASABI_SECRET_KEY;

export const client = new S3Client({
  credentials: {
    accessKeyId: accessKeyId!,
    secretAccessKey: secretAccessKey!,
  },
  endpoint: {
    url: wasabiEndpoint,
  },
  region: wasabiRegion,
});

export const findImageUrl = async (params: GetObjectRequest) => {
  try {
    const command = new GetObjectCommand(params);
    const signedUrl = await getSignedUrl(client, command, {
      expiresIn: 15 * 60, // 15 minutes
    });
    return signedUrl;
  } catch (err: any) {
    console.log("Error Genrating Signed URL: ", err);
    throw new Error(err?.message || "Error Generating Signed URL");
  }
};
```

---

### 3. ใช้งาน findImageUrl ใน Controller

ตัวอย่าง controller ที่รับไฟล์ upload แล้วสร้าง signed URL

```ts
import { generateImageID } from "../utils/id-generator";
import { uploadToWasabi, findImageUrl } from "../middlewares/wasabi";

const bucketName = process.env.WASABI_BUCKET_NAME;

const uploadImages = async (req: any, res: any) => {
  console.log("request files: ", req.files);

  if (req.files && req.files.length > 0) {
    for (let i = 0; i < req.files.length; i++) {
      const key = `${generateImageID()}.jpg`;

      uploadToWasabi(key, req.files[i].buffer).then((result) => {
        console.log("uploaded image url", result);
      });

      // Generate signed URL
      const params = { Bucket: bucketName, Key: key };
      const signedUrl = await findImageUrl(params);
      console.log("Signed URL for Image: ", signedUrl);
      // <SIGNED_URL_EXAMPLE>
    }
  }

  res.json({
    msg: `${req.files.length} Images uploaded successfully`,
  });
};

export default {
  uploadImages,
};
```

---

## Troubleshooting

### `getSignedUrl` ไม่ทำงานกับ TypeScript 4.9.5

**อาการ:** เรียก `getSignedUrl` แล้ว error หรือ type ไม่ตรง

**สาเหตุ:** ปัญหา compatibility ระหว่าง `@aws-sdk/s3-request-presigner` กับ TypeScript 4.9.5

**วิธีแก้:** ต้องสร้าง `S3Client` instance และส่งเข้าไปใน `getSignedUrl` โดยตรง ห้ามละไว้

Source: [getSignedUrl is not working with TypeScript 4.9.5 #4451 — aws-sdk-js-v3](https://github.com/aws/aws-sdk-js-v3/issues/4451)

```ts
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { GetObjectCommand, GetObjectRequest, S3Client } from "@aws-sdk/client-s3";

export const getsignedUrl = async (params: GetObjectRequest) => {
  try {
    const command = new GetObjectCommand(params);
    const client = new S3Client({
      region: process.env.WASABI_REGION,
    });
    const signedUrl = await getSignedUrl(client, command, { expiresIn: 15 * 60 });
    return signedUrl;
  } catch (err: any) {
    console.log("Error Genrating Signed URL: ", err);
    throw new Error(err?.message || "Error Generating Signed URL");
  }
};
```

---

## References

- [Storing Images in S3 from Node Server — Getting images with signed URL (30:03)](https://www.youtube.com/watch?v=eQAIojcArRY&t=1263s)
- [getSignedUrl is not working with TypeScript 4.9.5 #4451 — aws-sdk-js-v3](https://github.com/aws/aws-sdk-js-v3/issues/4451)