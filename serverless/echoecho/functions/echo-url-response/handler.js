'use strict';
var http = require ('http');

module.exports.handler = (event, context, cb) => {
  console.log("event:", event);
  console.log("context:", context);

  if (!event.queryParameters.url) {
    return cb(null, {
      message: 'No queryParameters `url`'
    });
  }

  http.get(event.queryParameters.url, (res) => {
    console.log("Got response: " + res.statusCode);
    let body = '';
    res.setEncoding('utf8');

    res.on('data', (chunk) => {
      body += chunk;
    });

    res.on('end', (res) => {
      return cb(null, body);
    });
  }).on('error', function(e) {
    return cb(e);
  });
  
};
