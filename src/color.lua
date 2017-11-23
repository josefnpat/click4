-- http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c

--[[
 * Converts an HSV color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes h, s, and v are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  v       The value
 * @return  Array           The RGB representation
]]
function hsvtorgb(h, s, v, a)
  local r, g, b

  local i = math.floor(h * 6);
  local f = h * 6 - i;
  local p = v * (1 - s);
  local q = v * (1 - f * s);
  local t = v * (1 - (1 - f) * s);

  i = i % 6

  if i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  elseif i == 5 then r, g, b = v, p, q
  end

  return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), math.floor(a * 255)
end

function color(index)
  local i = index-1
  if i == 0 then
    return {hsvtorgb(0,0,0.125,1)}
  elseif index == 16 then
    return {hsvtorgb(0,0,0.875,1)}
  else
    local h = (i-1)%14/14
    local s = 1
    local v = 1
    return {hsvtorgb(h,s,v,1)}
  end
end
