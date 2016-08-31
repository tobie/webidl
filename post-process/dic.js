var byline = require('byline');
process.stdin.setEncoding('utf8');
var LINES = [
    ["DOMString name;", "attribute DOMString name;"],
    ["unsigned long number;", "attribute unsigned long number;"],
    ["...", "// ..."],
    ['<pre class="idl">void forEach(Function callback, optional any thisArg);</pre>',
        '<pre highlight="webidl">\n  interface Iterable {\n    void forEach(Function callback, optional any thisArg);\n  };\n</pre>'],
]
  
var WRAP = [
    "return_type identifier(type identifier, optional type identifier = \"value\");",
    "return_type identifier([<mark>extended_attributes</mark>] type identifier, [<mark>extended_attributes</mark>] type identifier /* , ... */);",
    "return_type operation_identifier(argument_type <mark>argument_identifier</mark> /* , ... */);",
    "return_type identifier(type identifier, type identifier /* , ... */);",
    "return_type <mark>operation_identifier</mark>(/* arguments... */);",
    "stringifier attribute DOMString identifier;",
    "return_type identifier(/* arguments... */);",
    "static return_type identifier(/* arguments... */);",
    "return_type identifier(type identifier, optional type identifier);",
    "stringifier;",
    "serializer;",
    "serializer = { getter };",
    "serializer = [ attribute_identifier, attribute_identifier /* , ... */ ];",
    "serializer = [ getter ];",
    "serializer = attribute_identifier;",
    "serializer type identifier();"
]

var WRAP_FIRST = [
    "/* special_keywords... */ return_type identifier(/* arguments... */);",
    "legacycaller return_type identifier(/* arguments... */);",
    "return_type identifier(type<mark>...</mark> identifier);",
    "stringifier DOMString identifier();",
    "serializer = { attribute_identifier, attribute_identifier /* , ... */ };",
    "serializer = { attribute };",
    "getter type identifier(unsigned long identifier);",
    "getter type identifier(DOMString identifier);",
    "iterable&lt;value_type&gt;;",
    "readonly maplike&lt;key_type, value_type&gt;;",
    "readonly setlike&lt;type&gt;;"
]

var MIDDLE = [
    "setter type identifier(unsigned long identifier, type identifier);",
    "getter type (unsigned long identifier);",
    "setter type identifier(DOMString identifier, type identifier);",
    "deleter type identifier(DOMString identifier);",
    "getter type (DOMString identifier);",
    "setter type (DOMString identifier, type identifier);"
];

var WRAP_LAST = [
    "/* special_keywords... */ return_type (/* arguments... */);",
    "legacycaller return_type (/* arguments... */);",
    "return_type identifier(type identifier, type<mark>...</mark> identifier);",
    "stringifier DOMString ();",
    "serializer = { inherit, attribute_identifier, attribute_identifier /* , ... */ };",
    "serializer = { inherit, attribute };",
    "setter type (unsigned long identifier, type identifier);",
    "deleter type (DOMString identifier);",
    "iterable&lt;key_type, value_type&gt;;",
    "maplike&lt;key_type, value_type&gt;;",
    "setlike&lt;type&gt;;"
]

function escapeRegExp(string){
  return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"); // $& means the whole matched string
}

var regexes = LINES.map(pair => [new RegExp("^(\\s*)" + escapeRegExp(pair[0]) + "(\\s*)$", ""), "$1" + pair[1] + "$2"]);
regexes.push.apply(regexes, WRAP.map(str => [
    new RegExp("^(\\s*<pre highlight=\"webidl\" class=\"syntax\">)" + escapeRegExp(str) + "(</pre>\\s*)$", ""),
    "$1interface interface_identifier {\n  " + str + "\n};$2"
]));
regexes.push.apply(regexes, WRAP_FIRST.map(str => [
    new RegExp("^(\\s*<pre highlight=\"webidl\" class=\"syntax\">)" + escapeRegExp(str) + "(\\s*)$", ""),
    "$1interface interface_identifier {\n  " + str + "$2"
]));
regexes.push.apply(regexes, MIDDLE.map(str => [
    new RegExp("^(\\s*)" + escapeRegExp(str) + "(\\s*)$", ""),
    "$1  " + str + "$2"
]));
regexes.push.apply(regexes, WRAP_LAST.map(str => [
    new RegExp("^(\\s*)" + escapeRegExp(str) + "(</pre>\\s*)$", ""),
    "  " + str + "\n};$2"
]));
regexes.push([/interface ([a-zA-Z]+) \{ \.\.\. \};/,
              "interface $1 { /* ... */ };"]);
regexes.push([/const type (<mark>)?(?:constant_)?identifier(<\/mark>)? = "value";/,
              "const type $1constant_identifier$2 = 42;"]);
regexes.push([/(static |readonly )?attribute type identifier;<\/pre>/,
            "\ninterface interface_identifier {\n  $1attribute type identifier;\n};\n</pre>"]);
regexes.push([/serializer type identifier\(\)/,
              "serializer identifier()"]);

var reader = byline(process.stdin, { keepEmptyLines: true });
reader.on("data", function(line) {
    regexes.forEach(r => line = line.replace(r[0], r[1]));
    console.log(line);
});

