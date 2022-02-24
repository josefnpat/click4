local ops = require"src.ops"
require"src.color"
sound = require"src.sound"

git_hash,git_count = "missing git.lua",-1
pcall( function() return require("src.git") end );

print("# Click4 Documentation")
print()
print("__v"..git_count.." #"..git_hash.."__")
print()

for opi,opv in pairs(ops) do
  print("## "..(opi-1)..": "..opv.label)
  print()
  local c = color(opi)
  print("* Info: "..(opv.info or "This op is not defined."))
  print("* ShortInfo: `"..(opv.short or "").."`")
  print("* Args: "..(opv.arg))
  local color = c[1]..","..c[2]..","..c[3]
  print("* Color: "..color.."\n")
  print("  ![](https://www.thecolorapi.com/id?rgb=rgb("..color..")&format=svg)")
  print("* Sound: "..opv.sound.." ["..(sound[opi-1].f)..".wav]") --todo
  print()
end
