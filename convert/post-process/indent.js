var argv = process.argv;

if (argv.indexOf("-h") > 0 || argv.indexOf("--help") > 0) {
    console.log("$ node ./indent.js [--markdownify]")
    process.exit();
}

var MARKDOWNIFY = argv.indexOf("--markdownify") > -1 ;
function printPre(buf, ws) {
    if (buf[0] == '<pre class="metadata">' || buf[0] == '<pre class="anchors">' || buf[0] == '<pre class="link-defaults">') {
        return buf.join("\n")
    }
    
    var output = [];
    
    // handle first line
    var parts = buf.shift().trim().split(/(<pre[^>]*>)/).filter(p => p);
    buf.unshift(parts.pop().trim());
    output.push.apply(output, parts.map(line => line.trim()));
    
    // handle last line
    parts = buf.pop().split(/(<\/pre>)/);
    var last_line = parts.shift();
    if (last_line.trim().length) {
        buf.push(last_line);
    }
    var closing_tag = parts.join("");

    var lengths = buf.filter(line => line.trim()).map(line => line.match(/(^\s*)/)[1].length)
    var remove = Math.min(...lengths);
    if (remove > 0) {
        var regex = new RegExp("^\s{" + remove + "}");
        buf = buf.map(line => line.replace(regex))
    }
    buf.forEach(line => {
        output.push("    " + line)
    });
    output.push(closing_tag);
    return output.map(line => ws + line).join("\n")
}
var currentTag = null;
var tags = [];
var count = 0;
var p = false;
var pre = false;
var pre_buffer = [];
var dt = false;
var dt_buffer = [];
var intro = true;

