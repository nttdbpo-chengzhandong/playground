const path = require('path');
const glob = require('glob');

const srcBasePath = path.resolve(__dirname, 'src/');
const targets = glob.sync(`${srcBasePath}/**/*.js`);
const entries = {};
targets.forEach(value => {
    const re = new RegExp(`${srcBasePath}/`);
    const key = value.replace(re, '');
    entries[key] = value;
});

module.exports = {
    entry: entries,
    output: {
        path: __dirname + '/dist',
        filename: '[name]'
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: {
                    loader: 'babel-loader',
                    options: {
                        presets: ['@babel/preset-env']
                    }
                }
            },
            {
                test: /\.(woff|woff2|eot|ttf|otf)$/,
                loader: 'file-loader'
            }
        ]
    }
};
