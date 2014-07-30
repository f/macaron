default:
	coffee -co dist/ lib/index.coffee 
	browserify dist/index.js > dist/index.js
	uglifyjs dist/index.js > dist/index.min.js
