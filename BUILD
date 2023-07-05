load("//:toolchain/asm_library.bzl", "asm_library")

asm_library(
    name = "inner",
    srcs = ["src/say_hi.asm"],
    copts = ["-g", "dwarf2", "-I./",],
)

cc_library(
    name = "src",
    srcs = ["src/main.c", ":inner"],
)

cc_binary(
    name = "hello-world",
    deps = [
        ":src",
    ],
    linkopts = ["-no-pie"],
)
