#ifndef PLATFORMS_H
#define PLATOFRMS_H

#if SUPPORT_UTF8
#endif

# if defined(_WIN32)
#  define PLATFORMS_WINDOWS 1
# elif defined(__gnu_linux__)
#  define PLATFORMS_LINUX 1
# elif defined(__APPLE__) && defined(__MACH__)
#  define PLATFORMS_MACOS 1
# elif defined( __ANDROID__)
#  define PLATFORMS_ANDROID 1
# elif defined(__EMSCRIPTEN__)
#  define PLATFORMS_WEBASM 1
# else
#  error missing OS detection
# endif

#if PLATFORMS_WINDOWS
#define WIN32_LEAN_AND_MEAN
#define VC_EXTRALEAN
#define NOMINMAX
#include <windows.h>
#endif

#endif