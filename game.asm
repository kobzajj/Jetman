; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 4/5
;
;	Jacob Kobza
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include stars.inc	
    include blit.inc
    include rotate.inc
    include game.inc
    include keys.inc	
	
.DATA

bouncingStar SPRITE <219, 339, 0, 1, 1, 1>
controlShip SPRITE <319, 400, 0, 1, 0, 0>
clickAsteroid SPRITE <100, 100, 0, 0, 0, 0>
controller SPRITE <200, 239, 0, 0, 0, 0>
mouseClick POINT <?, ?>
mouseLocation POINT <?, ?>
keyPress DWORD ?
menuCounter DWORD 0
spaceman BYTE "hardwellspaceman.wav",0

.CODE

EXTERNDEF STDCALL PlaySoundA : NEAR
  PlaySoundA PROTO STDCALL :DWORD,:DWORD,:DWORD
  PlaySound equ <PlaySoundA>
  SND_ASYNC = 1h
  SND_LOOP = 0008h
  SND_FILENAME = 20000h
  

;this function executes the main game loop
GameMain PROC USES eax ebx  mouseStatus:DWORD, keyDown:DWORD, keyUp:DWORD
	
	mov eax, mouseStatus
	shr eax, 8
	mov ebx, eax
	shr eax, 12
	and ebx, 0fffh
	mov mouseLocation.x, eax
	mov mouseLocation.y, ebx

	test eax, 3
	je NoClick

	mov mouseClick.x, eax
	mov mouseClick.y, ebx

NoClick:
	
	mov eax, keyDown
	mov keyPress, eax
	
	
	
	INVOKE GameLogic, 10, 1
	INVOKE GameRender
	
	ret
	
GameMain ENDP

;this function initializes all necessary constants and variables
GameInit PROC USES eax
	
	mov mouseClick.x, 219
	mov mouseClick.y, 339
	
	xor eax, eax
	mov mouseLocation.x, eax
	mov mouseLocation.y, eax
	
	pushad
	INVOKE PlaySound, OFFSET spaceman, 0, SND_ASYNC+SND_FILENAME+SND_LOOP
	popad
	
	ret
	
GameInit ENDP

;; Define the functions GameMain and GameInit
;; Since we have thoroughly covered defining functions in class, its up to you from here on out...
	
END
