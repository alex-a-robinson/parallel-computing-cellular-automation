TARGET = XCORE-200-EXPLORER

bin/test_worker_logic.xe: src/worker_logic.xc
	xcc -target="$(TARGET)" tests/test_worker_logic.xc \
		-o bin/test_worker_logic.xe

test: bin/test_worker_logic.xe
	@echo "===================================================";
	@echo "====================== TESTS ======================";
	@echo "===================================================";

	xsim bin/test_worker_logic.xe

scratch.xc:
	xcc -g -target="$(TARGET)" scratch.xc -o bin/scratch.xe

scratch: scratch.xc
	xsim bin/scratch.xe

bin/gol.xe: src/*.c src/*.xc src/*.h
	xcc -o bin/gol.xe -target="XCORE-200-EXPLORER" \
		-Ilibs/i2c/api -Ilibs/xassert/api \
		-Ilibs/gpio/api -Ilibs/gpio/api \
		-Ilibs/logging/api libs/i2c/src/* \
		libs/xassert/src/* libs/gpio/src/* libs/logging/src/* src/*

sim: bin/gol.xe
	xsim bin/gol.xe

run: bin/gol.xe
	xrun --io bin/gol.xe

run_with_image: run
	images/pgm_tool.py images/testout.pgm
