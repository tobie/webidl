var jsdom = require("jsdom");
var argv = process.argv;

if (argv.indexOf("-h") > 0 || argv.indexOf("--help") > 0 || !argv[2]) {
    console.log("$ node ./check-structure.js path/to/file")
    process.exit();
}

var ADD_P = argv.indexOf("--add-p") > -1 ;

jsdom.env({
  file: process.argv[2],
  encoding: "utf-8",
  done: function (err, window) {
    console.log(tags(window.document.body, 0))
  }
});


function tags(e, indent) {
    if (e.nodeType == "3") {
        return e.textContent.trim().replace(/\n\s+/g, "\n")
    }
    
    //if (ADD_P) {
    //    if (
    //        (e.tagName == "DT" || e.tagName == "DD") &&
    //        (!e.children[0] || e.children[0].tagName != "P")
    //    ) {
    //        var p = e.ownerDocument.createElement("P");
    //        for (var i = 0; i < e.childNodes.length; i++) {
    //            p.appendChild(e.childNodes[i]);
    //        }
    //        e.appendChild(p);
    //    }
    //}
    
    if (e.childNodes.length) {
        if (e.tagName == "P") {
            return Array.from(e.childNodes).map(child => tags(child, indent)).join("\n").replace(/^(Note|Advisement|Issue): /, "")
        }
        var children = Array.from(e.childNodes).map(child => tags(child, indent + 1)).join("\n");
        return leftPad(indent) + openTag(e) + "\n" + children + "\n" + leftPad(indent) + closeTag(e);
    }
    return leftPad(indent) + emptyTag(e);
}

function leftPad(i) {
    var o = "";
    return ""
    while(i--) { o += "    "; }
    return o;
}

function openTag(e) {
    return "<" + e.tagName.toLowerCase() + id(e) + ">";
}

function closeTag(e) {
    return "</" + e.tagName.toLowerCase() + ">";
}

function emptyTag(e) {
    return "<" + e.tagName.toLowerCase() + id(e) + " />";
}

function id(e) {
    if (e.id && !(/^example-/.test(e.id))) {
        return ' id="' + e.id + '"';
    }
    return '';
}