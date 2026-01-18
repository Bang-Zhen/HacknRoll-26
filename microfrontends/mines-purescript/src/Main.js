"use strict";

exports.postJson = function (url) {
  return function (body) {
    return function () {
      var xhr = new XMLHttpRequest();
      xhr.open("POST", url, false);
      xhr.withCredentials = true;
      xhr.setRequestHeader("Content-Type", "application/json");
      xhr.send(body);
      return xhr.responseText || "";
    };
  };
};
