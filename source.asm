;
; Simple Line Tracking Robot.
;
; @author Akeda Bagus <admin@gedex.web.id>
; @copyright 2006
; @license MIT License
;
; Left      Right
;
; 7 6 5 4 3 2 1 0
;   + e -   - e +
; 0 1 1 0   0 0 0 0 60  Turns hard right
; 0 1 1 0   1 1 0 0 6C  Turns soft right
; 0 0 0 0   0 1 1 0 06  Turns hard left
; 0 0 1 1   0 1 1 0 36  Turns soft left
; 0 1 1 0   0 1 1 0 66  Moves forward
; 0 0 1 1   1 1 0 0 3C  Moves backward

;
; Port connected to to H-Bridge driver
; Kir means Kiri or left motor
; Kan means Kanan or right motor
;
enKir   bit   p2.5
negKir  bit   p2.4
posKir  bit   p2.6

enKan   bit   p2.2
posKan  bit   p2.1
negKan  bit   p2.3

pwmKa   EQU 30h
pwmKi   EQU 31h

;
; Sensor positions, from left to right
; [4]  [3] [2] [1]   [0]
;
sKaLuar  bit    p1.0
sKaDalam bit    p1.1
sTengah  bit    p1.2
sKiDalam bit    p1.3
sKiLuar  bit    p1.4

org 0h
  sjmp init

org 0bh
  Push PSW
  djnz r7, cek
  mov  r7, #255
  clr  enKan        ; Duty Cycle right motor 0
  clr  enKir        ; Duty Cycle left motor  0

cek:
  xch  a,r7
  cjne a, pwmKa, lanjut
  setb enKan        ; Duty Cycle right motor 1

lanjut:
  cjne a, pwmKi, lanjut2
  setb enKir        ; Duty Cycle left motor  1

lanjut2:
  xch  a, r7
  pop  PSW
  reti

init:
  mov  th0,   #0cch
  mov  tmod,  #02h     ; timer0 mode 2
  clr  tr0
  mov  ie,    #82h     ; interrupt timer0
  mov  pwmKa, #0
  mov  pwmKi, #0
  mov  dptr, #pwm_
  setb tr0             ; timer0 on

; Main loop
mulai:
  call scan
  sjmp mulai

; e maju, c serkir, 6 serkan
scan:
  mov a, p1
  anl a, #0eh
  jz  cekKiKa
  mov p2, #66h

mundur: ; serkan / serkir / maju, 0,6,c,e
  mov  B,     A
  movc A,     @A+dptr
  mov  pwmKi, A
  mov  A,     B
  inc  A
  movc A,     @A+dptr
  mov  pwmKa, A
  ret

mundur_:
  mov  p2, #3Ch
  sjmp mundur

cekKiKa:
  jnb sKiLuar, _kanan

_kiri:
  mov pwmKi, #40h
  mov pwmKa, #50h
  mov p2,    #36h
  ret

_kanan:
  jnb sKaLuar, mundur_
  mov pwmKi,   #50h
  mov pwmKa,   #40h
  mov p2,      #6Ch
  ret

MUNDUR:
  mov pwmKa, #04Fh
  mov pwmKi, #040h
  mov p2,    #3Ch
  ret

MAJU:
  mov pwmKa, #09Fh
  mov pwmKi, #08Ch
  mov p2,    #66h
  ret

SERKAN:
  mov pwmKi, #0CFh
  mov pwmKa, #0A0h
  mov p2,    #6Ch
  ret

SERKIR:
  mov pwmKi, #0A0h
  mov pwmKa, #0CFh
  mov p2,    #36h
  ret

FASTSTOP:
  mov p2,    #0
  mov pwmKi, #0
  mov pwmKa, #0
  ret

BKAN:
  lcall      FASTSTOP
  mov pwmKi, #0CFh
  mov pwmKa, #50h
  mov p2,    #60h
  ret

BKIR:
  lcall      FASTSTOP
  mov pwmKi, #50h
  mov pwmKa, #0CFh
  mov p2,    #06h
  ret

delay2:
  push 2
  mov  R2, #3
_delay2:
  call delay1
  djnz R2, _delay2
  pop  2
  ret

delay1:
  push 1
  mov  R1, #0
_delay1:
  call _delay_
  djnz R1, _delay1
  pop  1
  ret

_delay_:
  push 0
  mov  R0,#0
  djnz R0,$
  pop  0
  ret

; left right
pwm_:
  DB  01Bh, 030h ; mundur pelan 0
  DB  08Fh, 03Ah ; serKan++     2
  DB  070h, 090h ; maju pelan   4
  DB  080h, 04Fh ; serkan       6
  DB  03Ah, 080h ; serkir++     8
  DB  070h, 09Fh ;        10    a
  DB  050h, 080h ; serkir       12  c
  DB  0D0h, 085h ; maju         14  e

abiz_:
  end
