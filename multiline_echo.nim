import macros

macro echoAll(body: untyped): untyped =
  result = newStmtList()
  
  for s in body:
    result.add newCall(bindSym"echo", s)
    
    
echoAll:
  "Hello"
  "World"
  1234 
