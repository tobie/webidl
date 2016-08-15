var byline = require('byline');
process.stdin.setEncoding('utf8');
var previous_line = "";
var reader = byline(process.stdin, { keepEmptyLines: true });
reader.on("data", function(line) {
    if (/^<h[1-6]/.test(line)) {
        console.log("");
    } else if (/^<[a-z]/.test(line) && /\S/.test(previous_line)) {
        console.log("");
    } 
    console.log(line);
    previous_line = line;
});

