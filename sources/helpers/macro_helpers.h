#ifndef MACRO_HELPERS_H
#define MACRO_HELPERS_H

// string support
#define STRINGIFY(x) #x
#define TO_STRING(x) STRINGIFY(x)

//bit flag support
#define  HAS_FLAG(value, flag) (((value) & (flag)) != 0)
#define  SET_FLAG(value, flag) ((value) |= (flag))
#define UNSET_FLAG(value, flag) ((value) &= ~(flag))
#endif