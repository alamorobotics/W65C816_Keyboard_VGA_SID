{{

#######################################
#                                     #
# W65C816_VGA_SID_05                  #
#                                     #
# Copyright (c) 2015 Fredrik Safstrom #
#                                     #
# See end of file for terms of use.   #
#                                     #
#######################################

############################# DESCIPTION ########################

Transfer from W65C816SXB to Propeller

1. W65C816SXB waits for PB7 (P15) to be low, $80
2. W65C816SXB puts data on PIA PA
3. W65C816SXB puts data on PIA PB with PB6 high. $40
4. Propeller waits for PB6 (P14) to go high.
5. Propeller reads PIA PA-PB and sets P15 high.
6, W65C816SXB waits for PB7 (P15)to be high, $80
7. W65C816SXB sets PIA PB6 (P14) low. $40
8. Propeller waits for PB6 (P14) to go low.
9. Propeller does it's thing...
10. Propeller sets P15 Low.

Note: All connections to the W65C816SXB board have a 1Kohm resistor in series...

########################### PIN ASSIGNMENTS #####################

  P0  - Data 0 - PIA PA0 via 1Kohm resistor
  P1  - Data 1 - PIA PA1 via 1Kohm resistor
  P2  - Data 2 - PIA PA2 via 1Kohm resistor
  P3  - Data 3 - PIA PA3 via 1Kohm resistor 
  P4  - Data 4 - PIA PA4 via 1Kohm resistor 
  P5  - Data 5 - PIA PA5 via 1Kohm resistor
  P6  - Data 6 - PIA PA6 via 1Kohm resistor
  P7  - Data 7 - PIA PA7 via 1Kohm resistor
  P8  - Address 0 - PIA PB0 via 1Kohm resistor
  P9  - Address 1 - PIA PB1 via 1Kohm resistor
  P10 - Address 2 - PIA PB2 via 1Kohm resistor
  P11 - Address 3 - PIA PB3 via 1Kohm resistor
  P12 - Address 4 - PIA PB4 via 1Kohm resistor
  P13 - Address 5 - 0 for VGA and 1 for SID  - PIA PB5 via 1Kohm resistor
  P14 - Flag Write - Wait for High from W65C816SXB, once propeller flag busy, W65C816SXB sets low. - PIA PB6 via 1Kohm resistor
  P15 - Flag BUSY - Set high by propeller when processing. - PIA PB7 via 1Kohm resistor, only input...    
  P16 - VGA VSync - 270 ohm resistor to D-Sub 14
  P17 - VGA HSync - 270 ohm resistor to D-Sub 13 
  P18 - VGA B0 - 560 ohm resistor to D-Sub 3
  P19 - VGA B1 - 270 ohm resistor to D-Sub 3
  P20 - VGA G0 - 560 ohm resistor to D-Sub 2
  P21 - VGA G1 - 270 ohm resistor to D-Sub 2
  P22 - VGA R0 - 560 ohm resistor to D-Sub 1
  P23 - VGA R1 - 270 ohm resistor to D-Sub 1
  P24 - SID Right Channel connect to amplifier for headphones or line in to computer 
  P25 - SID Left Channel connect to amplifier for headphones or line in to computer 
  P26 - 
  P27 - 
  P28 - I2C SCL
  P29 - I2C SDA
  P30 - Serial Tx
  P31 - Serial Rx

########################### REVISIONS ###########################

}}
CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  cols = vgatext#cols
  rows = vgatext#rows
  chrs = cols * rows
  base_pin = 16
  right_channel = 24
  left_channel = 25

OBJ

  vgatext : "vga_hires_text_4"
      SID : "SIDcog" 

VAR

  'sync long - written to -1 by VGA driver after each screen refresh
  long  sync
  'screen buffer - could be bytes, but longs allow more efficient scrolling
  long  screen[cols*rows/4]
  'row colors
  word  colors[rows]
  'cursor control bytes
  byte  cx0, cy0, cm0, cx1, cy1, cm1

  long params[4]                                    'The address of this array gets
  long param  
  

