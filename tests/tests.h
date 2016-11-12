#ifndef TESTS_H_
#define TESTS_H_

#define ASSERT(str, expr)  \
    if (!expr) \
        printf("  %s failed at line %i\n", str, __LINE__)

#endif
