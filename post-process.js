var REMOVE_P_TAGS = false;

var Reader = require('line-by-line');

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

var tags = [];
var count = 0;
var p = false;
var p_has_attribute;
var pre = false;
var pre_buffer = [];
var li = false;
var dd = false;
var blockquote = false;
var intro = true;
var reader = new Reader('index-pre.bs');
reader.on("line", function(line) {
    count++;
    //console.log(tags)
    var opened = [], 
    closed = [],
    m,
    patt = /<(\/?)(html|pre|p|div|blockquote|ol|ul|li|dl|dd|dt|table|td|th|tr|tbody|thead)(\s[a-z0-9-]+="([^\"]|\\")*")*>/g;
    while (m = patt.exec(line)) {
        if (m && !m[1] && m[2]) {
            tags.push(m[2]);
            opened.push(m[2]);
            if (m[2] == "p") {
                p = true;
                p_has_attribute = !!m[3];
            }
            if (m[2] == "pre") {
                pre = true;
                pre_buffer.length = 0;
                intro = false; // first metadata block
            }
            if (m[2] == "blockquote") blockquote = true;
            if (m[2] == "li") li = true;
            if (m[2] == "dd") dd = true;
        } else if (m && m[1] && m[2]) {
            closed.push(m[2]);
            var last = tags.pop();
            if (last != m[2]) throw [count, JSON.stringify(last), JSON.stringify(m[2]), line].join(" ");
        }
    }
    var length = tags.length - 1 // account for html tag we want to remove
    var d = opened.length - closed.length
    var ws, TAB_SIZE = 4; 
    if (d > 0) {
        ws = times((length - d) * TAB_SIZE);
    } else if (d == 0) {
        ws = times(length * TAB_SIZE);
    } else if (d < 0) {
        ws = times(length * TAB_SIZE);
    }
    
    // Cleanup empty string tags (e.g. <dfn export=""> => <dfn export>).
    line = line.replace(/<[a-z1-6]+\s+[^>]+>/g, function(tag) {
        return tag.replace(/([a-z-]+)=""/g, "$1")
    });
    
    if (intro || closed[0] == "html") {
        // don't print, we're trimming <html> tags
    } else if (pre) {
        // buffer it
        pre_buffer.push(line);
    } else {
        if (p) {
            line = line.trim();
            if (line) { // avoid empty lines
                if (REMOVE_P_TAGS && !p_has_attribute) {
                    if (line == "<p>" || line == "</p>") {
                        // don't print
                    } else {
                        // watch out for inline tags
                        line = line.replace(/<\/?p>/, "");
                        console.log(ws.replace(/^    /, "") + line);
                    }
                } else {
                    console.log(ws + line);
                }
            }
        } else {
            if (/\S+\s*<\/(li|dd)>\s*$/.test(line) && !(/^\s*<(li|dd)/).test(line)) {
                ws += "    ";
            }
            console.log(ws + line.trim());
        }
    }
    
    
    //if (opened.length || closed.length) {
    //console.log(times(tags.length * 2) + "opened  ", JSON.stringify(opened))
    //console.log(times(tags.length * 2) + "closed", JSON.stringify(closed))
    //console.log(JSON.stringify(tags))
    //}
    if (closed.indexOf("pre") > -1) {
        if (pre_buffer.length == 1) {
            console.log(pre_buffer[0]);
        } else {
            console.log(printPre(pre_buffer, ws));
            // console.log(pre_buffer.join("\n"));
        }
        pre_buffer.length = 0;
        pre = false;
    }
    if (closed.indexOf("p") > -1) {
        p = false;
    }
    if (closed.indexOf("blockquote") > -1) {
        blockquote = false;
    }
    
    if (closed.indexOf("li") > -1) {
        li = false;
    }
    
    if (closed.indexOf("li") > -1) {
        dd = false;
    }
})
reader.on("end", function(line) { console.log("") })

function times(n, what) {
    var output = "";
    n = Math.max(0, n);
    while (n--) {
        output += what || " ";
    }
    return output;
}