var byline = require('byline');
process.stdin.setEncoding('utf8');
var reader = byline(process.stdin, { keepEmptyLines: true });
reader.on("data", function(line) {
    tags.forEach(tag => tag.line++);
    count++;
    var opened = [], 
    closed = [],
    m,
    patt = /<(\/?)(html|pre|p|div|blockquote|ol|ul|li|dl|dd|dt|table|td|th|tr|tbody|thead|h[1-6]|script|style)(\s[a-z0-9-]+(?:="(?:[^\"]|\\")*")?)*>/g;
    while (m = patt.exec(line)) {
        if (m && !m[1] && m[2]) {
            currentTag = {
                name: m[2],
                line: 0,
                hasAttributes: !!m[3]
            };
            
            tags.push(currentTag);
            opened.push(m[2]);
            if (m[2] == "p") {
                p = true;
                if (m[3] == ' class="note"') currentTag.prefix = "Note: ";
                if (m[3] == ' class="ednote"') currentTag.prefix = "Issue: ";
            }
            if (m[2] == "pre") {
                pre = true;
                pre_buffer.length = 0;
                intro = false; // first metadata block
            }
            if (m[2] == "dt") dt = true;
        }
        if (m && m[1] && m[2]) {
            closed.push(m[2]);
            currentTag = tags.pop();
            currentTag.line = -1;
            if (currentTag.name != m[2]) throw [count, JSON.stringify(currentTag), JSON.stringify(m[2]), line].join(" ");
        }
    }
    //console.log(tags)
    if (!currentTag || intro || closed[0] == "html") {
        // don't print, we're trimming <html> tags
    } else if (pre) {
        // buffer it
        pre_buffer.push(line);
    } else if (currentTag.name == "style" || currentTag.name == "script") {
        pad(line);
    } else {
        line = line.trim();
        if (currentTag.name == "p") {
            if (line) { // avoid empty lines
                pad(line);
            }
        } else if (currentTag.name == "dt") {
            if (line != "<dt>" && line != "</dt>") {
                dt_buffer.push(line)
            }
        } else {
            pad(line);
        }
    }

    if (closed.indexOf("pre") > -1) {
        if (pre_buffer.length == 1) {
            console.log(parentPad(tags) + pre_buffer[0].trim());
        } else {
            console.log(printPre(pre_buffer, parentPad(tags)));
        }
        pre_buffer.length = 0;
        pre = false;
    }
    
    if (closed.indexOf("dt") > -1) {
        if (MARKDOWNIFY) {
            console.log(parentPad(tags) + " :  " + dt_buffer.join(" "));
        } else {
            console.log(parentPad(tags) + "<dt>" + dt_buffer.join(" ") + "</dt>");
        }
        dt_buffer.length = 0;
        dt = false;
    }
    
    if (currentTag && currentTag.line == -1) {
        var parent = tags[tags.length - 1];
        if (parent && (/^li$/).test(parent.name)) {
            parent.childNodes = parent.childNodes || [];
            parent.childNodes.push(currentTag);
        }
        currentTag = tags[tags.length - 1];
    }
});

function pad(line) {
    var output;
    
    if (currentTag.line == 0) {
        if (shouldAddPadLine(currentTag)) {
            console.log(parentPad(tags.slice(0, -1)));
        }
        if (!shouldSkipTagLines(currentTag)) {
            output = parentPad(tags.slice(0, -1));
            if (shouldPrintTags(currentTag)) {
                output += line;
            }
            console.log(output)
        }
    } else if (currentTag.line == -1) {
        if (!shouldSkipTagLines(currentTag)) {
            output = parentPad(tags.slice(0));
            if (shouldPrintTags(currentTag)) {
                output += line;
            }
            console.log(output)
        }
    } else {
        if (isLiWithMultipleChildNodes(currentTag)) {
            console.log(parentPad(tags.slice(0)));
        }
        console.log(parentPad(tags.slice(0)) + line);
    }
}

function shouldPrintTags(tag) {
    if (MARKDOWNIFY && /^(dl|dt|dd|ul|ol|li|p)$/.test(tag.name) && (tag.prefix || !tag.hasAttributes)) {
        return false;
    }
    return true;
}

function isLiWithMultipleChildNodes(tag) {
    var children = currentTag && currentTag.childNodes;
    var last_child = children && children[children.length - 1];
    if (MARKDOWNIFY && last_child && !last_child.used) {
        last_child.used = true;
        return true;
    }
    return false;
}

function shouldAddPadLine(tag) {
    var parent = tags[tags.length - 2];
    if (MARKDOWNIFY &&
            parent &&
            parent.childNodes) {
        return true;
    }
    return false;
}

function shouldSkipTagLines(tag) {
    // nested lists
    if (MARKDOWNIFY &&
        /^(dl|ul|ol)$/.test(tag.name) &&
        (tags.filter(tag => tag.name == "dl" || tag.name == "li").length > 0) && 
        !tag.hasAttributes) {
        return true;
    }
    
    if (MARKDOWNIFY &&
        /^(li|dd)$/.test(tag.name) &&
        !tag.hasAttributes) {
        return true;
    }
    var parent = tags[tags.length - 2];
    if (MARKDOWNIFY &&
        tag.name == "p" &&
        parent &&
        /^(li|dd)$/.test(parent.name) &&
        !parent.childNodes &&
        !tag.hasAttributes) {
        return true;
    }
    
    return false;
}

function parentPad(tags) {
    var output = ""
    tags.forEach((tag, i) => {
        switch(tag.name) {
            case "html":
                output += "";
                break;
            case "p":
                if (MARKDOWNIFY) {
                    if (tag.prefix) {
                        if (!tag.prefixed) {
                            tag.prefixed = true;
                            output += tag.prefix;
                        }
                    } else if (tag.hasAttributes) {
                        output += "    ";
                    } else {
                        output += "";
                    }
                } else {
                    output += "    ";
                }
                break;
            case "ol": 
            case "ul": 
            case "dl": 
                output += (tag.hasAttributes || !MARKDOWNIFY) ? "    " : "";
                break;
            case "dt":
                if (MARKDOWNIFY) {
                    output += " :  ";
                } else {
                    output += "    ";
                }
                break;
            case "dd":
                if (!tag.prefixed && MARKDOWNIFY) {
                    tag.prefixed = true;
                    output += " :: ";
                } else {
                    output += "    ";
                }
                break;
            case "li":
                if (!tag.prefixed && MARKDOWNIFY) {
                    tag.prefixed = true;
                    output += (tags[i - 1].name == "ol" ? "1.  " : "*   ");
                } else {
                    output += "    ";
                }
                break;
            default:
                output += "    " ;
        }
    });
    return output;
}