PUB start | i

  'start vga text driver
  vgatext.start(base_pin, @screen, @colors, @cx0, @sync)
  
  param := SID.start(right_channel, left_channel)  'Start the emulated SID chip in one cog 
  SID.resetRegisters                     'Reset all SID registers

  params[0] := @screen
  params[1] := @colors
  params[2] := @cx0
  params[3] := param
  
  ' Pass on Parameters.
  cognew(@VGA_SID_entry, @params)


  'fill screen with characters
  repeat i from 0 to chrs - 1
    screen.byte[i] := i // $81
    screen.byte[i] := " "

  repeat ' Forever

DAT                             org     0
VGA_SID_entry                   jmp     #initialization         'Start here...

'***************************************************
'* Constants                                       *
'***************************************************

' Used to figure out when to read the address and data
MAPPING_START                   long  $00004000
MAPPING_END                     long  $00000000
MAPPING_MASK                    long  $00004000

DIRECTION_MASK                  long  $00008000
COLOR_CLEAR_VALUE               long  %%0000_0300

'***************************************************
'* Variables                                       *
'***************************************************

' Parameters...
screen_address                  long  $0
color_address                   long  $0
cursor_address                  long  $0
sid_address                     long  $0    

' General Purpose Registers
r0                              long  $0        ' should typically equal 0
r1                              long  $0
r2                              long  $0
r3                              long  $0
r4                              long  $0
r5                              long  $0
r6                              long  $0

' current stuff
current_Col                     long $0
current_Row                     long $0
current_screen_add              long $0
current_Col_save                long $0
current_Row_save                long $0
current_screen_add_save         long $0
auto_increase                   long $0
x1                              long $0
y1                              long $0
x2                              long $0
y2                              long $0

'***************************************************
'* The driver itself                               *
'***************************************************

initialization

                        and     DIRA, DIRECTION_MASK                            ' Set input pins
                        or      DIRA, DIRECTION_MASK                            ' Set output pin.
                        and     OUTA, #0                                        ' Set output low.
                        mov     r0, PAR                                         ' Get parameter block address
                        rdlong  screen_address, r0                              ' Get virtual address
                        add     r0, #4                                          ' Next parameter address
                        rdlong  color_address, r0                               ' Get Screen address
                        add     r0, #4                                          ' Next parameter address
                        rdlong  cursor_address, r0                              ' Get color address
                        add     r0, #4                                          ' Next parameter address
                        rdlong  sid_address, r0                                 ' Get SID address
                        mov     current_screen_add,screen_address               ' Initiate screen address

                        mov     r0, color_address
                        mov     r2, #50                                         ' 50 rows
                        mov     r1, COLOR_CLEAR_VALUE

clear_loop              wrword  r1, r0                                          ' Write one long.
                        add     r0, #2                                          ' Increase address                                           
                        djnz    r2, #clear_loop                                 ' Decrease r3

                        mov     r1, #$20
                        jmp     #fill_screen

                        
main_loop
                        and     OUTA, #0                                        ' Set BUSY Flag Low.
                        waitpeq MAPPING_START, MAPPING_MASK                     ' Wait for Write Flag and VGA address. 
                        or      OUTA, DIRECTION_MASK                            ' Set BUSY Flag high.
                        mov     r0, INA                                         ' Get input to figure out register and data
                        waitpeq MAPPING_END, MAPPING_MASK                       ' Wait for Clear Write Flag and VGA address. 
                        mov     r1, r0                                          ' Copy input to r1 for data
                        shr     r0, #$8                                         ' Shift 8 bits down.
                        and     r0, #$3F                                        ' Address $7F00-$7F3F, 0-63 in r0
                        and     r1, #$FF                                        ' Data in r1

                        mov     r2, #jumptable                                  ' Get Jump Table                                  
                        add     r2, r0                                          ' Add address
                        jmp     r2                                              ' Jump to subroutine.

