help:
	@echo "Yerel olarak test etmek için 'make test' komutunu, veya siteyi statik olarak oluşturmak için 'make build' komutunu kullanın."

build:
	mkdocs build

clean:
	rm -rf site

test:
	mkdocs serve

.PHONY: help build test
