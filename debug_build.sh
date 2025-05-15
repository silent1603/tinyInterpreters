#!/bin/bash


# Detect architecture if not provided
if [[ -n "$1" ]]; then
    ARCH="$1"
else
    case "$(uname -m)" in
        x86_64) ARCH="amd64" ;;
        i386|i686) ARCH="i386" ;;
        aarch64) ARCH="arm64" ;;
        *) echo "Unsupported architecture: $(uname -m)" ; exit 1 ;;
    esac
fi

# === Configuration ===
             
SOURCE_DIR="./sources"
BUILD_DIR="./build"
EXE_NAME="app_debug"
CPP_LIST="cpp_files.txt"
OBJ_LIST="obj_files.txt"


ARCH_DIR="$SOURCE_DIR/core/$ARCH"
START_FILE="$ARCH_DIR/start.S"
#MAIN_FILE="$ARCH_DIR/main.c"

# Chọn trình biên dịch
COMPILER="clang++"
C_COMPILER="clang"
ASM_COMPILER="clang"

# Compiler flags (C/C++/ASM)
CXXFLAGS="-g -Wall -Wextra -pedantic -O0 -Werror \
-nostdlib \
-fno-asynchronous-unwind-tables \
-Wa,--noexecstack \
-fno-builtin \
-fno-stack-protector \
-Wl,-e,_start \
-c"

CFLAGS="$CXXFLAGS"
ASFLAGS="$CXXFLAGS"
LDFLAGS="-g"

# === Chuẩn bị thư mục build ===
mkdir -p "$BUILD_DIR"
rm -f "$CPP_LIST" "$OBJ_LIST"

echo "Cleaning $BUILD_DIR..."
rm -f "$BUILD_DIR"/*.o "$BUILD_DIR/$EXE_NAME"

# === Tìm file nguồn ===
echo "Finding source files..."
find "$SOURCE_DIR" -name '*.cpp' > "$CPP_LIST"

# === Bắt đầu tính thời gian ===
start_time=$(date +%s.%N)

# === Biên dịch file start.S (nếu có) ===
if [[ -f "$START_FILE" ]]; then
    echo "Compiling $START_FILE..."
    obj_file="$BUILD_DIR/$(basename "${START_FILE%.S}.o")"
    $ASM_COMPILER $ASFLAGS "$START_FILE" -o "$obj_file" || {
        echo "Compile error in $START_FILE"
        exit 1
    }
    echo "$obj_file" >> "$OBJ_LIST"
else
    echo "No start.S found for arch '$ARCH'"
fi

# === Biên dịch main.c (nếu có) ===
# if [[ -f "$MAIN_FILE" ]]; then
#     echo "🛠️ Compiling $MAIN_FILE..."
#     obj_file="$BUILD_DIR/$(basename "${MAIN_FILE%.c}.o")"
#     $C_COMPILER $CFLAGS "$MAIN_FILE" -o "$obj_file" || {
#         echo "Compile error in $MAIN_FILE"
#         exit 1
#     }
#     echo "$obj_file" >> "$OBJ_LIST"
# else
#     echo "No main.c found for arch '$ARCH'"
# fi

# === Biên dịch tất cả file .cpp ===
echo "🛠️ Compiling C++ source files..."
while read -r src_file; do
    obj_file="$BUILD_DIR/$(basename "${src_file%.cpp}.o")"
    echo "Compiling $src_file -> $obj_file"
    $COMPILER $CXXFLAGS "$src_file" -o "$obj_file" || {
        echo "Compile error in $src_file"
        exit 1
    }
    echo "$obj_file" >> "$OBJ_LIST"
done < "$CPP_LIST"

# === Liên kết ===
echo "🔗 Linking with $COMPILER..."
$COMPILER $LDFLAGS $(cat "$OBJ_LIST") -o "$BUILD_DIR/$EXE_NAME" || {
    echo "Link error"
    exit 1
}

# === Kết thúc ===
end_time=$(date +%s.%N)
elapsed=$(echo "$end_time - $start_time" | bc)

echo "Debug build complete: $BUILD_DIR/$EXE_NAME"
echo "Build time: ${elapsed}s"