'***************************************************
'* Print a character $00                           *
'***************************************************
print_char
                        wrbyte  r1, current_screen_add                          ' "Print" by writing to shared memory.
                        add     current_screen_add, auto_increase               ' Add auto_increase to address
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set column $01                                  *
'***************************************************
set_col
                        mov     current_Col, r1                                 ' Set current column
                        call    #calculate_row_col                              ' Recaluclate current address
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set row $02                                     *
'***************************************************
set_row
                        mov     current_Row, r1                                 ' Set current row
                        call    #calculate_row_col                              ' Recaluclate current address
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set row color $03                               *
'***************************************************
set_row_color
                        mov     r0, current_Row                                 ' Get current row.         
                        add     r0, r0                                          ' Double
                        add     r0, color_address                               ' Add color address.
                        wrbyte  r1, r0                                          ' Write color byte to memory.
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set row background color $04                    *
'***************************************************
set_row_color_back
                        mov     r0, current_Row                                 ' Get current row.         
                        add     r0, r0                                          ' Double
                        add     r0, #1                                          ' Add 1 
                        add     r0, color_address                               ' Add color address.
                        wrbyte  r1, r0                                          ' Write color byte to memory.
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set auto increase $05                           *
'***************************************************
set_auto_increase
                        mov     auto_increase, r1                               ' Set auto increase
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Fill Screen $06                                 *
'***************************************************
fill_screen
                        mov     r0, screen_address                              ' Load screen address
                        mov     r2, r1                                          ' Copy r1
                        shl     r2, #8                                          ' Multiply by 256
                        add     r1, r2                                          ' Add to r1
                        mov     r2, r1                                          ' Copy r1
                        shl     r2, #16                                         ' Multiply by 65536
                        add     r1, r2                                          ' Add to r1, r1 now has four of it's original byte so to say.  
                        mov     r2, #50                                         ' 50 rows
                        mov     r3, #25                                         ' 100 chars but divided by 4.

fill_loop1              wrlong  r1, r0                                          ' Write one long.
                        add     r0, #4                                          ' Increase address                                           
                        djnz    r3, #fill_loop1                                 ' Decrease r3
                        mov     r3, #25                                         ' Refill loop counter
                        djnz    r2, #fill_loop1                                 ' Decrease r2

                        mov     current_screen_add, screen_address              ' Reset pointer to top of screen.
                        
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Fill color $07                                  *
'***************************************************
fill_color
                        mov     r0, color_address
                        mov     r2, #50                                         ' 50 rows

fill_loop2              wrbyte  r1, r0                                          ' Write one long.
                        add     r0, #2                                          ' Increase address                                           
                        djnz    r2, #fill_loop2                                 ' Decrease r3
                        
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Fill background color $08                       *
'***************************************************
fill_back
                        mov     r0, color_address
                        add     r0, #1
                        mov     r2, #50                                         ' 50 rows

fill_loop3              wrbyte  r1, r0                                          ' Write one long.
                        add     r0, #2                                          ' Increase address                                           
                        djnz    r2, #fill_loop3                                 ' Decrease r3
                        
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Scroll one row up $09                           *
'***************************************************
scroll_up
                        mov     r0, screen_address
                        add     r0, #100
                        mov     r1, screen_address
                        mov     r2, #49                                         ' 49 rows
                        mov     r3, #25                                         ' 100 chars but divided by 4.

scroll_loop1            rdlong  r4, r0                                          ' Read Word
                        add     r0, #4                                          ' Increase address                                           
                        wrlong  r4, r1
                        add     r1, #4                                          ' Increase address                                           
                        djnz    r3, #scroll_loop1                                 ' Decrease r3
                        mov     r3, #25                                         ' Refill loop counter
                        djnz    r2, #scroll_loop1                                 ' Decrease r2
                        jmp     #main_loop                                      ' Back to work


'***************************************************
'* Scroll one row down $0A                         *
'***************************************************
scroll_down
                        mov     r0, #300                                        ' 300 to r0 
                        shl     r0, #4                                          ' Multiply by 16, 300x16 = 4800
                        add     r0, #96                                         ' 4800 + 96 = 4896,                         
                        add     r0, screen_address
                        mov     r1, r0
                        add     r1, #100
                        mov     r2, #49                                         ' 49 rows
                        mov     r3, #25                                         ' 100 chars but divided by 4.

scroll_loop2            rdlong  r4, r0                                          ' Read Word
                        sub     r0, #4                                          ' Increase address                                           
                        wrlong  r4, r1
                        sub     r1, #4                                          ' Increase address                                           
                        djnz    r3, #scroll_loop2                                 ' Decrease r3
                        mov     r3, #25                                         ' Refill loop counter
                        djnz    r2, #scroll_loop2                                 ' Decrease r2
                        jmp     #main_loop 

