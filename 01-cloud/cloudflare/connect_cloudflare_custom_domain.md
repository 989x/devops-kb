---
title: "Custom Domains"
tags:
  - cloudflare
  - workers
  - dns
  - routing
type: reference
status: stable
created: 2026-05-02
related: []
---

## Background

Custom Domains ช่วยให้เชื่อมต่อ Worker กับ domain หรือ subdomain ได้โดยไม่ต้องปรับ DNS settings หรือจัดการ certificate เอง เมื่อตั้งค่า Custom Domain แล้ว Cloudflare จะสร้าง DNS records และออก certificate ให้โดยอัตโนมัติ โดย DNS records ที่สร้างขึ้นจะชี้ตรงไปยัง Worker ต่างจาก [Routes](https://developers.cloudflare.com/workers/configuration/routing/routes/#set-up-a-route) ที่ Custom Domains จะส่ง traffic ทุก path ของ domain หรือ subdomain ไปยัง Worker

Custom Domains คือ route ที่ผูกกับ domain หรือ subdomain (เช่น `example.com` หรือ `shop.example.com`) ภายใน Cloudflare zone โดยให้ Worker เป็น origin

แนะนำให้ใช้ Custom Domains เมื่อต้องการเชื่อมต่อ Worker กับ Internet โดยไม่มี application server ที่ต้องติดต่อตลอดเวลา หากมี external dependencies สามารถสร้าง `Request` object พร้อม target URI แล้วใช้ `fetch()` เรียกออกไปได้

Custom Domains สามารถซ้อนกันได้ เช่น Worker A ผูกกับ `app.example.com` และ Worker B ผูกกับ `api.example.com` Worker A สามารถเรียก `fetch()` ไปที่ `api.example.com` เพื่อ invoke Worker B ได้

![Custom Domains can stack on top of each other, like any external dependencies](https://developers.cloudflare.com/_astro/custom-domains-subrequest.C6c84jN5_1oQWRD.webp)

นอกจากนี้ Custom Domains ยังสามารถถูก invoke ภายใน zone เดียวกันผ่าน `fetch()` ได้ ต่างจาก Routes

## Add a Custom Domain

ก่อนเพิ่ม Custom Domain ต้องมีสิ่งต่อไปนี้:

1. [Active Cloudflare zone](https://developers.cloudflare.com/dns/zone-setups/)
2. Worker ที่ต้องการ invoke

สามารถผูก Custom Domain กับ Worker ได้ผ่าน Cloudflare dashboard, [Wrangler](https://developers.cloudflare.com/workers/configuration/routing/custom-domains/#set-up-a-custom-domain-in-your-wrangler-configuration-file) หรือ [API](https://developers.cloudflare.com/api/resources/workers/subresources/domains/methods/list/)

### Set up a Custom Domain in the dashboard

ขั้นตอนการตั้งค่าผ่าน dashboard:

1. เปิด Cloudflare dashboard ไปที่หน้า **Workers & Pages**
	[Go to **Workers & Pages**](https://dash.cloudflare.com/?to=/:account/workers-and-pages)
2. ใน **Overview** เลือก Worker ที่ต้องการ
3. ไปที่ **Settings** > **Domains & Routes** > **Add** > **Custom Domain**
4. กรอก domain ที่ต้องการผูกกับ Worker
5. กด **Add Custom Domain**

หลังเพิ่ม domain หรือ subdomain แล้ว Cloudflare จะสร้าง DNS record ให้อัตโนมัติ สามารถเพิ่มได้หลาย Custom Domain

### Set up a Custom Domain in your Wrangler configuration file

ในการตั้งค่าผ่าน [Wrangler configuration file](https://developers.cloudflare.com/workers/wrangler/configuration/) ให้เพิ่ม option `custom_domain=true` ในแต่ละ pattern ภายใต้ `routes` ตัวอย่างการตั้งค่า Custom Domain เดียว:

- [wrangler.jsonc](#tab-panel-8594)
- [wrangler.toml](#tab-panel-8595)

```jsonc
{
  "routes": [
    {
      "pattern": "shop.example.com",
      "custom_domain": true
    }
  ]
}
```

ตัวอย่างการตั้งค่าหลาย Custom Domains:

- [wrangler.jsonc](#tab-panel-8598)
- [wrangler.toml](#tab-panel-8599)

```jsonc
{
  "routes": [
    {
      "pattern": "shop.example.com",
      "custom_domain": true
    },
    {
      "pattern": "shop-two.example.com",
      "custom_domain": true
    }
  ]
}
```

## Worker to Worker communication

ใน zone เดียวกัน หาก Worker ต้องการติดต่อกับ Worker อื่นที่รันบน [route](https://developers.cloudflare.com/workers/configuration/routing/routes/#set-up-a-route) หรือ subdomain [`workers.dev`](https://developers.cloudflare.com/workers/configuration/routing/routes/#_top) วิธีเดียวที่ทำได้คือผ่าน [service bindings](https://developers.cloudflare.com/workers/runtime-apis/bindings/service-bindings/)

อย่างไรก็ตาม หาก Worker ปลายทางรันบน Custom Domain (ไม่ใช่ route) ข้อจำกัดนี้จะหมดไป — Fetch request ภายใน zone เดียวกันไปยัง Worker ที่รันบน Custom Domain จะสำเร็จโดยไม่ต้องมี service binding

ตัวอย่าง: Workers ทั้งสองรันอยู่บน `example.com` Cloudflare zone:

- `worker-a` รันบน [route](https://developers.cloudflare.com/workers/configuration/routing/routes/#set-up-a-route) `auth.example.com/*`
- `worker-b` รันบน [route](https://developers.cloudflare.com/workers/configuration/routing/routes/#set-up-a-route) `shop.example.com/*`

หาก `worker-a` ส่ง fetch request ไปหา `worker-b` จะ fail เพราะข้อจำกัดของ same-zone fetch — `worker-a` ต้องมี service binding กับ `worker-b` จึงจะทำงานได้

```js
export default {
  fetch(request) {
    // This will fail
    return fetch("https://shop.example.com")
  }
}
```

แต่หาก `worker-b` รันบน Custom Domain `shop.example.com` แทน fetch request จะสำเร็จได้ทันที

## Request matching behaviour

Custom Domains ไม่รองรับ [wildcard DNS records](https://developers.cloudflare.com/dns/manage-dns-records/reference/wildcard-dns-records/) — request ที่เข้ามาต้องตรงกับ domain หรือ subdomain ที่ลงทะเบียนไว้เท่านั้น ส่วนอื่นของ URL (path, query parameters) จะไม่ถูกนำมาพิจารณาในการ match เช่น หากสร้าง Custom Domain บน `api.example.com` ผูกกับ `api-gateway` Worker ทั้ง request ไปที่ `api.example.com/login` และ `api.example.com/user` จะ invoke `api-gateway` Worker เหมือนกัน

![Custom Domains follow standard DNS ordering and matching logic](https://developers.cloudflare.com/_astro/custom-domains-api-gateway.DmeJZDoL_Z1d0vv1.webp)

## Interaction with Routes

Worker ที่รันบน Custom Domain จะถูกมองเป็น origin — Workers ที่รันบน route ก่อนหน้า Custom Domain สามารถเรียก Worker นั้นได้ด้วย `fetch(request)` พร้อม `Request` object ที่รับเข้ามา ซึ่งหมายความว่าสามารถตั้ง Worker ให้ทำงานก่อน request จะถึง Custom Domain Worker ได้ หรือพูดอีกแบบคือสามารถเชื่อม Workers สองตัวไว้ใน request เดียวกันได้

ตัวอย่าง workflow:

1. Custom Domain `api.example.com` ชี้ไปยัง `api-worker`
2. Route `api.example.com/auth` ชี้ไปยัง `auth-worker`
3. Request ไปที่ `api.example.com/auth` จะ trigger `auth-worker`
4. การเรียก `fetch(request)` ภายใน `auth-worker` จะ invoke `api-worker` ต่อ ราวกับเป็น application server ปกติ

```js
export default {
  fetch(request) {
    const url = new URL(request.url)
    if(url.searchParams.get("auth") !== "SECRET_TOKEN") {
      return new Response(null, { status: 401 })
    } else {
      // This will invoke `api-worker`
      return fetch(request)
    }
  }
}
```

## Certificates

การสร้าง Custom Domain จะสร้าง [Advanced Certificate](https://developers.cloudflare.com/ssl/edge-certificates/advanced-certificate-manager/) ให้อัตโนมัติบน target zone สำหรับ hostname ที่กำหนด

Certificate ที่สร้างจะใช้ค่า default — หากต้องการปรับแต่ง ให้ลบ certificate ที่สร้างขึ้นแล้วสร้างใหม่เองใน Cloudflare dashboard ดูรายละเอียดได้ที่ [Manage advanced certificates](https://developers.cloudflare.com/ssl/edge-certificates/advanced-certificate-manager/manage-certificates/)

## Redirect between www and root domain

เนื่องจาก Custom Domains ต้องการ hostname ที่ตรงกันทุกประการ Worker ที่ผูกกับ `example.com` จะไม่รับ request ที่ส่งมาที่ `www.example.com` และในทางกลับกัน เพื่อให้ domain ทั้งสองรูปแบบทำงานได้ ให้ตั้ง redirect rule:

- [Redirect from www to root](https://developers.cloudflare.com/rules/url-forwarding/examples/redirect-www-to-root/)
- [Redirect from root to www](https://developers.cloudflare.com/rules/url-forwarding/examples/redirect-root-to-www/)

นอกจากนี้ยังต้องมี [proxied DNS record](https://developers.cloudflare.com/dns/manage-dns-records/how-to/create-dns-records/) สำหรับ hostname ที่ redirect *จาก* เพื่อให้ Cloudflare สามารถ apply redirect rule ได้:

- For www to root: เพิ่ม proxied DNS `A` record สำหรับ `www` ชี้ไปที่ `192.0.2.0` หรือ proxied `AAAA` record ชี้ไปที่ `100::`
- For root to www: เพิ่ม proxied DNS `A` record สำหรับ root domain ชี้ไปที่ `192.0.2.0` หรือ proxied `AAAA` record ชี้ไปที่ `100::`

## Migrate from Routes

หากใช้งาน Worker ผ่าน [route](https://developers.cloudflare.com/workers/configuration/routing/routes/) แบบ `/*` และมี CNAME record ชี้ไปที่ `100::` หรือคล้ายกัน แนะนำให้ย้ายมาใช้ Custom Domain แทน

### Migrate from Routes via the dashboard

ขั้นตอน migrate route `example.com/*`:

1. เปิด Cloudflare dashboard ไปที่หน้า **DNS Records** ของ domain
	[Go to **Records**](https://dash.cloudflare.com/?to=/:account/:zone/dns/records)
2. ลบ CNAME record ของ `example.com`
3. ไปที่ **Account Home** > **Workers & Pages**
4. ใน **Overview** เลือก Worker > **Settings** > **Domains & Routes**
5. กด **Add** > **Custom domain** แล้วเพิ่ม `example.com`
6. ลบ route `example.com/*` ที่ Worker > **Settings** > **Domains & Routes**

### Migrate from Routes via Wrangler

ขั้นตอน migrate route `example.com/*` ผ่าน [Wrangler configuration file](https://developers.cloudflare.com/workers/wrangler/configuration/):

1. เปิด Cloudflare dashboard ไปที่หน้า **DNS Records** ของ domain
	[Go to **Records**](https://dash.cloudflare.com/?to=/:account/:zone/dns/records)
2. ลบ CNAME record ของ `example.com`
3. เพิ่ม config ต่อไปนี้ใน Wrangler file:
	- [wrangler.jsonc](#tab-panel-8596)
	- [wrangler.toml](#tab-panel-8597)
	```jsonc
	{
	  "routes": [
	    {
	      "pattern": "example.com",
	      "custom_domain": true
	    }
	  ]
	}
	```
4. รัน `npx wrangler deploy` เพื่อสร้าง Custom Domain ให้ Worker

## References

- [Custom Domains — Cloudflare Workers Docs](https://developers.cloudflare.com/workers/configuration/routing/custom-domains/)
- [Cloudflare Zone Setup](https://developers.cloudflare.com/dns/zone-setups/)
- [Wrangler Configuration](https://developers.cloudflare.com/workers/wrangler/configuration/)
- [Service Bindings](https://developers.cloudflare.com/workers/runtime-apis/bindings/service-bindings/)
- [Advanced Certificate Manager](https://developers.cloudflare.com/ssl/edge-certificates/advanced-certificate-manager/)
- [Wildcard DNS Records](https://developers.cloudflare.com/dns/manage-dns-records/reference/wildcard-dns-records/)
- [Workers API — Domains](https://developers.cloudflare.com/api/resources/workers/subresources/domains/methods/list/)