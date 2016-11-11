TARGET = XCORE-200-EXPLORER

game_of_life/tests/bin/test_worker_logic.xe:
	xcc -target="$(TARGET)" game_of_life/tests/test_worker_logic.xc \
		-o game_of_life/tests/bin/test_worker_logic.xe

test: game_of_life/tests/bin/test_worker_logic.xe
	clear;
	@echo "=================";
	@echo "===== TESTS =====";
	@echo "=================";

	xsim game_of_life/tests/bin/test_worker_logic.xe

scratch.xc:
	xcc -g -target="$(TARGET)" scratch.xc -o bin/scratch.xe

scratch: scratch.xc
	xsim bin/scratch.xe

bin/gol.xe: src/*.c src/*.xc src/*.h
	xcc -o bin/gol.xe -target="XCORE-200-EXPLORER" \
		-Ilibs/lib_i2c/api -Ilibs/lib_xassert/api \
		-Ilibs/lib_logging/api libs/lib_i2c/src/* \
		libs/lib_xassert/src/* libs/lib_logging/src/* src/*

gol: bin/gol.xe
	xsim bin/gol.xe