'***************************************************
'* Set cursor 1 X $10                              *
'***************************************************
set_cursor1_X
                        wrbyte  r1, cursor_address                              ' Set Cursor X                       
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set cursor 1 Y $11                              *
'***************************************************
set_cursor1_Y
                        mov     r0, cursor_address                              ' Get Cursor address
                        add     r0, #1                                          ' Add Offset
                        wrbyte  r1, r0                                          ' Set Cursor Y                        
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set cursor 1 Mode $12                           *
'***************************************************
set_cursor1_mode
                        mov     r0, cursor_address                              ' Get Cursor address
                        add     r0, #2                                          ' Add Offset
                        wrbyte  r1, r0                                          ' Set Cursor Mode                        
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set cursor 2 X $13                              *
'***************************************************
set_cursor2_X
                        mov     r0, cursor_address                              ' Get Cursor address
                        add     r0, #3                                          ' Add Offset
                        wrbyte  r1, r0                                          ' Set Cursor X                        
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set cursor 2 Y $14                              *
'***************************************************
set_cursor2_Y
                        mov     r0, cursor_address                              ' Get Cursor address
                        add     r0, #4                                          ' Add Offset
                        wrbyte  r1, r0                                          ' Set Cursor Y                        
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set cursor 2 Mode $15                           *
'***************************************************
set_cursor2_mode
                        mov     r0, cursor_address                              ' Get Cursor address
                        add     r0, #5                                          ' Add Offset
                        wrbyte  r1, r0                                          ' Set Cursor Mode                        
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set x1 $16                                      *
'***************************************************
set_x1
                        mov     x1, r1                                          ' Set x1
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set y1 $17                                      *
'***************************************************
set_y1
                        mov     y1, r1                                          ' Set y1
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set x2 $18                                      *
'***************************************************
set_x2
                        mov     x2, r1                                          ' Set x2
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set y2 $19                                      *
'***************************************************
set_y2
                        mov     y2, r1                                          ' Set y2
                        jmp     #main_loop                                      ' Back to work


'***************************************************
'* Scroll box one row up $1A                       *
'***************************************************
box_up
                        call    #save_row_col                                   ' Save current X, Y and address
                        
                        mov     current_Col, x1
                        mov     current_Row, y1
                        call    #calculate_row_col                              ' Calcuate screen address for upper right corner.

                        mov     r1, current_screen_add                          ' Move screen address to write address
                        add     current_screen_add, #100                        ' Calculate next row
                        mov     r0, current_screen_add                          ' Move screen address to read address                                                  

                        mov     r5, x2                                          ' Calucate how many chars to copy
                        sub     r5, x1
                        add     r5, #1                                          ' Add one for right amount of bytes

                        mov     r2, y2                                          ' Calculate number of rows to copy                                          
                        sub     r2, y1                                          ' No need to add one since r0 and r1 is one row difference.
                        
                        mov     r3, r5                                          ' Set char counter

scroll_loop3            rdbyte  r4, r0                                          ' Read Byte
                        add     r0, #1                                          ' Increase address                                           
                        wrbyte  r4, r1                                          ' Write byte
                        add     r1, #1                                          ' Increase address                                           
                        djnz    r3, #scroll_loop3                               ' Decrease r3, chars to copy per row
                        mov     r1, current_screen_add                          ' Reset Write address, we already increaded it earlier. 
                        add     current_screen_add, #100                        ' Calculate next row
                        mov     r0, current_screen_add                          ' Reset read address.
                        mov     r3, r5                                          ' Refill char counter
                        djnz    r2, #scroll_loop3                               ' Decrease rows
                        call    #restore_row_col                                ' Restore
                        jmp     #main_loop                                      ' Back to work


'***************************************************
'* Scroll box one row down $1B                     *
'***************************************************
box_down
                        call    #save_row_col                                   ' Save current X, Y and address
                        
                        mov     current_Col, x1
                        mov     current_Row, y2
                        call    #calculate_row_col                              ' Calcuate screen address for lower left corner.

                        mov     r1, current_screen_add                          ' Move screen address to write address
                        sub     current_screen_add, #100                        ' Calculate previous row
                        mov     r0, current_screen_add                          ' Move screen address to read address                                                  

                        mov     r5, x2                                          ' Calucate how many chars to copy
                        sub     r5, x1
                        add     r5, #1                                          ' Add one for right amount of bytes

                        mov     r2, y2                                          ' Calculate number of rows to copy                                          
                        sub     r2, y1                                          ' No need to add one since r0 and r1 is one row difference.
                        
                        mov     r3, r5                                          ' Set char counter

