'use strict';

const client = require('cheerio-httpcli');

module.exports.parse = (event, context, callback) => {
    const url = event.queryStringParameters && event.queryStringParameters.hasOwnProperty('url') ? event.queryStringParameters.url : null;

    if (!url) {
        const response = {
            statusCode: 400,
            body: JSON.stringify({
                message: 'Bad request',
                input: event,
            }),
        };
        callback(null, response);
        return;
    }

    client.fetch(url, (err, $, res, body) => {
        // レスポンスヘッダを参照
        console.log(res.headers);

        // HTMLタイトルを表示
        console.log($('title').text());

        // リンク一覧を表示
        let links = [];
        $('a').each(function (idx) {
            console.log($(this).attr('href'));
            links.push($(this).attr('href'));
        });

        const response = {
            statusCode: 200,
            body: JSON.stringify({
                title: $('title').text(),
                links: links,
            }),
        };
        callback(null, response);
    });
};
