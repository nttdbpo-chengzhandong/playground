'use strict';

const d3 = require('d3'),
      { JSDOM } = require('jsdom'),
      { document } = (new JSDOM).window,
      svg2png = require('svg2png'),
      fs = require('fs'),
      // set the dimensions and margins of the graph
      margin = {top: 10, right: 20, bottom: 30, left: 50},
      imgW = 400,
      imgH = 200,
      graphW = imgW - margin.left - margin.right,
      graphH = imgH - margin.top - margin.bottom,
      // parse the date / time
      parseTime = d3.timeParse("%d-%b-%y"),
      // set the ranges
      x = d3.scaleTime().range([0, graphW]),
      y = d3.scaleLinear().range([graphH, 0]),
      // define the line
      valueline = d3.line()
      .x(function(d) { return x(d.date); })
      .y(function(d) { return y(d.close); }),
      // svg
      svg = d3.select(document.body).append("svg")
      .attr('xmlns', 'http://www.w3.org/2000/svg')
      .attr("width", imgW)
      .attr("height", imgH)
      .style('background-color', 'white')
      .append("g")
      .attr("transform",
            "translate(" + margin.left + "," + margin.top + ")");    

const csvData = fs.readFileSync('./data.csv', 'utf8');
const data = d3.csvParse(csvData);
// Get the data
// format the data
data.forEach(function(d) {
    d.date = parseTime(d.date);
    d.close = +d.close;
});

// Scale the range of the data
x.domain(d3.extent(data, function(d) { return d.date; }));
y.domain([0, d3.max(data, function(d) { return d.close; })]);

// Add the valueline path.
svg.append("path")
    .data([data])
    .attr("class", "line")
    .attr("fill", "none")
    .attr("stroke","steelblue")
    .attr("stroke-width","2px")
    .attr("d", valueline);

// Add the X Axis
svg.append("g")
    .attr("transform", "translate(0," + graphH + ")")
    .call(d3.axisBottom(x));

// Add the Y Axis
svg.append("g")
    .call(d3.axisLeft(y));

console.log(document.body.innerHTML);

const svgString = decodeURIComponent(document.body.innerHTML);
const sourceBuffer = new Buffer(svgString);

svg2png(sourceBuffer, { width: imgW, height: imgH })
    .then(buffer => {
        fs.writeFile("dest.png", buffer);
    })
    .catch(e => console.error(e));
