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

var csl = document.getElementById('console');
var consol = CodeMirror.fromTextArea(csl, {
  theme: "monokai",
  lineNumbers: true,
  readOnly: true
});

function compile() {
  try {
    var macaron = new Macaron();
    result.setValue("// The Result\n\n" + macaron.compileSource(macros.getValue(), source.getValue(), {bare: true}));
  } catch (e) { }
};

compile();

function run() {
  try {
    var console = {}
    console.log = function() {
      var args = Array.prototype.slice.call(arguments);
      window.console.log.apply(window.console, arguments);
      consol.setValue(consol.getValue().concat(args.join(' '), '\n'));
    };
    console.error = console.log;
    console.warn = console.log;
    console.info = console.log;
    console.clear = function () { console.setValue(''); }
    eval(result.getValue());
    document.getElementById('close').style.display = 'block';
  } catch (e) {}
};

function close(n) {
  csl.className = csl.className.replace(/ active/, '');
  consol.setValue('');
  document.getElementById('close').style.display = 'none';
}

macros.on('keyup', compile);
source.on('keyup', compile);
result.on('keyup', compile);
macros.on('focus', close);
source.on('focus', close);
document.getElementById('run').onclick = function () {
  compile();
  run();
  csl.className = csl.className.replace(/ active/, '');
  csl.className += " active";
};
document.getElementById('close').onclick = close;
