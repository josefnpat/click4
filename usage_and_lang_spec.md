# Click4 Usage and Language Specification

While Click4 only interprets a Click4 Cart (e.g. a 64x64 PNG), there is a way to circumvent the use of the Click4 fantasy console.

Using a text editor of your choice, the [click42ppm.lua](https://github.com/josefnpat/click4/blob/master/click42ppm.lua) script will convert source code into a PPM image file. Using ImageMagick (or any image renderer that can convert PPM to PNG) will give you an output that Click4 can interpret. This specific workflow is wrapped in [makecart.sh](https://github.com/josefnpat/click4/blob/master/makecart.sh).

This document seeks to outline the usage and language specification that is used in the \*.click4 file format.

## Usage

The easiest way to convert a \*.click4 file to a Click4 \*.png is to use the `makecart.sh` script.

Basic usage is as follows:
> `sh makecart.sh code background output`

Here is an example:
> `sh makecart.sh cart_templates/default.click4 \
> cart_templates/default_bg.png output.png`

This creates the default cart, [default.click4](https://github.com/josefnpat/click4/blob/master/cart_templates/default.click4).

## Language Specification

The \*.click4 language is parsed as simple tokens. Valid tokens are:
* Data: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
* Notes: REST A A# B C C# D D# E F F# G ALT1 ALT2 ALT3
* Operations: NOP SET COPY INC DEC NAND JMP RJMP LOAD SAVE INPUT DRAW QSND N/A

The `click42ppm.lua` script provides some helpful macros.

* Comment Macro: Start a line with `#` and the entire line will be discarded
* Label Macro: Start an op with `@` to create a label wich the RJMP Macro and JMP Macro can go to.
* RJMP Macro: Start an op with `!!` to create a 2 nibble RJMP series of ops. This will do a relative jump to the defined label.
* JMP Macro: Start an op with `!` to create a 5 nibble JMP series of ops. This will do an absolute jump to the defined label.

For example, the file test_label.click4:
```
NOP
# this is a comment
# start label
@start
# Skip the set command
!!skip
# Set 1 to register 0
SET 0 1
# skip label
@skip
# return to start
!start
```
Will produce the following ppm file:
```
$ lua click42ppm.lua test_label3.click4  | head -n15
P3
# click4 raw ppm
64 64
255
31      31      31      # [0] NOP(0)
0       255     255     # [1] RJMP(8)
255     109     0       # [2] 2(2)
255     0       0       # [3] SET(1)
31      31      31      # [4] 0(0)
255     0       0       # [5] 1(1)
0       255     145     # [6] JMP(7)
31      31      31      # [7] 0(0)
255     0       0       # [8] 1(1)
31      31      31      # [9] 0(0)
31      31      31      # [10] 0(0)
```