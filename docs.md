# Click4 Documentation

__v19 #e955f74__

## 0: NOP

* Info: No Operation. :)
* ShortInfo: `nop`
* Args: 0
* Color: 31,31,31

  ![](https://www.thecolorapi.com/id?rgb=rgb(31,31,31)&format=svg)
* Sound: Rest note [rest.wav]

## 1: SET

* Info: Set contents of register defined by ARG1 with value of ARG2.
* ShortInfo: `*ARG1=ARG2`
* Args: 2
* Color: 255,0,0

  ![](https://www.thecolorapi.com/id?rgb=rgb(255,0,0)&format=svg)
* Sound: Note A [A.wav]

## 2: COPY

* Info: Copy the contents of register defined by ARG2 to the contents of register defined by ARG1.
* ShortInfo: `*ARG1=*ARG2`
* Args: 2
* Color: 255,109,0

  ![](https://www.thecolorapi.com/id?rgb=rgb(255,109,0)&format=svg)
* Sound: Note A# [As.wav]

## 3: INC

* Info: Increment register defined by ARG1.
* ShortInfo: `*ARG1=*ARG1+1`
* Args: 1
* Color: 255,218,0

  ![](https://www.thecolorapi.com/id?rgb=rgb(255,218,0)&format=svg)
* Sound: Note B [B.wav]

## 4: DEC

* Info: Decrement register defined by ARG1.
* ShortInfo: `*ARG1=*ARG1-1`
* Args: 1
* Color: 182,255,0

  ![](https://www.thecolorapi.com/id?rgb=rgb(182,255,0)&format=svg)
* Sound: Note C [C.wav]

## 5: NAND

* Info: NAND the values of registers defined by ARG2 and ARG3 and store in register defined by ARG1.
* ShortInfo: `*ARG1=*ARG2&*ARG3`
* Args: 3
* Color: 72,255,0

  ![](https://www.thecolorapi.com/id?rgb=rgb(72,255,0)&format=svg)
* Sound: Note C# [Cs.wav]

## 6: CRSZ

* Info: Increment program counter by 2 if register defined by ARG1 is zero.
* ShortInfo: `*ARG1==0?PC=PC+2`
* Args: 1
* Color: 0,255,36

  ![](https://www.thecolorapi.com/id?rgb=rgb(0,255,36)&format=svg)
* Sound: Note D [D.wav]

## 7: JMP

* Info: Change program counter to position X[ARG1,ARG2] Y[ARG3,ARG4].
* ShortInfo: `PC=X[*ARG1*16+*ARG2]+Y[*ARG3*16+*ARG4]`
* Args: 4
* Color: 0,255,145

  ![](https://www.thecolorapi.com/id?rgb=rgb(0,255,145)&format=svg)
* Sound: Note D# [Ds.wav]

## 8: RJMP

* Info: Increment program counter by ARG1 plus 1.
* ShortInfo: `PC=PC+*ARG1+1`
* Args: 1
* Color: 0,255,255

  ![](https://www.thecolorapi.com/id?rgb=rgb(0,255,255)&format=svg)
* Sound: Note E [E.wav]

## 9: LOAD

* Info: Load contents of X[R1+R2], Y[R3+R4] to R0.
* ShortInfo: `R0=X[R*16+R2]+Y[R3*16+R4]`
* Args: 0
* Color: 0,145,255

  ![](https://www.thecolorapi.com/id?rgb=rgb(0,145,255)&format=svg)
* Sound: Note F [F.wav]

## 10: SAVE

* Info: Save contents of R0 to X[R1+R2], Y[R3+R4].
* ShortInfo: `X[R*16+R2]+Y[R3*16+R4]=R0`
* Args: 0
* Color: 0,36,255

  ![](https://www.thecolorapi.com/id?rgb=rgb(0,36,255)&format=svg)
* Sound: Note F# [Fs.wav]

## 11: INPUT

* Info: Copy values of WASD or Up, Right, Down, Left into the register defined by ARG1.
* ShortInfo: `&ARG1=INPUT`
* Args: 1
* Color: 72,0,255

  ![](https://www.thecolorapi.com/id?rgb=rgb(72,0,255)&format=svg)
* Sound: Note G [G.wav]

## 12: DRAW

* Info: Draw area of screen with SourceX[R0+R1], SourceY[R2+R3], Width[R4] plus 1, Height[R5] plus 1, TargetX[R6+R7], TargetY[R8+R9]
* ShortInfo: `Draw X[R0*16+R1],Y[R2*16+R3] with W,H to X[R6*16+R7],Y[R8*16+R9]`
* Args: 0
* Color: 182,0,255

  ![](https://www.thecolorapi.com/id?rgb=rgb(182,0,255)&format=svg)
* Sound: Note G# [Gs.wav]

## 13: QSND

* Info: Enqueue sound from register defined by ARG1.
* ShortInfo: `enqueue_sound(&ARG1)`
* Args: 1
* Color: 255,0,218

  ![](https://www.thecolorapi.com/id?rgb=rgb(255,0,218)&format=svg)
* Sound: Alt 1 [alt1.wav]

## 14: N/A

* Info: This op is not defined.
* ShortInfo: `N/A`
* Args: 0
* Color: 255,0,109

  ![](https://www.thecolorapi.com/id?rgb=rgb(255,0,109)&format=svg)
* Sound: Alt 2 [alt2.wav]

## 15: N/A

* Info: This op is not defined.
* ShortInfo: `N/A`
* Args: 0
* Color: 223,223,223

  ![](https://www.thecolorapi.com/id?rgb=rgb(223,223,223)&format=svg)
* Sound: Alt 3 [alt3.wav]