scroll_loop4            rdbyte  r4, r0                                          ' Read Byte
                        add     r0, #1                                          ' Increase address                                           
                        wrbyte  r4, r1                                          ' Write byte
                        add     r1, #1                                          ' Increase address                                           
                        djnz    r3, #scroll_loop4                               ' Decrease r3, chars to copy per row
                        mov     r1, current_screen_add                          ' Reset read address, we already increaded it earlier. 
                        sub     current_screen_add, #100                        ' Calculate next row
                        mov     r0, current_screen_add                          ' Reset read address.
                        mov     r3, r5                                          ' Refill char counter
                        djnz    r2, #scroll_loop4                               ' Decrease rows
                        call    #restore_row_col                                ' Restore
                        jmp     #main_loop   

'***************************************************
'* Fill box $1C                                    *
'***************************************************
box_fill
                        call    #save_row_col                                   ' Save current X, Y and address

                        mov     r0, r1                                          ' Save r1
                        mov     current_Col, x1
                        mov     current_Row, y1
                        call    #calculate_row_col                              ' Calcuate screen address for upper right corner.
                        
                        mov     r1, r0                                          ' Restore r1
                        mov     r0, current_screen_add                          ' Move screen address to write address

                        mov     r5, x2                                          ' Calucate how many chars to copy
                        sub     r5, x1
                        add     r5, #1                                          ' Add one for right amount of cols

                        mov     r2, y2                                          ' Calculate number of rows to copy                                          
                        sub     r2, y1
                        add     r2, #1                                          ' Add one for right amount of rows
                        
                        mov     r3, r5                                          ' Set char counter

fill_loop4              wrbyte  r1, r0                                          ' Write byte
                        add     r0, #1                                          ' Increase address                                           
                        djnz    r3, #fill_loop4                                 ' Decrease r3, chars to fill per row
                        add     current_screen_add, #100                        ' Calculate next row
                        mov     r0, current_screen_add                          ' Reset write address.
                        mov     r3, r5                                          ' Refill char counter
                        djnz    r2, #fill_loop4                                 ' Decrease rows
                        call    #restore_row_col                                ' Restore
                        jmp     #main_loop  

'***************************************************
'* Sid register $00-$06, $20-$26                   *
'***************************************************
sid_00
                        mov     r2, sid_address                                 ' Get Sid address
                        add     r2, #$00                                        ' Add Offset
                        and     r0, #$1F                                        ' Remove $20 Offset 
                        add     r2, r0                        
                        wrbyte  r1, r2                                          ' Set SID Value                        
                        jmp     #main_loop  

'***************************************************
'* Sid register $07-$0D, $27-$2D                   *
'***************************************************
sid_01
                        mov     r2, sid_address                                 ' Get Sid address
                        add     r2, #$01                                        ' Add Offset
                        and     r0, #$1F                                        ' Remove $20 Offset 
                        add     r2, r0                        
                        wrbyte  r1, r2                                          ' Set SID Value                        
                        jmp     #main_loop  

'***************************************************
'* Sid register $0E-$14, $2E-$34                   *
'***************************************************
sid_02
                        mov     r2, sid_address                                 ' Get Sid address
                        add     r2, #$02                                        ' Add Offset
                        and     r0, #$1F                                        ' Remove $20 Offset 
                        add     r2, r0                        
                        wrbyte  r1, r2                                          ' Set SID Value                        
                        jmp     #main_loop  

'***************************************************
'* Sid register $15-$18, $35-$38                   *
'***************************************************
sid_03
                        mov     r2, sid_address                                 ' Get Sid address
                        add     r2, #$03                                        ' Add Offset
                        and     r0, #$1F                                        ' Remove $20 Offset 
                        add     r2, r0                        
                        wrbyte  r1, r2                                          ' Set SID Value                        
                        jmp     #main_loop  


'***************************************************
'* Sid register $19-$1F, $39-$3F Do Not Use        *
'***************************************************
sid_04
                        mov     r2, sid_address                                 ' Get Sid address
                        add     r2, #$04                                        ' Add Offset
                        and     r0, #$1F                                        ' Remove $20 Offset 
                        add     r2, r0                        
                        wrbyte  r1, r2                                          ' Set SID Value                        
                        jmp     #main_loop 

'***************************************************
'* Subroutines                                     *
'***************************************************

