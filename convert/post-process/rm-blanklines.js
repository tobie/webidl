// Remove extra blank lines around tags
// For example, turn this:
// <li>
//    
//     Added a warning to prefer the use of {{double}}
//     to {{float}}, unless there are good
//     reasons to choose the 32 bit type.
//    
// </li>
//
// into this:
//
// <li>
//     Added a warning to prefer the use of {{double}}
//     to {{float}}, unless there are good
//     reasons to choose the 32 bit type.
// </li>

function isEmpty(line) {
    return (/^\s*$/).test(line);
}

var byline = require('byline');
process.stdin.setEncoding('utf8');
var reader = byline(process.stdin, { keepEmptyLines: true });
var previousLineIsOpeningTag = false;
var previousLine = null;
reader.on("data", function(line) {
    var isClosingTag = false;
    var isOpeningTag = false;
    var m = line.match(/^\s*<(\/)?(?:p|pre|div|blockquote|ol|ul|li|dl|dd|dt)(?:\s[a-z0-9-]+="(?:[^\"]|\\")*")*>\s*$/);
    if (m && m[1]) {
        isClosingTag = true;
    } else if (m) {
        isOpeningTag = true;
    }
    
    // if there's a stored line and this line is empty, and we're not closing a tag, it should be printed.
    if (previousLine != null && isEmpty(previousLine) && !isClosingTag) {
        console.log(previousLine);
    }
    previousLine = null;
    
    // if current line is empty:
    //      if previous line was an opening tag, don't print it.
    //      else store it for later.
    if (isEmpty(line)) {
        if (!previousLineIsOpeningTag) {
            previousLine = line;
        }
    } else {
        console.log(line);
    }
    previousLineIsOpeningTag = isOpeningTag;
});

reader.on("end", function() {
    console.log(previousLine)
});

