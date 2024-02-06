debug: WebApp.js
	python3 -m http.server

deploy: WebApp.min.js
	cp $^ ../
	sed 's/WebApp\.js/WebApp\.min\.js/' index.html > ../index.html

WebApp.js: WebApp.lpr
	pas2js -Tbrowser -Pecmascript5 -MObjFPC -Sc -O2 -l -vewnhibq -Fijs -Fu../../jslib -Fu. -FUjs -FE. -oWebApp.js -dPas2js -dPas2js -Jeutf-8 -Jirtl.js -Jc -Jm- -JRjs WebApp.lpr

WebApp.min.js: WebApp.js
	cat $^ | minify --type js > $@

clean:
	rm *.js
