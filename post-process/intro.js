var regex = /(<\/?(?:p|div|blockquote|ol|ul|li|dl|dd)(?:\s[a-z0-9-]+="(?:[^\"]|\\")*")*>)/g;
var byline = require('byline');
process.stdin.setEncoding('utf8');
var reader = byline(process.stdin, { keepEmptyLines: true });
reader.on("data", function(line) {
    var parts = line.split(regex);
    var filtered = parts.map(p => p.trim()).filter(p => p);
    if (filtered.length > 1) {
        console.log(parts.map(p => {
            var m = p.match(/^<(\/)?(?:p|div|blockquote|ol|ul|li|dl|dd)(?:\s[a-z0-9-]+="(?:[^\"]|\\")*")*>$/);
            if (m && m[1]) {
                return "\n" + p;
            }
            if (m) {
                return p + "\n";
            }
            return p;
        }).join(""));
    } else {
        console.log(line)
    }
});

