var jsdom = require("jsdom");
function getSortedAnchors(window) {
    var anchors = [].slice.call(window.document.querySelectorAll("*[id]"), 0);
    return anchors.map(e => e.id).sort();
}
var argv = process.argv;

if (argv.indexOf("-h") > 0 || argv.indexOf("--help") > 0) {
    console.log("$ node ./check-anchors.js [--show-added] [--show-examples] [--show-issues] [--show-refs-for] [--show-refs] [--show-proddefs]")
    process.exit();
}
 
var allowAll = _ => true;
var filterExamples = argv.indexOf("--show-examples") > 0 ? allowAll : id => !(/^example/).test(id);
var filterIssues = argv.indexOf("--show-issues") > 0 ? allowAll : id => !(/^issue-/).test(id);
var filterRefsFor = argv.indexOf("--show-refs-for") > 0 ? allowAll : id => !(/^ref-for-/).test(id);
var filterRefs = argv.indexOf("--show-refs") > 0 ? allowAll : id => !(/^ref-/).test(id);
var filterProdDefs = argv.indexOf("--show-proddefs") > 0 ? allowAll : id => !(/^proddef-/).test(id);

console.log("Parsing bikeshed port...")
jsdom.env({
  file: "index.html",
  done: function (err, bikeshedWindow) {
    var bikeshedAnchors = getSortedAnchors(bikeshedWindow);
    console.log("Parsing old version...\n")
    jsdom.env({
      file: "oldindex.html",
      done: function (err, oldWindow) {
        var oldAnchors = getSortedAnchors(oldWindow)
        console.log("Anchors missing from the Bikeshed port:")
        if (filterRefs != allowAll) {
            console.log("(Hiding all ids prefixed with 'ref-'.)")
        }
        if (filterProdDefs != allowAll) {
            console.log("(Hiding all ids prefixed with 'proddef-'.)")
        }
        oldAnchors
            .filter(id => bikeshedAnchors.indexOf(id) == -1)
            .filter(filterRefs)
            .filter(filterProdDefs)
            .forEach(id => console.log("  * " + id));
        if (argv.indexOf("--show-added") > 0) {
          console.log("Anchors added by the Bikeshed port (to include all anchors see -h):")
          bikeshedAnchors.filter(id => oldAnchors.indexOf(id) == -1)
              .filter(filterRefsFor)
              .filter(filterIssues)
              .filter(filterExamples)
              .forEach(id => console.log("  * " + id))
        }
      }
    });
  }
});
