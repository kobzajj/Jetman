; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;   Jacob Kobza
;   January 20th, 2014
;
; #########################################################################

;This program displays 17 stars in an X shape on the screen using the
;DrawStarReg routine, which takes esi and edi as the x and y parameters

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include stars.inc

.CODE

; Routine which uses DrawStarReg to create all the stars
; Screen dimensions are 640X480
DrawAllStars PROC 

    ;The coordinates below create an X of stars on the screen
    ;Each pair of mov statements specifies the coordinates on the screen
    ;of the next star to be placed.
    mov esi, 320
    mov edi, 240
    call DrawStarReg
    mov esi, 64
    mov edi, 48
    call DrawStarReg
    mov esi, 128
    mov edi, 96
    call DrawStarReg
    mov esi, 192
    mov edi, 144
    call DrawStarReg
    mov esi, 256
    mov edi, 192
    call DrawStarReg
    mov esi, 384
    mov edi, 288
    call DrawStarReg
    mov esi, 448
    mov edi, 336
    call DrawStarReg
    mov esi, 512
    mov edi, 384
    call DrawStarReg
    mov esi, 576
    mov edi, 432
    call DrawStarReg
    mov esi, 576
    mov edi, 48
    call DrawStarReg
    mov esi, 512
    mov edi, 96
    call DrawStarReg
    mov esi, 448
    mov edi, 144
    call DrawStarReg
    mov esi, 384
    mov edi, 192
    call DrawStarReg
    mov esi, 256
    mov edi, 288
    call DrawStarReg
    mov esi, 192
    mov edi, 336
    call DrawStarReg
    mov esi, 128
    mov edi, 384
    call DrawStarReg
    mov esi, 64
    mov edi, 432
    call DrawStarReg
    ret             ;; Don't delete this line
    
DrawAllStars ENDP

END
