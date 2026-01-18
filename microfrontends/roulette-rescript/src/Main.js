"use strict";

export function fetchJson(url, bodyDict, method) {
  var bodyObj = {};
  Object.keys(bodyDict).forEach(function (k) {
    bodyObj[k] = bodyDict[k];
  });
  return fetch(url, {
    method: method || "POST",
    credentials: "include",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(bodyObj)
  }).then(function (res) {
    return res.text();
  });
}
