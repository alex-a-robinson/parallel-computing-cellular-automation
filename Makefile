TARGET = XCORE-200-EXPLORER

test: game_of_life/tests/test_worker_logic.xc game_of_life/tests/grids.c
	# python3 -m 'grids' ./tests/grids_to_c.py
	xcc -target="XCORE-200-EXPLORER" game_of_life/tests/test_worker_logic.xc -o game_of_life/tests/bin/test_worker_logic.xe
	xsim game_of_life/tests/bin/test_worker_logic.xe
