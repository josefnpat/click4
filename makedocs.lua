local ops = require"src.ops"
require"src.color"
sound = require"src.sound"

git_hash,git_count = "missing git.lua",-1
pcall( function() return require("src.git") end );

print("#Click4 Documentation")
print()
print("__v"..git_count.." #"..git_hash.."__")
print()

for opi,opv in pairs(ops) do
  print("##"..(opi-1)..": "..opv.label)
  local c = color(opi-1)
  print("Info: "..(opv.info or "This op is not defined."))
  print("Args: "..(opv.arg))
  print("Color: "..c[1]..","..c[2]..","..c[3])
  print("Sound: "..sound[opi-1].i.." ["..(sound[opi-1].f)..".wav]") --todo
  print()
end
