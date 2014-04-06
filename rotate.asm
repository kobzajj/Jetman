; #########################################################################
;
;   rotate.asm - Assembly file for EECS205 Assignment 3
;	Jacob Kobza, 2/14/14
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include trig.inc		; Useful prototypes
    include rotate.inc		; 	and definitions


.DATA
	;; You may declare helper variables here, but it would probably be better to use local variables

.CODE

;this function calls the BlitReg function in blit.asm using stack-passed parameters
BasicBlit PROC USES esi ebx ecx edx lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD
mov esi, xcenter
mov edi, ycenter
mov edx, lpBmp
call BlitReg

ret

BasicBlit ENDP

;-------------------------------------------------------------------------------------------------------------------------------

;this function creates an image that rotates using the arrow keys
RotateBlit PROC lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:DWORD
LOCAL sina:FIXED, cosa:FIXED, shiftX:DWORD, shiftY:DWORD, dstWidth:DWORD, dstHeight:DWORD, 
dstX:DWORD, dstY:DWORD, srcX:DWORD, srcY:DWORD, writeCoordX:DWORD, writeCoordY:DWORD, bitmapval:BYTE

;initialize local variables
mov shiftX, 0
mov shiftY, 0
mov dstWidth, 0

;call the fixed cos and sin functions to get the trig values
INVOKE FixedSin, angle
mov sina, eax
INVOKE FixedCos, angle
mov cosa, eax

;moves the address of the bitmap into a register
mov esi, lpBmp

;use the sine and cosine values to calculate vertical and horizontal shifts
mov ebx, sina
mov ecx, cosa
mov eax, (EECS205BITMAP PTR [esi]).dwWidth
mov dstWidth, eax
imul ecx
sar eax, 17
mov shiftX, eax
mov eax, (EECS205BITMAP PTR [esi]).dwHeight
add dstWidth, eax
mov edx, dstWidth
mov dstHeight, edx
imul ebx
sar eax, 17
sub shiftX, eax
mov eax, (EECS205BITMAP PTR [esi]).dwWidth
imul ebx
sar eax, 17
mov shiftY, eax
mov eax, (EECS205BITMAP PTR [esi]).dwHeight
imul ecx
sar eax, 17
add shiftY, eax

;set dstX to -dstWidth and dstY to -dstHeight to start loop
mov eax, dstWidth
mov dstX, eax
sub dstX, eax
sub dstX, eax
mov eax, dstHeight
mov dstY, eax
sub dstY, eax
sub dstY, eax

;returns here when to write to a new row (x-value)
XLoop:
	mov eax, dstHeight
	mov dstY, eax
	sub dstY, eax
	sub dstY, eax
	
;returns here to write to a new column (y-value)
YLoop:
	;find the x-coordinate srcX in the bitmap
	mov eax, cosa
	imul dstX
	sar eax, 16
	mov srcX, eax
	mov eax, sina
	imul dstY
	sar eax, 16
	add srcX, eax
	
	;find the y-coordinate srcY in the bitmap
	mov eax, cosa
	imul dstY
	sar eax, 16
	mov srcY, eax
	mov eax, sina
	imul dstX
	sar eax, 16
	sub srcY, eax
	
	;check the boundary conditions of the bitmap
	cmp srcX, 0
	jl skip
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	cmp srcX, eax
	jge skip
	cmp srcY, 0
	jl skip
	mov eax, (EECS205BITMAP PTR [esi]).dwHeight
	cmp srcY, eax
	jge skip
	
	;calculate the write coordinates (writeCoordX, writeCoordY)
	;for writing to the screen
	mov eax, xcenter
	add eax, dstX
	sub eax, shiftX
	mov writeCoordX, eax
	mov eax, ycenter
	add eax, dstY
	sub eax, shiftY
	mov writeCoordY, eax
	
	;check the boundary conditions for the screen
	cmp writeCoordX, 0
	jl skip
	cmp writeCoordX, 639
	jg skip
	cmp writeCoordY, 0
	jl skip
	cmp writeCoordY, 479
	jg skip
	
	;find the color value from the specified point in the bitmap
	;stored in dl (lowest byte in edx)
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	mul srcY
	add eax, (EECS205BITMAP PTR [esi]).lpBytes
	add eax, srcX
	sub edx, edx
	mov dl, BYTE PTR [eax]
	mov bitmapval, dl
	
	;check for transparency
	cmp dl, (EECS205BITMAP PTR [esi]).bTransparent
	je skip
	
	;write the color specified into the specified coordinate on the screen
	mov eax, writeCoordY
	mul dwPitch
	add eax, lpDisplayBits
	add eax, writeCoordX
	sub edx, edx
	mov dl, bitmapval
	mov BYTE PTR [eax], dl
	
;jump to skip the write if boundary conditions aren't met
skip:
	
	;increment Y counter and return to YLoop
	add dstY, 1
	mov eax, dstY
	cmp eax, dstHeight
	jl YLoop
	
	;increment X counter and return to XLoop
	add dstX, 1
	mov eax, dstX
	cmp eax, dstWidth
	jl XLoop
	
ret

RotateBlit ENDP

;----------------------------------------------------------------------------------------------------------------------------------

;This is the pseudocode for the rotateblit function written above.
; cosa = FixedCos(angle) 
; sina = FixedSin(angle) 
; esi = lpBitmap 
; shiftX = (EECS205BITMAP PTR [esi]).dwWidth * cosa / 2 ­
;      (EECS205BITMAP PTR [esi]).dwHeight * sina / 2;
; shiftY = (EECS205BITMAP PTR [esi]).dwHeight * cosa / 2 +
;      (EECS205BITMAP PTR [esi]).dwWidth * sina / 2;
; dstWidth= (EECS205BITMAP PTR [esi]).dwWidth + 
; (EECS205BITMAP PTR [esi]).dwHeight; 
; dstHeight= dstWidth; 
; for(dstX = ­dstWidth; dstX < dstWidth; dstX++)   { 
;   for(dstY = ­dstHeight; dstY < dstHeight; dstY++) { 
; srcX = dstX*cosa + dstY*sina; 
; srcY = dstY*cosa – dstX*sina; 
; if (srcX >= 0 && srcX < (EECS205BITMAP PTR [esi]).dwWidth && 
;             srcY >= 0 && srcY < (EECS205BITMAP PTR [esi]).dwHeight && 
;             (xcenter+dstX­shiftX) >= 0 && (xcenter+dstX­shiftX) < 639 && 
;             (ycenter+dstY­shiftY) >= 0 && (ycenter+dstY­shiftY) < 479 && 
;             bitmap pixel (srcX,srcY) is not transparent) then
;           Copy color value from bitmap (srcX, srcY) 
; to screen (xcenter+dstX­shiftX, ycenter+dstY­shiftX) 
;       } 
;   } 
; }

;; Define the functions BasicBlit and RotateBlit
;; Take a look at rotate.inc for the correct prototypes (if you don't follow these precisely, you'll get errors)
;; Since we have thoroughly covered defining functions in class, its up to you from here on out...
;; Remember to include the 'ret' instruction or your program will hang
		

END
