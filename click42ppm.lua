require"src.color"

local function readAll(filename)
  local f = io.open(filename, "rb")
  local content = f:read("*all")
  f:close()
  return content
end

local function split(s, delimter)
  local result = {}
  for match in (s..delimter):gmatch("(.-)"..delimter) do
    table.insert(result, match)
  end
  return result
end

local filename = arg[1]
assert(filename~=nil,"Missing filename")
local raw = readAll(filename)
local lines = split(raw,"\n")
local symbols = {}

for _,line in pairs(lines) do
  if string.sub(line,1,1) ~= "#" then
    for i,v in pairs( split(line," ") ) do
      if v ~= "" then
        table.insert(symbols,v)
      end
    end
  end
end

function position_to_jmp_args(pos)
  local x = (pos/64)%1*64
  local y = math.floor(pos/64)

  local x1 = math.floor(x/16)
  local x2 = (x/16)%1*16
  local y1 = math.floor(y/16)
  local y2 = (y/16)%1*16

  --[[
  io.stderr:write(
    pos.."\t"..
    "[x:"..x..",y:"..y.."]\t"..
    "JMP "..x1.." "..x2.." "..y1.." "..y2.."\n"
  )
  --]]

  return x1,x2,y1,y2
end

local symbols_clean = {}
local labels = {}
local ops = require "src.ops"
for _,op in pairs(symbols) do

  local valid = false

  for index,testop in pairs(ops) do
    if index-1 == tonumber(op) then
      table.insert(symbols_clean, {symbol=op,value=index-1})
      valid = true
      break
    elseif testop.label == op then
      table.insert(symbols_clean, {symbol=op,value=index-1})
      valid = true
      break
    elseif testop.sound == op then
      table.insert(symbols_clean, {symbol=op,value=index-1})
      valid = true
      break
    end
  end

  if string.sub(op,1,1) == "@" then
    local label = string.sub(op,2)
    local label_pos = #symbols_clean
    local x1,x2,y1,y2 = position_to_jmp_args(label_pos)
    if labels[label] then
      io.stderr:write("Warning: skipping already defined label `"..label.."` at symbol position "..label_pos.."\n")
    else
      --io.stderr:write("Defining label `"..label.."` at symbol position "..label_pos.."\n")
      labels[label] = label_pos
    end
    valid = true
  elseif string.sub(op,1,2) == "!!" then
    local label = string.sub(op,3)
    --io.stderr:write("rjmp to label `"..label.."`\n")
    table.insert(symbols_clean, {rjmp=label})--RJMP
    table.insert(symbols_clean, {})--arg1
    valid = true
  elseif string.sub(op,1,1) == "!" then
    local label = string.sub(op,2)
    --io.stderr:write("jmp to label `"..label.."`\n")
    table.insert(symbols_clean, {jmp=label})--JMP
    table.insert(symbols_clean, {})--arg1
    table.insert(symbols_clean, {})--arg2
    table.insert(symbols_clean, {})--arg3
    table.insert(symbols_clean, {})--arg4
    valid = true
  end

  if valid then
    if #symbols_clean >= 64*64 then
      io.stderr:write("Warning: symbol `"..op.."` outside of cart size at symbol position "..#symbols_clean.."\n")
    end
  else
    io.stderr:write("Warning: skipping unknown symbol `"..op.."` at symbol position "..#symbols_clean.."\n")
  end
end

-- Update JMP/RJMP targets
for symbol_index,symbol in pairs(symbols_clean) do

  if symbol.rjmp then
    local offset = 0
    if labels[symbol.rjmp] then
      offset = labels[symbol.rjmp] - symbol_index - 2
      if offset > 15 then
        io.stderr:write("Warning: rjmp offset is greater than 15 ("..offset..")`\n")
        offset = 0
      end
    else
      io.stderr:write("Warning: skipping unknown rjmp `"..symbol.rjmp.." at symbol position "..symbol_index.."`\n")
    end
    symbols_clean[symbol_index+0] = {symbol="RJMP",value=8}
    symbols_clean[symbol_index+1] = {symbol=offset,value=offset}
  end

  if symbol.jmp then
    local x1,x2,y1,y2 = 0,0,0,0
    if labels[symbol.jmp] then
      x1,x2,y1,y2 = position_to_jmp_args(labels[symbol.jmp])
    else
      io.stderr:write("Warning: skipping unknown jmp `"..symbol.jmp.." at symbol position "..symbol_index.."`\n")
    end
    symbols_clean[symbol_index+0] = {symbol="JMP",value=7}
    symbols_clean[symbol_index+1] = {symbol=x1,value=x1}
    symbols_clean[symbol_index+2] = {symbol=x2,value=x2}
    symbols_clean[symbol_index+3] = {symbol=y1,value=y1}
    symbols_clean[symbol_index+4] = {symbol=y2,value=y2}
  end

end


print("P3")
print("# click4 raw ppm")
print("64 64")
print("255")
for i = 1,64*64 do
  local v = symbols_clean[i] or {symbol="0",value=0}
  local c = color(v.value+1)
  print(c[1],c[2],c[3],"# ["..i.."] "..v.symbol.."("..v.value..")")
end
