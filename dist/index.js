// Generated by CoffeeScript 1.7.1
(function() {
  var Cloner, Macaron, coffee, fs;

  fs = require('fs');

  coffee = require('coffee-script');

  module.exports = Macaron = (function() {
    Macaron.prototype.hygienicVariableTemplate = function(name, id) {
      return "_" + name + "$" + id;
    };

    function Macaron(options) {
      this.options = options;
    }

    Macaron.prototype.compileSource = function(macroSource, mainSource, options) {
      this.macros = this.parseMacros(macroSource);
      this.literals = this.parseLiterals(macroSource);
      this.mainNodes = this.getNodes(mainSource);
      return this.compile(options);
    };

    Macaron.prototype.compileFile = function(macroFile, mainFile, options) {
      this.macros = this.parseMacros(this.getSource(macroFile));
      this.mainNodes = this.getNodes(this.getSource(mainFile));
      return this.compile(options);
    };

    Macaron.prototype.compileFileAndRun = function() {
      return eval(this.compileFile.apply(this, arguments));
    };

    Macaron.prototype.compileSourceAndRun = function() {
      return eval(this.compileFile.apply(this, arguments));
    };

    Macaron.prototype.compile = function(options) {
      if (options == null) {
        options = this.options;
      }
      this.walkAndReplace(this.mainNodes, this.macroize.bind(this));
      this.walkAndReplace(this.mainNodes, this.literalize.bind(this));
      return this.mainNodes.compile(options);
    };

    Macaron.prototype.parseMacros = function(source) {
      var macros, nodes;
      macros = {};
      nodes = this.getNodes(source);
      nodes.expressions.forEach((function(_this) {
        return function(node) {
          var name, _ref, _ref1, _ref2;
          if (node.variable.base.value === 'macro') {
            name = (_ref = node.variable.properties) != null ? (_ref1 = _ref[0]) != null ? (_ref2 = _ref1.name) != null ? _ref2.value.toString() : void 0 : void 0 : void 0;
            return macros[name] = node.value;
          }
        };
      })(this));
      return macros;
    };

    Macaron.prototype.parseLiterals = function(source) {
      var literals, nodes;
      literals = [];
      nodes = this.getNodes(source);
      nodes.expressions.forEach((function(_this) {
        return function(node) {
          var regexp, _ref, _ref1, _ref2;
          if (node.variable.base.value === 'literal') {
            regexp = new RegExp("^" + ((_ref = node.args[0]) != null ? (_ref1 = _ref.base) != null ? (_ref2 = _ref1.value) != null ? typeof _ref2.replace === "function" ? _ref2.replace(/^\/|\/$/g, '') : void 0 : void 0 : void 0 : void 0) + "$");
            return literals.push([regexp, node.args[1]]);
          }
        };
      })(this));
      return literals;
    };

    Macaron.prototype.walkAndReplace = function(node, replacer) {
      var _ref;
      return (_ref = node.children) != null ? _ref.forEach((function(_this) {
        return function(childName) {
          var child, grantChild, i, _i, _len, _results;
          child = node[childName];
          if (!child) {
            return;
          }
          if (child.length != null) {
            _results = [];
            for (i = _i = 0, _len = child.length; _i < _len; i = ++_i) {
              grantChild = child[i];
              replacer(grantChild, function(replacement) {
                return child[i] = replacement;
              });
              _results.push(_this.walkAndReplace(child[i], replacer));
            }
            return _results;
          } else {
            replacer(child, function(replacement) {
              return child = node[childName] = replacement;
            });
            return _this.walkAndReplace(child, replacer);
          }
        };
      })(this)) : void 0;
    };

    Macaron.prototype.literalize = function(node, replace) {
      var arg, args, i, literal, macro, matches, name, param, _i, _j, _len, _len1, _matches, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _results;
      if (node.constructor.name !== 'Literal') {
        args = {};
        _ref = this.literals;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          _ref1 = _ref[_i], literal = _ref1[0], macro = _ref1[1];
          _matches = (_ref2 = node.base) != null ? (_ref3 = _ref2.value) != null ? typeof _ref3.replace === "function" ? _ref3.replace(/^["']|["']$/g, '').match(literal) : void 0 : void 0 : void 0;
          if (!_matches) {
            continue;
          }
          _matches.shift();
          matches = (function() {
            var _j, _len1, _results1;
            _results1 = [];
            for (_j = 0, _len1 = _matches.length; _j < _len1; _j++) {
              arg = _matches[_j];
              _results1.push(arg);
            }
            return _results1;
          })();
          macro = Cloner.clone(macro);
          _ref4 = macro.params;
          for (i = _j = 0, _len1 = _ref4.length; _j < _len1; i = ++_j) {
            param = _ref4[i];
            name = param.name["this"] ? (_ref5 = param.name.properties) != null ? (_ref6 = _ref5[0]) != null ? (_ref7 = _ref6.name) != null ? _ref7.value : void 0 : void 0 : void 0 : param.name.value;
            args[name] = [matches[i], param.name["this"]];
          }
          this.walkAndReplace(macro, (function(_this) {
            return function(node, replace) {
              var isString, ref, _ref8, _ref9;
              if (node.constructor.name !== 'Value') {
                return;
              }
              ref = (_ref8 = node.base) != null ? _ref8.value : void 0;
              if (args[ref] instanceof Array) {
                _ref9 = args[ref], arg = _ref9[0], isString = _ref9[1];
                if (arg) {
                  if (isString) {
                    arg = "\"" + arg + "\"";
                  }
                  return replace(_this.getNodes(arg));
                }
              }
            };
          })(this));
          _results.push(replace(macro.body));
        }
        return _results;
      }
    };

    Macaron.prototype.macroize = function(node, replace) {
      var args, i, macro, macroBody, macroType, name, param, vars, _ref, _ref1, _ref2, _ref3;
      if (node.constructor.name !== 'Call') {
        return;
      }
      name = (_ref = node.variable) != null ? (_ref1 = _ref.base) != null ? _ref1.value : void 0 : void 0;
      if (!this.macroExists(name)) {
        return;
      }
      macro = Cloner.clone(this.macros[name]);
      args = {};
      vars = {};
      macroType = (_ref2 = macro.variable) != null ? (_ref3 = _ref2.base) != null ? _ref3.value : void 0 : void 0;
      macroBody = (function() {
        var _i, _len, _ref4, _ref5;
        switch (true) {
          case macro["do"]:
            return (_ref4 = macro.variable) != null ? _ref4.body : void 0;
          default:
            _ref5 = macro.params;
            for (i = _i = 0, _len = _ref5.length; _i < _len; i = ++_i) {
              param = _ref5[i];
              name = param.name.value;
              if (param.splat) {
                args[name] = node.args[i].body;
              } else {
                args[name] = node.args[i];
              }
            }
            this.walkAndReplace(macro, (function(_this) {
              return function(node, replace) {
                var ref, _ref6;
                if (node.constructor.name !== 'Value') {
                  return;
                }
                ref = (_ref6 = node.base) != null ? _ref6.value : void 0;
                if (args[ref]) {
                  return replace(args[ref]);
                } else if ((ref != null ? ref.indexOf('$') : void 0) === 0 && !macro.bound) {
                  name = ref.substring(1);
                  name = vars[name] || (vars[name] = _this.generateHygienicName(name));
                  return node.base.value = name;
                }
              };
            })(this));
            return macro.body;
        }
      }).call(this);
      return replace(macroBody);
    };

    Macaron.prototype.getSource = function(file) {
      return fs.readFileSync(file).toString();
    };

    Macaron.prototype.getNodes = function(source) {
      return coffee.nodes(coffee.tokens(source));
    };

    Macaron.prototype.macroExists = function(name) {
      return (name != null) && (this.macros[name] != null);
    };

    Macaron.prototype.generateHygienicName = function(name) {
      if (this.hygieneId == null) {
        this.hygieneId = 0;
      }
      this.hygieneId++;
      return this.hygienicVariableTemplate(name, this.hygieneId);
    };

    return Macaron;

  })();

  Cloner = (function() {
    function Cloner() {}

    Cloner.clone = function(object) {
      var cloner;
      switch (typeof object) {
        case 'undefined':
        case 'number':
        case 'string':
        case 'boolean':
        case 'function':
          return object;
        case 'object':
          cloner = object instanceof Array ? 'array' : 'object';
          return Cloner[cloner](object);
        default:
          return console.log("Non-clonable " + (typeof object));
      }
    };

    Cloner.array = function(data) {
      var item, _i, _len, _results;
      if (data == null) {
        data = [];
      }
      _results = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        item = data[_i];
        _results.push(Cloner.clone(item));
      }
      return _results;
    };

    Cloner.object = function(data) {
      var cloned, key, value;
      if (data == null) {
        data = {};
      }
      cloned = {};
      for (key in data) {
        value = data[key];
        cloned[key] = Cloner.clone(value);
      }
      cloned.constructor = data.constructor;
      cloned.__proto__ = data.__proto__;
      return cloned;
    };

    return Cloner;

  })();

  if (window) {
    window.Macaron = Macaron;
  }

}).call(this);
