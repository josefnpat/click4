local ops = {}

table.insert(ops,{
  label = "NOP",
  info = "No Operation. :)",
  short = "nop",
  sound = "REST",
  exe = function(self)
  end,
  arg = 0,
})

table.insert(ops,{
  label = "SET",
  info = "Set contents of register defined by ARG1 with value of ARG2.",
  short = "*ARG1=ARG2",
  sound = "A",
  exe = function(self)
    self.registers[ self.args[1] ] = self.args[2]
  end,
  arg = 2,
})

table.insert(ops,{
  label = "COPY",
  info = "Copy the contents of register defined by ARG2 to the contents of register defined by ARG1.",
  short = "*ARG1=*ARG2",
  sound = "A#",
  exe = function(self)
    self.registers[ self.args[1] ] = self.registers[ self.args[2] ]
  end,
  arg = 2,
})

table.insert(ops,{
  label = "INC",
  info = "Increment register defined by ARG1.",
  short = "*ARG1=*ARG1+1",
  sound = "B",
  exe = function(self)
    local newval = self.registers[self.args[1]] + 1
    if newval > 2^bits-1 then
      newval = 0
    end
    self.registers[self.args[1]] = newval
  end,
  arg = 1,
})

table.insert(ops,{
  label = "DEC",
  info = "Decrement register defined by ARG1.",
  short = "*ARG1=*ARG1-1",
  sound = "C",
  exe = function(self)
    local newval = self.registers[self.args[1]] - 1
    if newval < 0 then
      newval = 2^bits-1
    end
    self.registers[self.args[1]] = newval
  end,
  arg = 1,
})

table.insert(ops,{
  label = "NAND",
  info = "NAND the values of registers defined by ARG2 and ARG3 and store in register defined by ARG1.",
  short = "*ARG1=*ARG2&*ARG3",
  sound = "C#",
  exe = function(self)
    local a = self.registers[ self.args[2] ]
    local b = self.registers[ self.args[3] ]
    self.registers[ self.args[1] ] = bit.band(bit.bnot(bit.band(a,b)),15)
  end,
  arg = 3,
})

table.insert(ops,{
  label = "CRSZ",
  info = "Increment program counter by 2 if register defined by ARG1 is zero.",
  short = "*ARG1==0?PC=PC+2",
  sound = "D",
  exe = function(self)
    if self.registers[ self.args[1] ] == 0 then
      self.pc = (self.pc + 2) % (width*height)
    end
  end,
  arg = 1,
})

table.insert(ops,{
  label = "JMP",
  info = "Change program counter to position X[ARG1,ARG2] Y[ARG3,ARG4].",
  short = "PC=X[*ARG1*16+*ARG2]+Y[*ARG3*16+*ARG4]",
  sound = "D#",
  exe = function(self)
    local x = (self.args[1])*16 + self.args[2]
    local y = (self.args[3])*16 + self.args[4]
    self.pc = (y*width+x-1)%(width*height)
  end,
  arg = 4,
})

table.insert(ops,{
  label = "RJMP",
  info = "Increment program counter by ARG1 plus 1.",
  short = "PC=PC+ARG1+1",
  sound = "E",
  exe = function(self)
    self.pc = (self.pc + self.args[1] + 1)%(width*height)
  end,
  arg = 1,
})

table.insert(ops,{
  label = "LOAD",
  info = "Load contents of X[R1+R2], Y[R3+R4] to R0.",
  short = "R0=X[R*16+R2]+Y[R3*16+R4]",
  sound = "F",
  exe = function(self)
    local x = (self.registers[1])*16 + self.registers[2]
    local y = (self.registers[3])*16 + self.registers[4]
    self.registers[0] = database:getMap(x+1,y+1)
  end,
  arg = 0,
})

table.insert(ops,{
  label = "SAVE",
  info = "Save contents of R0 to X[R1+R2], Y[R3+R4].",
  short = "X[R*16+R2]+Y[R3*16+R4]=R0",
  sound = "F#",
  exe = function(self)
    local x = (self.registers[1])*16 + self.registers[2]
    local y = (self.registers[3])*16 + self.registers[4]
    database:setMap(x+1,y+1,self.registers[0])
  end,
  arg = 0,
})


table.insert(ops,{
  label = "INPUT",
  info = "Copy values of WASD or Up, Right, Down, Left into the register defined by ARG1.",
  short = "*ARG1=INPUT",
  sound = "G",
  exe = function(self)
    self.registers[ self.args[1] ] =
      (love.keyboard.isDown("w",   "up") and 2^0 or 0)+
      (love.keyboard.isDown("d","right") and 2^1 or 0)+
      (love.keyboard.isDown("s", "down") and 2^2 or 0)+
      (love.keyboard.isDown("a", "left") and 2^3 or 0)
  end,
  arg = 1,
})

table.insert(ops,{
  label = "DRAW",
  info = "Draw area of screen with SourceX[R0+R1], SourceY[R2+R3], Width[R4] plus 1, Height[R5] plus 1, TargetX[R6+R7], TargetY[R8+R9]",
  short = "Draw X[R0*16+R1],Y[R2*16+R3] with W[R4],H[R5] to X[R6*16+R7],Y[R8*16+R9]",
  sound = "G#",
  exe = function(self)

    local sx = (self.registers[0])*16 + self.registers[1]
    local sy = (self.registers[2])*16 + self.registers[3]

    local w = self.registers[4]
    local h = self.registers[5]

    local tx = (self.registers[6])*16 + self.registers[7]
    local ty = (self.registers[8])*16 + self.registers[9]

    for x = sx,sx+w do
      for y = sy,sy+h do
        local val = database:getMap(x,y)
        self.buffer:setMap(tx+x-sx+1,ty+y-sy+1,val)
      end
    end

  end,
  arg = 0,
})

table.insert(ops,{
  label = "QSND",
  info = "Enqueue sound from register defined by ARG1.",
  short = "enqueue_sound(*ARG1)",
  sound = "ALT1",
  exe = function(self)
    self.qsound:enqueue(sounds[self.registers[self.args[1]]])
  end,
  arg = 1,
})

table.insert(ops,{
  label = "N/A",
  info = "N/A",
  short = "N/A",
  sound = "ALT2",
  arg = 0,
})

table.insert(ops,{
  label = "N/A",
  info = "N/A",
  short = "N/A",
  sound = "ALT3",
  arg = 0,
})

return ops
