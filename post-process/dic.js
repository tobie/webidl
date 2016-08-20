var byline = require('byline');
process.stdin.setEncoding('utf8');
var LINES = [
    ["DOMString name;", "attribute DOMString name;"],
    ["unsigned long number;", "attribute unsigned long number;"],
    ["...", "// ..."],
    ['<pre class="idl">void forEach(Function callback, optional any thisArg);</pre>',
    '<pre class="idl">\n  interface Iterable {\n    void forEach(Function callback, optional any thisArg);\n  };\n</pre>']
]

function escapeRegExp(string){
  return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"); // $& means the whole matched string
}

var regexes = LINES.map(pair => [new RegExp("^(\\s*)" + escapeRegExp(pair[0]) + "(\\s*)$", ""), "$1" + pair[1] + "$2"]);

regexes.push([/interface ([a-zA-Z]+) \{ \.\.\. \};/, "interface $1 { /* ... */ };"]);

var reader = byline(process.stdin, { keepEmptyLines: true });
reader.on("data", function(line) {
    regexes.forEach(r => line = line.replace(r[0], r[1]));
    console.log(line);
});

