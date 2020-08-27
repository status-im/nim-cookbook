# Context
#
# Discussion with PMunch on IRC to disallow the use of some variable
# in a code block

template undef(symbol: untyped{nkIdent}, body: untyped{nkStmtList}): untyped =
  block:
    template `symbol`(): untyped = {.error: "Cannot use `" & astToStr(`symbol`) & "` in this undef context".}
    body

var x = 100
echo x

undef(x):
  echo x
