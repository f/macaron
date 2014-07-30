var macros = CodeMirror.fromTextArea(document.getElementById("macros"), {
  lineNumbers: true,
  theme: "mdn-like",
  mode: "coffeescript",
  gutters: ["CodeMirror-lint-markers"],
  lint: true
});

var source = CodeMirror.fromTextArea(document.getElementById("source"), {
  lineNumbers: true,
  theme: "mdn-like",
  mode: "coffeescript",
  gutters: ["CodeMirror-lint-markers"],
  lint: true
});

var result = CodeMirror.fromTextArea(document.getElementById("result"), {
  lineNumbers: true,
  theme: "mdn-like",
  mode: "javascript",
  readOnly: true
});

function compile() {
  try {
    var macaron = new Macaron();
    result.setValue("// The Result\n\n" + macaron.compileSource(macros.getValue(), source.getValue(), {bare: true}));
  } catch (e) {
    console.log(e);
  }
};

compile();
macros.on('keyup', compile);
source.on('keyup', compile);
result.on('keyup', compile);

