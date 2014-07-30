default:
	rm -rf dist/
	coffee -co dist/ lib/index.coffee 
	browserify dist/index.js > dist/_tmp.js
	uglifyjs dist/_tmp.js > dist/index.min.js
	rm -f dist/_tmp.js
	cp dist/index.min.js try/js/macaron.min.js
