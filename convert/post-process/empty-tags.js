var byline = require('byline');
process.stdin.setEncoding('utf8');
var reader = byline(process.stdin, { keepEmptyLines: true });
reader.on("data", function(line) {
    // <div /> => <div></div>
    // <td /> => <td></td>
    // <th /> => <th></th>
    console.log(line.replace(/<(div|td|th)(\s+[^>]+)?\/>/g, "<$1$2></$1>"));
});

