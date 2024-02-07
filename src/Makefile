debug: WebApp.js
	python3 -m http.server

deploy: WebApp.min.js
	cp $^ ../
	sed 's/WebApp\.js/WebApp\.min\.js/' index.html | sed 's/api\.js/src\/api\.js/' > ../index.html

WebApp.js: WebApp.lpr
	pas2js -Tbrowser -Pecmascript5 -MObjFPC -Sc -O2 -l -vewnhibq -Fijs -Fu../../jslib -Fu. -FUjs -FE. -o$@ -dPas2js -dPas2js -Jeutf-8 -Jirtl.js -Jc -Jm- -JRjs $^

*.min.js: WebApp.js api.js
	cat $^ | minify --type js > $@

WebAppFramework.js: WebApp.lpr
	pas2js -Tbrowser -Pecmascript5 -MObjFPC -Sc -O2 -l -vewnhibq -Fijs -Fu../../jslib -Fu. -FUjs -FE. -o$@ -dPas2js -dPas2js -Jeutf-8 -Jirtl.js -Jc -Jm- $^

dist: WebAppFramework.min.js
	mkdir -p dist/data
	cp $^ dist/
	sed 's/WebApp\.js/WebAppFramework\.min\.js/' index.html > dist/index.html
	cp AdminApp/DBAdmin dist/
	cp AdminApp/metaData.json dist/
	cp AdminApp/data/types.* dist/data/
	
clean:
	rm -f WebApp.min.js WebApp.js
