# Context
# https://forum.nim-lang.org/t/5000#31345
#
# The goal is to approximate the dynamic creation of properties
# we use Nim dot operators for that and store everything in a Json object.

import json

{.experimental: "dotOperators".}

type
  Action = ref object
    properties: JsonNode

template `.`(action: Action, field: untyped): untyped =
  action.properties[astToStr(field)]

template `.=`(action: Action, field, value: untyped): untyped =
  action.properties[astToStr(field)] = %value


# Our main object, the fields are dynamic

var a = Action(
  properties: %*{
    "layer": 0,
    "add": true,
    "vis": false,
    "new_name": "fancy_name"
  }
)

# And usage, those are not real fields but there is no difference in syntax

echo a.new_name # "fancy_name"

a.algo = 10
echo a.algo     # 10
