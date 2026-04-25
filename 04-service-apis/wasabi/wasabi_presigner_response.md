---
title: "Wasabi Presigner — Expected Response"
tags: [wasabi, presigner, s3, signed-url, response]
type: reference
status: stable
created: 2026-04-25
related:
  - "[[wasabi_presigner_guide]]"
  - "[[wasabi_connect_nodejs]]"
---

# Wasabi Presigner — Expected Response

ตัวอย่าง output ที่ควรเห็นเมื่อ presigner workflow ทำงานสำเร็จ

---

## Upload Flow Output

Console log ตั้งแต่ fileFilter จนถึง upload สำเร็จ

```
fileFilter started

request files:  [
  {
    fieldname: 'images',
    originalname: 'unnamed.jpeg',
    encoding: '7bit',
    mimetype: 'image/jpeg',
    buffer: <Buffer ff d8 ff e0 00 10 4a 46 49 46 00 01 01 00 00 01 00 01 00 00 ff e1 00 2a 45 78 69 66 00 00 49 49 2a 00 08 00 00 00 01 00 31 01 02 00 07 00 00 00 1a 00 ... 21905 more bytes>,
    size: 21955
  }
]

Signed URL for Image:  https://<BUCKET_NAME>.s3.<REGION>.wasabisys.com/<IMAGE_KEY>.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=<ACCESS_KEY>%2F<REGION>%2Fs3%2Faws4_request&X-Amz-Date=<TIMESTAMP>&X-Amz-Expires=900&X-Amz-Signature=<SIGNATURE>&X-Amz-SignedHeaders=host&x-id=GetObject
[7/20/2023, 3:06:25 PM] [INFO] Result - METHOD: [POST] - URL: [/upload-multiple] - IP: [::1] - STATUS: [200]
uploadToWasabi response:  {
  '$metadata': {
    httpStatusCode: 200,
    requestId: '<REQUEST_ID>',
    extendedRequestId: '<EXTENDED_REQUEST_ID>',
    cfId: undefined,
    attempts: 1,
    totalRetryDelay: 0
  },
  ETag: '"<ETAG>"'
}

uploaded image url undefined
```

---

## Signed URL Format

ตัวอย่าง signed URL ที่ได้จาก `s3-request-presigner`

```
https://<BUCKET_NAME>.s3.<REGION>.wasabisys.com/<IMAGE_KEY>.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=<ACCESS_KEY>%2F<DATE>%2F<REGION>%2Fs3%2Faws4_request&X-Amz-Date=<TIMESTAMP>&X-Amz-Expires=900&X-Amz-Signature=<SIGNATURE>&X-Amz-SignedHeaders=host&x-id=GetObject
```

URL รูปแบบอื่นที่เข้าถึง object เดียวกัน

```
# web URL
https://s3.<REGION>.wasabisys.com/<BUCKET_NAME>/<IMAGE_KEY>.jpg

# imageUrl (virtual-hosted style)
https://<BUCKET_NAME>.s3.<REGION>.wasabisys.com/<IMAGE_KEY>.jpg
```

---

## getObjectCommand Response

Response object เต็มที่ได้จาก `GetObjectCommand`

```bash
getObjectCommand response:  {
  '$metadata': {
    httpStatusCode: 200,
    requestId: '<REQUEST_ID>',
    extendedRequestId: '<EXTENDED_REQUEST_ID>',
    ...
  },
  AcceptRanges: 'bytes',
  LastModified: 2023-07-20T13:53:37.000Z,
  ContentLength: 21955,
  ETag: '"<ETAG>"',
  ContentType: 'application/octet-stream',
  Metadata: {},
  Body: <ref *1> IncomingMessage {
    _readableState: ReadableState {
      ...
      buffer: BufferList { head: [Object], tail: [Object], length: 1 },
      length: 3145,
      ...
    },
    _events: [Object: null prototype] { end: [Function: responseOnEnd] },
    ...
    socket: TLSSocket {
      _tlsOptions: [Object],
      ...
      servername: '<BUCKET_NAME>.s3.<REGION>.wasabisys.com',
      ...
      _host: '<BUCKET_NAME>.s3.<REGION>.wasabisys.com',
      ...
      server: undefined,
      ...
      [Symbol(connect-options)]: [Object]
    },
    httpVersionMajor: 1,
    ...
    url: '',
    method: null,
    statusCode: 200,
    statusMessage: 'OK',
    client: TLSSocket {
      _tlsOptions: [Object],
      ...
      servername: '<BUCKET_NAME>.s3.<REGION>.wasabisys.com',
      ...
      _host: '<BUCKET_NAME>.s3.<REGION>.wasabisys.com',
      ...
      [Symbol(connect-options)]: [Object]
    },
    _consuming: false,
    _dumped: false,
    req: ClientRequest {
      _events: [Object: null prototype],
      ...
      socket: [TLSSocket],
      _header: 'GET /<IMAGE_KEY>.jpg?x-id=GetObject HTTP/1.1\r\n' +
        'host: <BUCKET_NAME>.s3.<REGION>.wasabisys.com\r\n' +
        'x-amz-user-agent: aws-sdk-js/3.370.0\r\n' +
        'user-agent: aws-sdk-js/3.370.0 ua/2.0 os/darwin#19.6.0 lang/js md/nodejs#18.12.1 api/s3#3.370.0\r\n' +
        'amz-sdk-invocation-id: <INVOCATION_ID>\r\n' +
        'amz-sdk-request: attempt=1; max=3\r\n' +
        'x-amz-date: <TIMESTAMP>\r\n' +
        'x-amz-content-sha256: <CONTENT_SHA256>\r\n' +
        'authorization: AWS4-HMAC-SHA256 Credential=<ACCESS_KEY>/<DATE>/<REGION>/s3/aws4_request, SignedHeaders=amz-sdk-invocation-id;amz-sdk-request;host;x-amz-content-sha256;x-amz-date;x-amz-user-agent, Signature=<SIGNATURE>\r\n' +
        'Connection: keep-alive\r\n' +
        '\r\n',
      _keepAliveTimeout: 0,
      ...
      socketPath: undefined,
      method: 'GET',
      ...
      path: '/<IMAGE_KEY>.jpg?x-id=GetObject',
      ...
      host: '<BUCKET_NAME>.s3.<REGION>.wasabisys.com',
      protocol: 'https:',
      ...
    },
    transformToByteArray: [AsyncFunction: transformToByteArray],
    [Symbol(kHeaders)]: {
      'accept-ranges': 'bytes',
      'content-length': '21955',
      'content-type': 'application/octet-stream',
      date: 'Thu, 20 Jul 2023 13:53:37 GMT',
      etag: '"<ETAG>"',
      'last-modified': 'Thu, 20 Jul 2023 13:53:37 GMT',
      server: 'WasabiS3/7.14.311-2023-06-21-10defea71f (head18)',
      'x-amz-id-2': '<EXTENDED_REQUEST_ID>',
      'x-amz-request-id': '<REQUEST_ID>'
    },
    ...
  }
}
```