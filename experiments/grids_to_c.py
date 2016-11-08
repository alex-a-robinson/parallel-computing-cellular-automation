#!/usr/bin/env python3

import grids

vars_list = [item for item in dir(grids) if not item.startswith("_")]


with open('../game_of_life/tests/grids.c', 'w') as nnf:
    nnf.write('')
    nnf.close()

with open('../game_of_life/tests/grids.c', 'a') as nf:
    for var in vars_list:
        val = grids.__dict__[var]
        if type(val) == list and type(val[0]) == list:
            if len(val[0]) == len(val[-1]):
                nf.write("int %s[][%i] = %s;\n" % (var, len(val[0]), str(val).replace('[', '{').replace(']', '}')))
            else:
                print("%s was a variable-sized list" % (var))
                nf.write("//%s was a variable-sized list\n" % (var))
        else:

            nf.write("int %s[] = %s;\n" % (var, str(val).replace('[', '{').replace(']', '}')))
    nf.close()
