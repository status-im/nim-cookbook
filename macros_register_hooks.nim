# Context
# https://forum.nim-lang.org/t/5450
#
# A macro that inserts code somewhere else
#
# ```
# registerHook post_foo:
#   echo “foo done. x=“, x
#
# ...
#
# proc foo =
#   let x = 10
#   runHooks post_foo
#

# Solution 1 - Using {.dirty.} templates
# --------------------------------------------------------------------------------------------------------

block:
  template post_foo(): untyped {.dirty.} =
    echo "foo done. x=", x

  proc foo =
    let x = 10
    post_foo()

# Solution 2 - Using a compile-time table
# --------------------------------------------------------------------------------------------------------

import tables, macros
block: #
  var hooks {.compileTime.}: Table[string, NimNode] # Can use custom hashing for NimNode instead of strings

  macro registerHook(name: untyped{ident}, body: untyped): untyped =
    result = newStmtList()
    result.add newProc(
      name = name,
      body = body,
      # need a dirty template to capture x
      procType = nnkTemplateDef,
      pragmas = nnkPragma.newTree(ident"dirty")
      )

    hooks[$name] = name

  macro runHooks(hook: untyped): untyped =
    result = newCall(hooks[$hook])

  registerHook post_foo:
    # need a dirty template to capture x
    echo "foo done. x=", x

  proc foo =
    let x = 10
    runHooks post_foo

  proc main() =
    foo()
    echo "The end."

  main()

# Solution 3 - Using macros as pragmas
# --------------------------------------------------------------------------------------------------------

import macros
block:
  macro registerHook(name: untyped{ident}, body: untyped): untyped =
    result = newStmtList()
    result.add newProc(
      name = name,
      body = body,
      # need a dirty template to capture x
      procType = nnkTemplateDef,
      pragmas = nnkPragma.newTree(ident"dirty")
      )

  macro runHook(pragma: untyped, moddedProc: untyped): untyped =
    result = moddedProc

    result[6].expectKind(nnkStmtList)
    result[6].add newCall(pragma)

  registerHook post_foo:
    # need a dirty template to capture x
    echo "foo done. x=", x

  proc foo {.runHook: post_foo.}=
    let x = 10

  proc main() =
    foo()
    echo "The end."

  main()
