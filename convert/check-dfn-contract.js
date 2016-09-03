var jsdom = require("jsdom");
function getDfns(window) {
    return [].slice.call(window.document.querySelectorAll("dfn, h1[data-dfn-type], h2[data-dfn-type], h3[data-dfn-type], h4[data-dfn-type], h5[data-dfn-type], h6[data-dfn-type]"), 0).map(dfn => {
        var lt = dfn.getAttribute("dataset-lt");
        return {
            lt: lt ? lt.split("|") : [dfn.textContent.replace(/\s*\n+\s*/g, " ")],
            ids: dfn.id,
            type: dfn.getAttribute("dataset-dfn-type") || (dfn.tagName == "DFN" ? "dfn" : null),
            for: dfn.getAttribute("dataset-dfn-for")  || null,
            export: dfn.hasAttribute("export") || dfn.getAttribute("dataset-dfn-type") != "dfn"
        }
    });
}

function dicFromDfns(dfns) {
    var output = {};
    dfns.forEach(dfn => {
        dfn.lt.forEach(lt => output[dfn.for ? dfn.for + "!" + lt : lt] = dfn)
    });
    return output;
}
var argv = process.argv;

if (argv.indexOf("-h") > 0 || argv.indexOf("--help") > 0) {
    console.log("$ node ./check-dfn-contract.js path/to/old/file path/to/new/file")
    process.exit();
}

var oldFile = process.argv[2];
var bikeshedPort = process.argv[3];

console.log("Parsing bikeshed port... (" + bikeshedPort + ")")
jsdom.env({
  file: bikeshedPort,
  done: function (err, bikeshedWindow) {
    var bikeshedDfns = dicFromDfns(getDfns(bikeshedWindow));
    console.log("Parsing old version... (" + oldFile + ")")
    jsdom.env({
      file: oldFile,
      done: function (err, oldWindow) {
        var oldDfns = dicFromDfns(getDfns(oldWindow));
        console.log("DFNs missing from the Bikeshed port:")
        //console.log(JSON.stringify(oldDfns, null, 4))
        Object.keys(oldDfns)
            .filter(id => !(id in bikeshedDfns))
            .forEach(id => console.log("  * " + id));
        console.log("DFNs no longer exported in the Bikeshed port:")
        //console.log(JSON.stringify(oldDfns, null, 4))
        Object.keys(oldDfns)
            .filter(id => id in bikeshedDfns && oldDfns[id].export && !bikeshedDfns[id].export)
            .forEach(id => console.log("  * " + id));
      }
    });
  }
});
