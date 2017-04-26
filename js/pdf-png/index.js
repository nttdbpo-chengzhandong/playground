'use strict';
const gm = require('gm').subClass({imageMagick: true});
const img = gm('test.pdf').in('-density', '400').resize(1024,768);
img.write('image.png', (err) => {
    if (err) {
        console.log(err);
    }
});
