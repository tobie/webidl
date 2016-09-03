var byline = require('byline');
process.stdin.setEncoding('utf8');
var previous_line = "";
var reader = byline(process.stdin, { keepEmptyLines: true });
reader.on("data", function(line) {
    if (/^\s*$/.test(line) && /^\s*$/.test(previous_line)) {
       //do nothing
    } else {
        console.log(line);
    }
    previous_line = line;
});

