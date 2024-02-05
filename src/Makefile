debug:
	python3 -m http.server

deploy: WebApp.min.js
	cp $^ ../
	sed 's/WebApp\.js/WebApp\.min\.js/' index.html > ../index.html

WebApp.min.js: WebApp.js
	cat $^ | minify --type js > $@

clean:
	rm *.js
