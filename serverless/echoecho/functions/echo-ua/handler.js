'use strict';

module.exports.handler = function(event, context, cb) {
  console.log("event:", event);
  console.log("context:", context);

  return cb(null, {
    message: 'Go Serverless! Your Lambda function executed successfully!'
  });
};
