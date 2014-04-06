; #########################################################################
;
;   logic.asm - Assembly file for EECS205 Assignment 4/5
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
	
;;-------------------------------------------------------------------------------------------------------------------------------------
	
.DATA

	started DWORD 0;;contains 0 if new game, 1 if playing, 2 if game over
	loopCounter DWORD 0;;counts to 30 to limit movement of jetman character

;;--------------------------------------------------------------------------------------------------------------------------------------
	
.CODE

;This function calls other logic functions to do calculations for the screen
GameLogic PROC USES eax ebx ecx edx esi edi xinc:DWORD, yinc:DWORD

	;;jumps to GameOver if the user's game is over
	cmp started, 2
	je GameOver
	
	;;checks for space bar, if clicked moves character up
	cmp keyPress, VK_SPACE
	jne GoingDown
	mov started, 1
	mov controller.yy, -50
	jmp WriteJet
	
;;if spacebar not active, moves character down with acceleration 1
;;velocity increases by 1 each time	
GoingDown:
	cmp loopCounter, 30
	jl SkipJetMove
	mov loopCounter, 0
	cmp started, 0
	je SkipJetMove
	cmp controller.yy, 0
	jl SetDownward
	add controller.yy, 1
	jmp WriteJet
SetDownward:
	mov controller.yy, 1
	
	
;;write the new location of the character below
WriteJet:
	
	;;check for wall crash conditions
	cmp controller.y, 20
	jle Crash
	cmp controller.y, 440
	jge Crash
	mov edi, OFFSET postArray
	xor esi, esi
L2:
	;;check for post crash conditions
	cmp (POST PTR [edi]).leftBound, 250
	jg NoCollision
	cmp (POST PTR [edi]).leftBound, 100
	jl NoCollision
	
	;;if it gets past here, leftBound and rightBound are in the target range
	mov ecx, controller.y
	mov edx, (POST PTR [edi]).lowerHeight
	add edx, 10
	cmp ecx, edx
	jg UpperCheck
	jmp Crash
	
UpperCheck:
	mov edx, (POST PTR [edi]).upperHeight
	sub edx, 10
	cmp ecx, edx
	jge Crash
	
;;if no collision, check other posts, loop through all
NoCollision:
	
	add esi, 1
	add edi, 16
	cmp esi, 10
	jl L2
	
	jmp NoCrash
	
;;executes if there is a collision
Crash:
	mov controller.yy, 0
	;;set game over conditions
	mov started, 2
	mov nukeCounter, 1
	mov edx, score
	cmp edx, highScore
	jle NotHighScore
	mov highScore, edx
NotHighScore:
	
NoCrash:
	;;writes the new location of the character
	INVOKE MoveInDirection, offset controller, 1, 1
	
SkipJetMove:

	

	add loopCounter, 1;
	
;;resets all variables if game over condition occurs so it can begin again
GameOver:
	
	;;check for 'r' key to be pressed for new game
	cmp keyPress, VK_R
	jne DontRestart
	mov started, 0
	mov controller.y, 239
	
	mov score, 0
	mov postAddCount, 0
	mov postMoveCount, 0
	mov nextPost, 0
	mov moveSpacing, 5
	mov addSpacing, 2000
	mov spacingCount, 0
	mov edi, OFFSET postArray
	xor esi, esi
L3:
	mov (POST PTR [edi]).leftBound, 639
	mov (POST PTR [edi]).rightBound, 689
	mov (POST PTR [edi]).upperHeight, -100
	mov (POST PTR [edi]).lowerHeight, -100
	add edi, 16
	add esi, 1
	cmp esi, 10
	jl L3
	
DontRestart:
	
	ret
GameLogic ENDP

;;--------------------------------------------------------------------------------------------------------------------------------------

;Moves the sprite in a direction specified by xx and yy in the sprite
;Parameter 'type' is 0 if it bounces, 1 if it goes through screen to other side
MoveInDirection PROC USES eax ebx esi mySprite:PTR SPRITE, factor:DWORD, boundaryType:DWORD

	mov esi, mySprite
	
	cmp (SPRITE PTR[esi]).x, 0
	jle SwitchX
	cmp (SPRITE PTR[esi]).x, 639
	jge SwitchX
	jmp CheckY
	
SwitchX:
	mov eax, (SPRITE PTR[esi]).xx
	not eax
	add eax, 1
	mov (SPRITE PTR[esi]).xx, eax

;check the y coordinate is on the screen
CheckY:
	cmp (SPRITE PTR[esi]).y, 0
	jle SwitchY
	cmp (SPRITE PTR[esi]).y, 479
	jge SwitchY
	jmp CheckDone
	
SwitchY:
	mov eax, (SPRITE PTR[esi]).yy
	not eax
	add eax, 1
	mov (SPRITE PTR[esi]).yy, eax
	
;once the checking is done, the sprite movement is calculated
CheckDone:
	mov eax, (SPRITE PTR[esi]).yy
	imul factor
	mov ebx, eax
	mov eax, (SPRITE PTR[esi]).xx
	imul factor	
	add eax, (SPRITE PTR[esi]).x
	add ebx, (SPRITE PTR[esi]).y
	mov (SPRITE PTR[esi]).x, eax
	mov (SPRITE PTR[esi]).y, ebx
	
	ret

MoveInDirection ENDP

;;------------------------------------------------------------------------------------------------------------------------------------------

;rotates the sprite by a specified angle and factor
RotateSprite PROC USES eax esi mySprite:PTR SPRITE, factor:DWORD

mov esi, mySprite

mov eax, (SPRITE PTR[esi]).aa
mul factor
add eax, (SPRITE PTR[esi]).a
mov (SPRITE PTR[esi]).a, eax

ret

RotateSprite ENDP

;; Define the function GameLogic
;; Since we have thoroughly covered defining functions in class, its up to you from here on out...
	
END
