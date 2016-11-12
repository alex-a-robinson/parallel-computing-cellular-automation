TARGET = XCORE-200-EXPLORER

bin/test_worker_logic.xe: src/logic/worker_logic.xc
	xcc -o bin/test_worker_logic.xe -target="$(TARGET)" -Isrc/ \
		tests/test_worker_logic.xc

test: bin/test_worker_logic.xe
	@echo "===================================================";
	@echo "====================== TESTS ======================";
	@echo "===================================================";

	xsim bin/test_worker_logic.xe

scratch.xc:
	xcc -o bin/scratch.xe -g -target="$(TARGET)" scratch.xc

scratch: scratch.xc
	xsim bin/scratch.xe

bin/gol.xe: src/*
	 xcc -o bin/gol.xe -target="$(TARGET)" \
		-Ilibs/i2c/api -Ilibs/xassert/api \
		-Ilibs/gpio/api -Ilibs/gpio/api \
		-Ilibs/logging/api -Isrc/ libs/i2c/src/* \
		libs/xassert/src/* libs/gpio/src/* libs/logging/src/* \
		src/*.xc src/*.h src/logic/* src/image_processing/* src/controls/*

sim: bin/gol.xe
	xsim bin/gol.xe

run: bin/gol.xe
	xrun --io bin/gol.xe

run_with_image: run
	images/pgm_tool.py images/testout.pgm
