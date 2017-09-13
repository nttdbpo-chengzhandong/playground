'use strict';

const exec = require('node-exec-promise').exec;

module.exports.check = (event, context, callback) => {
    let cmd = [];
    cmd.push('export HOME=/tmp');
    cmd.push('curl -L -o /tmp/repo.zip "https://github.com/faultline/faultline/archive/master.zip"');
    cmd.push('unzip /tmp/repo.zip -d /tmp/src');
    cmd.push('cd /tmp/src/faultline-master');
    cmd.push('cat package.json');
    cmd.push('npm install');
    cmd.push('npm install serverless --save');
    cmd.push('./node_modules/.bin/sls info || true');
     
    exec(cmd.join(' && ')).then((out) => {
        const response = {
            statusCode: 200,
            body: JSON.stringify(
                out
            )
        };
        console.log(out);
        callback(null, response);
    }, (err) => {
        console.error(err);
    });

    // Use this code if you don't use the http event with the LAMBDA-PROXY integration
    // callback(null, { message: 'Go Serverless v1.0! Your function executed successfully!', event });
};
