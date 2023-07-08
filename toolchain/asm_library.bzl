def _cxx_compile(ctx, src):
    pre = ctx.label.workspace_root
    if len(pre) > 0:
        pre = pre + "/"
    out = ctx.actions.declare_file(src.short_path + ".o")

    args = ctx.actions.args()
    args.add("-f")
    args.add("elf64")
    args.add_all(ctx.attr.copts)
    for d in ctx.attr.includes:
        args.add("-I{pre}{dir}".format(pre = pre, dir = d))        
    args.add("-o", out)
    args.add(src)

    ctx.actions.run(
        executable = "/usr/bin/yasm",
        outputs = [out],
        inputs = [src] + ctx.files.hdrs,
        arguments = [args],
        mnemonic = "AsmCompile",
        use_default_shell_env = True,
    )

    return out

def _compile_sources(ctx):
    objs = []
    for src in ctx.files.srcs:
        if src.basename.endswith(".asm"):
            obj = _cxx_compile(
                ctx,
                src = src,
            )
            objs.append(obj)

    return objs

def _asm_library_impl(ctx):
    objs = _compile_sources(ctx)
    return [
        DefaultInfo(
            files = depset(objs),
        )
    ]

asm_library = rule(
    _asm_library_impl,
    attrs = {
        "hdrs": attr.label_list(
            allow_files = [".asm"],
            doc = "Pre-include files for this library",
        ),
        "includes": attr.string_list(
            doc = "List of directories that should be browsed when looking for headers.",
        ),
        "srcs": attr.label_list(
            allow_files = [".asm"],
            doc = "Source files to compile for this library",
        ),
        "copts": attr.string_list(
            doc = "Compile flags for this library",
        ),
    },
    doc = "Builds a library from asm source code",
)
