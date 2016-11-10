#include <grids.c>
#include <../src/worker_logic.xc>

#define ASSERT(str, expr)  \
    if (!expr) \
        printf("  %s failed at line %i\n", str, __LINE__)




void test_get_bit(){
    printf("\ntest_get_bit:\n");
    uint array_0[1] = {0};
    ASSERT("get_bit(array_0,0) == 0)", get_bit(array_0,0) == 0);

    uint array_1[1] = {1};
    ASSERT("get_bit(array_1,0) == 0", get_bit(array_1,0) == 0);
    ASSERT("get_bit(array_1,31) == 1", get_bit(array_1,31) == 1);

    uint array_donut[3] = {7,5,7};
    ASSERT("get_bit(array_donut,60) == 0", get_bit(array_donut,62) == 0);
    ASSERT("get_bit(array_donut,62) == 0", get_bit(array_donut,62) == 0);
    ASSERT("get_bit(array_donut,61) == 1", get_bit(array_donut,61) == 1);
    ASSERT("get_bit(array_donut,63) == 1", get_bit(array_donut,63) == 1);

    printf("done.\n\n");
}

void test_calc_cell() {
    uint strip_32_4_zeros[4] = {0, 0, 0, 0};
    uint strip_32_4_ones[4]  = {0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff};
    uint strip_32_4_columns[4] = {0xaaaaaaaa, 0xaaaaaaaa, 0xaaaaaaaa, 0xaaaaaaaa};
    uint strip_32_4_columns_inv[4] = {0x55555555, 0x55555555, 0x55555555, 0x55555555};

    //uint strip_32_4_diagonal[4] = {8, 4, 2, 1};
    //uint strip_32_4_diagonal_inv[4] = {1,2,4,8};
    //TODO diagonal test
    //uint strip_32_8_diagonal_inv[4] = {1,2,4,8,16,32,64,128};

    ASSERT("calc_cell(33, strip_32_4_zeros, 32) == 0)", calc_cell(33, strip_32_4_zeros, 32) == 0);
    ASSERT("calc_cell(33, strip_32_4_ones, 32) == 0)", calc_cell(33, strip_32_4_ones, 32) == 0);
    ASSERT("calc_cell(63, strip_32_4_ones, 32) == 0)", calc_cell(63, strip_32_4_ones, 32) == 0);
    ASSERT("calc_cell(32, strip_32_4_columns, 32) == 1", calc_cell(32, strip_32_4_columns, 32) == 1);
    ASSERT("alc_cell(33, strip_32_4_columns, 32) == 0", calc_cell(33, strip_32_4_columns, 32) == 0);
    ASSERT("calc_cell(32, strip_32_4_columns_inv, 32) == 0", calc_cell(32, strip_32_4_columns_inv, 32) == 0);
    ASSERT("alc_cell(33, strip_32_4_columns_inv, 32) == 1", calc_cell(33, strip_32_4_columns_inv, 32) == 1);

}

int main(void) {
    test_get_bit();
    test_calc_cell();
    return 0;
}