'***************************************************
'* calculate_row_col                               *
'***************************************************
calculate_row_col
                        mov     r1, current_Row                                 ' Get row.
                        shl     r1, #6                                          ' Multiply by 64
                        mov     r2, current_Row                                 ' Get row.
                        shl     r2, #5                                          ' Multiply by 32
                        add     r1,r2                                           ' Add to r1 
                        mov     r2, current_Row                                 ' Get row.
                        shl     r2, #2                                          ' Multiply by 4
                        add     r1,r2                                           ' Add to r1, each row is 100 chars, row*64+row*32+row*4 = 100*row
                        add     r1, current_Col                                 ' Add columns                                           
                        add     r1,screen_address                               ' Add address
                        mov     current_screen_add, r1                          ' Set current.
calculate_row_col_ret   
                        ret

'***************************************************
'* save_row_col                                    *
'***************************************************
save_row_col
                        mov     current_Row_save, current_Row                   ' Save row.
                        mov     current_Col_save, current_Col                   ' Save column                                           
                        mov     current_screen_add_save, current_screen_add     ' Save screen address
save_row_col_ret
                        ret

'***************************************************
'* restore_row_col                                 *
'***************************************************
restore_row_col
                        mov     current_Row, current_Row_save                   ' Restore row.
                        mov     current_Col, current_Col_save                   ' Restore column                                           
                        mov     current_screen_add, current_screen_add_save     ' Restore address
restore_row_col_ret
                        ret


'***************************************************
'* Jump table, used to map address to subroutine.  *
'***************************************************
jumptable
                       jmp    #print_char               '$00
                       jmp    #set_col                  '$01
                       jmp    #set_row                  '$02
                       jmp    #set_row_color            '$03
                       jmp    #set_row_color_back       '$04
                       jmp    #set_auto_increase        '$05
                       jmp    #fill_screen              '$06
                       jmp    #fill_color               '$07
                       jmp    #fill_back                '$08
                       jmp    #scroll_up                '$09
                       jmp    #scroll_down              '$0A
                       jmp    #print_char               '$0B
                       jmp    #print_char               '$0C
                       jmp    #print_char               '$0D
                       jmp    #print_char               '$0E
                       jmp    #print_char               '$0F

                       jmp    #set_cursor1_X            '$10
                       jmp    #set_cursor1_Y            '$11
                       jmp    #set_cursor1_mode         '$12
                       jmp    #set_cursor2_X            '$13
                       jmp    #set_cursor2_Y            '$14
                       jmp    #set_cursor2_mode         '$15
                       jmp    #set_x1                   '$16
                       jmp    #set_y1                   '$17
                       jmp    #set_x2                   '$18
                       jmp    #set_y2                   '$19
                       jmp    #box_up                   '$1A
                       jmp    #box_down                 '$1B
                       jmp    #box_fill                 '$1C
                       jmp    #print_char               '$1D
                       jmp    #print_char               '$1E
                       jmp    #print_char               '$1F

                       jmp    #sid_00                   '$20
                       jmp    #sid_00                   '$21
                       jmp    #sid_00                   '$22
                       jmp    #sid_00                   '$23
                       jmp    #sid_00                   '$24
                       jmp    #sid_00                   '$25
                       jmp    #sid_00                   '$26
                       jmp    #sid_01                   '$27
                       jmp    #sid_01                   '$28
                       jmp    #sid_01                   '$29
                       jmp    #sid_01                   '$2A
                       jmp    #sid_01                   '$2B
                       jmp    #sid_01                   '$2C
                       jmp    #sid_01                   '$2D
                       jmp    #sid_02                   '$2E
                       jmp    #sid_02                   '$2F

                       jmp    #sid_02                   '$30
                       jmp    #sid_02                   '$31
                       jmp    #sid_02                   '$32
                       jmp    #sid_02                   '$33
                       jmp    #sid_02                   '$34
                       jmp    #sid_03                   '$35
                       jmp    #sid_03                   '$36
                       jmp    #sid_03                   '$37
                       jmp    #sid_03                   '$38
                       jmp    #sid_04                   '$39
                       jmp    #sid_04                   '$3A
                       jmp    #sid_04                   '$3B
                       jmp    #sid_04                   '$3C
                       jmp    #sid_04                   '$3D
                       jmp    #sid_04                   '$3E
                       jmp    #sid_04                   '$3F                       

                       fit 496     'Warn if we used up memory...

{{

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}        