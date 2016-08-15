var byline = require('byline');
process.stdin.setEncoding('utf8');
var reader = byline(process.stdin, { keepEmptyLines: true });
reader.on("data", function(line) {
    // Cleanup empty string tags (e.g. <dfn export=""> => <dfn export>).
    console.log(line.replace(/<[a-z1-6]+\s+[^>]+>/g, function(tag) {
        return tag.replace(/([a-z-]+)=""/g, "$1")
    }));
});

