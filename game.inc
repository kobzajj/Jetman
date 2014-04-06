; #########################################################################
;
;   game.inc - Includes for EECS205 Assignment 4/5
;
;	Jacob Kobza
; #########################################################################

;; These are library routines that you will call (but do NOT have to implement)
BeginDraw PROTO
EndDraw PROTO

;; You should not need to modify these prototypes (actually, it would probably be bad)
GameInit PROTO
GameMain PROTO mouseStatus:DWORD, keyDown:DWORD, keyUp:DWORD

;; Useful Library Routines
DrawString PROTO x:DWORD, y:DWORD, string:PTR BYTE 
DrawInt PROTO x:DWORD, y:DWORD, value:DWORD

;Defines the sprite and point structures
_SPRITE STRUCT
	x DWORD ?
	y DWORD ?
	a DWORD ?
	xx DWORD ?
	yy DWORD ?
	aa DWORD ?
_SPRITE ENDS

SPRITE TYPEDEF _SPRITE

_POINT STRUCT
	x DWORD ?
	y DWORD ?
_POINT ENDS

;;post struct contains data for a post the character is avoiding
POST STRUCT
	upperHeight DWORD -100
	lowerHeight DWORD -100
	leftBound DWORD 639
	rightBound DWORD 689
POST ENDS

POINT TYPEDEF _POINT
;; Defines all the functions in the render and logic files
GameRender PROTO
GenRandomHeight PROTO
DrawRectangle PROTO xleft:DWORD, xright:DWORD, ybottom:DWORD, ytop:DWORD, color:BYTE
GameLogic PROTO xinc:DWORD, yinc:DWORD
MoveInDirection PROTO mySprite:PTR SPRITE, factor:DWORD, boundaryType:DWORD
RotateSprite PROTO mySprite:PTR SPRITE, factor:DWORD


EXTERNDEF lpTyroneBmp : DWORD

;Defines the sprites to create
EXTERNDEF bouncingStar:SPRITE 
EXTERNDEF controlShip:SPRITE 
EXTERNDEF clickAsteroid:SPRITE
EXTERNDEF controller:SPRITE 

;Defines the point structures to create
EXTERNDEF mouseClick:POINT
EXTERNDEF mouseLocation:POINT
EXTERNDEF keyPress:DWORD

;Defines the additional bitmaps used in the program
EXTERNDEF fighter_001:EECS205BITMAP
EXTERNDEF asteroid_005:EECS205BITMAP
EXTERNDEF jetman:EECS205BITMAP
EXTERNDEF nuke_000:EECS205BITMAP
EXTERNDEF nuke_001:EECS205BITMAP
EXTERNDEF nuke_002:EECS205BITMAP
EXTERNDEF nuke_003:EECS205BITMAP
EXTERNDEF nuke_004:EECS205BITMAP
EXTERNDEF nuke_005:EECS205BITMAP

;Defines additional variables that I need to use
EXTERNDEF randomSeed:DWORD
EXTERNDEF score:DWORD
EXTERNDEF loopCounter:DWORD
EXTERNDEF postArray:POST
EXTERNDEF started:DWORD
EXTERNDEF highScore:DWORD
EXTERNDEF postAddCount:DWORD
EXTERNDEF postMoveCount:DWORD
EXTERNDEF nextPost:DWORD
EXTERNDEF moveSpacing:DWORD
EXTERNDEF addSpacing:DWORD
EXTERNDEF spacingCount:DWORD
EXTERNDEF nukeCounter:DWORD