clean:
	rm -rf build

build:
	./build.sh

install: clean
	./install.sh

kill:
	pkill -9 -f "SuperOpt" || echo "No running SuperOpt processes found."

run: kill clean
	./install.sh --run
