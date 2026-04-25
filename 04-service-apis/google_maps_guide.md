---
title: Google Maps Guide
tags: [api, google, maps]
type: guide
status: stable
created: 2026-04-25
---

# Google Maps Guide

คู่มือการใช้ Google Maps API ใน web application แบ่งเป็น 2 ประเภทหลัก

| ประเภท | ใช้เมื่อ |
|--------|---------|
| **Dynamic Map** | ต้องการ interactive map เช่น drag, zoom, click marker |
| **Static Map** | ต้องการแสดงแผนที่เป็นภาพเฉยๆ ไม่มี interaction |

## Prerequisites

- Google Maps API Key พร้อมใช้งาน
- เปิดใช้ **Maps JavaScript API** (สำหรับ Dynamic)
- เปิดใช้ **Maps Static API** (สำหรับ Static)

---

## Dynamic Map

ใช้ Maps JavaScript API แสดงแผนที่แบบ interactive

### References

> ⛔ ห้ามลบเด็ดขาด — แหล่งที่มาของ code ในส่วนนี้

- **Simple Markers example (Official):** https://developers.google.com/maps/documentation/javascript/examples/marker-simple
- **JSFiddle sandbox:** https://jsfiddle.net/u80qd3nm/23/

### Example: Simple Marker

```js
/**
 * @license
 * Copyright 2019 Google LLC. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */
let map;

async function initMap() {
  const position = { lat: <LATITUDE>, lng: <LONGITUDE> };

  const { Map } = await google.maps.importLibrary("maps");
  const { AdvancedMarkerElement } = await google.maps.importLibrary("marker");

  map = new Map(document.getElementById("map"), {
    zoom: 16,
    center: position,
    mapId: "DEMO_MAP_ID",
  });

  const marker = new AdvancedMarkerElement({
    map: map,
    position: position,
    title: "<MARKER_TITLE>",
  });
}

initMap();
```

---

## Static Map

แสดงแผนที่เป็น `<img>` tag ไม่มี interaction เหมาะกับ React

> **หมายเหตุ:** `google-map-react` ใช้ Maps JavaScript API ไม่ใช่ Maps Static API
> ถ้าต้องการ static map ใน React ให้ใช้ Maps Static API URL ใน `src` ของ `<img>` โดยตรง

### References

> ⛔ ห้ามลบเด็ดขาด — แหล่งที่มาของ code ในส่วนนี้

- **Stack Overflow — Static map กับ google-map-react:** https://stackoverflow.com/questions/66876496/how-i-can-make-a-static-map-with-google-map-react-in-react
- **react-static-google-map (GitHub):** https://github.com/bondz/react-static-google-map

### วิธีที่ 1: Maps Static API URL ใน img tag

```jsx
import React from "react";

function App() {
  return (
    <div>
      <h1>Static Maps Sample</h1>
      <img src="https://maps.googleapis.com/maps/api/staticmap?center=Brooklyn+Bridge,New+York,NY&zoom=13&size=600x300&maptype=roadmap&markers=color:blue%7Clabel:S%7C40.702147,-74.015794&key=<YOUR_API_KEY>" />
    </div>
  );
}
```

### วิธีที่ 2: react-static-google-map library

```bash
yarn add react-static-google-map
```

```jsx
import { StaticGoogleMap, Marker, Path } from 'react-static-google-map';

// Single marker
<StaticGoogleMap size="600x600" apiKey="<YOUR_API_KEY>">
  <Marker location="<LATITUDE>,<LONGITUDE>" color="blue" label="P" />
</StaticGoogleMap>

// Multiple markers
<StaticGoogleMap size="600x600" apiKey="<YOUR_API_KEY>">
  <Marker.Group label="T" color="brown">
    <Marker location="<LAT_1>,<LNG_1>" />
    <Marker location="<LAT_2>,<LNG_2>" />
  </Marker.Group>
</StaticGoogleMap>

// Marker + Path
<StaticGoogleMap size="600x600" apiKey="<YOUR_API_KEY>">
  <Marker location={{ lat: <LATITUDE>, lng: <LONGITUDE> }} color="blue" label="P" />
  <Path
    points={[
      '<LAT_1>,<LNG_1>',
      '<LAT_2>,<LNG_2>',
      '<LAT_3>,<LNG_3>',
    ]}
  />
</StaticGoogleMap>
```

### Rendered Output ตัวอย่าง

**Single marker**
```html
<img src="https://maps.googleapis.com/maps/api/staticmap?size=600x600&scale=1&format=png&maptype=roadmap&markers=size:normal%7Ccolor:blue%7Clabel:P%7C6.4488387,3.5496361&key=YOUR_API_KEY">
```

**Multiple markers**
```html
<img src="https://maps.googleapis.com/maps/api/staticmap?size=600x600&scale=1&format=png&maptype=roadmap&markers=size:normal%7Ccolor:brown%7Clabel:T%7C40.737102,-73.990318%7C40.749825,-73.987963&key=YOUR_API_KEY">
```

**Marker + Path**
```html
<img src="https://maps.googleapis.com/maps/api/staticmap?size=600x600&scale=1&format=png&maptype=roadmap&markers=size:normal%7Ccolor:blue%7Clabel:P%7C40.737102,-73.990318&path=weight:5%7C40.737102,-73.990318%7C40.749825,-73.987963%7C40.752946,-73.987384%7C40.755823,-73.986397&key=YOUR_API_KEY">
```