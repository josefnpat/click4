# Click4 Documentation

__v15 #6a46a47__

## 0: NOP

* Info: No Operation. :)
* Args: 0
* Color: 255,0,218
* Sound: Rest note [rest.wav]

## 1: SET

* Info: Set contents of register defined by ARG2 with value of ARG1.
* Args: 2
* Color: 31,31,31
* Sound: Note A [A.wav]

## 2: COPY

* Info: Copy the contents of register defined by ARG1 to the contents of register defined by ARG2.
* Args: 2
* Color: 255,0,0
* Sound: Note A# [As.wav]

## 3: INC

* Info: Increment register defined by ARG1.
* Args: 1
* Color: 255,109,0
* Sound: Note B [B.wav]

## 4: DEC

* Info: Decrement register defined by ARG1.
* Args: 1
* Color: 255,218,0
* Sound: Note C [C.wav]

## 5: NAND

* Info: NAND the values of registers defined by ARG2 and ARG3 and store in register defined by ARG1.
* Args: 3
* Color: 182,255,0
* Sound: Note C# [Cs.wav]

## 6: CRSZ

* Info: Increment program counter by 2 if register defined by ARG1 is zero.
* Args: 1
* Color: 72,255,0
* Sound: Note D [D.wav]

## 7: JMP

* Info: Change program counter to position X[ARG1,ARG2] Y[ARG1,ARG2].
* Args: 4
* Color: 0,255,36
* Sound: Note D# [Ds.wav]

## 8: RJMP

* Info: Increment program counter by ARG1 plus 1.
* Args: 1
* Color: 0,255,145
* Sound: Note E [E.wav]

## 9: LOAD

* Info: Load contents of X[R1+R2], Y[R3+R4] to R0.
* Args: 0
* Color: 0,255,255
* Sound: Note F [F.wav]

## 10: SAVE

* Info: Save contents of R0 to X[R1+R2], Y[R3+R4].
* Args: 0
* Color: 0,145,255
* Sound: Note F# [Fs.wav]

## 11: INPUT

* Info: Copy values of WASD or Up, Right, Down, Left into the register defined by ARG1.
* Args: 1
* Color: 0,36,255
* Sound: Note G [G.wav]

## 12: DRAW

* Info: Draw area of screen with SourceX[R0\*16+R1], SourceY[R2\*16+R3], Width[R4] plus 1, Height[R5] plus 1, TargetX[R6\*16+R7], TargetY[R7\*16+R9]
* Args: 0
* Color: 72,0,255
* Sound: Note G# [Gs.wav]

## 13: QSND

* Info: Enqueue sound from register defined by ARG1.
* Args: 1
* Color: 182,0,255
* Sound: Alt 1 [alt1.wav]

## 14: N/A

* Info: This op is not defined.
* Args: 0
* Color: 255,0,218
* Sound: Alt 2 [alt2.wav]

## 15: N/A

* Info: This op is not defined.
* Args: 0
* Color: 255,0,109
* Sound: Alt 3 [alt3.wav]

