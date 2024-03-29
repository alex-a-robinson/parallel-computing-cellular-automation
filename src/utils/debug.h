#ifndef DEBUG_H_
#define DEBUG_H_

#define FTL (1) // Fatal
#define ERR (2) // Error
#define WRN (3) // Warning
#define IFO (4) // Info
#define DBG (5) // Debug

#define DEBUG_LEVEL (4)

#define LOG(level, ...)                                                                                                \
    do {                                                                                                               \
        if (level <= DEBUG_LEVEL) {                                                                                    \
            fprintf(stderr, __VA_ARGS__);                                                                              \
            fflush(stderr);                                                                                            \
        }                                                                                                              \
    } while (0)

/*
Example use:

LOG(FTL, "fatel");
LOG(ERR, "err");
LOG(WRN, "warn");
LOG(IFO, "info");
LOG(DBG, "dbg");
*/

#endif
