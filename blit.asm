; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 2
;   Jacob Kobza
;   February 3rd, 2014
; #########################################################################
; This program writes the colors specified onto the bitmap to create a blit on the screen

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include blit.inc		; Take a look at this file to understand how
				;      bitmaps are declared

.DATA

currRow DWORD ?	         ;contains the current row number to write to in the bitmap. A counter that controls the outer loop
bitmapAddress DWORD ?    ;contains the address of the next color byte in the bitmap to read from memory
storeecx DWORD ?         ;temporarily contains the value that was in ecx while it is needed to perform other computations
xcoord DWORD ?           ;stores the current x coordinate

.CODE

; Routine which draws a bitmap to the screen
BlitReg PROC 

mov ebx, edx
mov currRow, 0
mov eax, (EECS205BITMAP PTR [ebx]).lpBytes
mov bitmapAddress, eax

mov edx, (EECS205BITMAP PTR [ebx]).dwWidth
shr edx, 1                       ;edx <- dwWidth / 2
sub esi, edx                     ;esi <- Address for (x - dwWidth / 2, y)
mov xcoord, esi

mov edx, (EECS205BITMAP PTR [ebx]).dwHeight
shr edx, 1                       ;edx <- dwHeight / 2
sub edi, edx                     ;edi <- Address for (x, y - dwHeight / 2)

;this loop goes through each row of the bitmap
RowLoop:
	;each time through the row loop, the pixel in the specified location is drawn and the row is increased
	;this is the outer loop of the nested loops
	mov ecx, xcoord
	sub xcoord, ecx
	sub ecx, ecx
	
	mov eax, dwPitch
	mul edi
	add eax, esi
	add eax, lpDisplayBits

;this loop goes through each column of the bitmap
ColumnLoop:
	;each time through the column loop, the pixel in the specified location is drawn and the column is increased
	mov storeecx, ecx
	mov ecx, bitmapAddress
	mov cl, BYTE PTR[ecx]
	;check for transparency
	cmp cl, (EECS205BITMAP PTR [ebx]).bTransparent
	je Skip
	;checks for boundaries
	cmp edi, 479
	jg Skip
	cmp edi, 0
	jl Skip
	cmp xcoord, 639
	jg Skip
	cmp xcoord, 0
	jl Skip
	mov BYTE PTR [eax], cl ;this line writes a pixel to the screen at address eax
;Skip is a jump destination for when the pixel shouldn't be drawn
Skip:
	mov ecx, storeecx
	;the column counters are incremented
	add bitmapAddress, 1
	add eax, 1
	add ecx, 1
	add xcoord, 1
	
	;check for the condition of the inner loop
	;if satisfied it goes to the next column
	cmp ecx, (EECS205BITMAP PTR [ebx]).dwWidth
	jl ColumnLoop
	
	;the row counters are incremented
	add currRow, 1
	add edi, 1
	mov eax, currRow
	;check for the condition of the outer loop
	;if satisfied it goes to the next row
	cmp eax, (EECS205BITMAP PTR [ebx]).dwHeight
	jl RowLoop

    ;; Here is some C-like pseudocode. You can use this as a starting point
    ;; 	 (or start from scratch if you feel like it)

    ;; Feel free to declare variables (global) if it helps. There is a pretty
    ;;   good chance that you won't fit everything in registers

    ;; 	for(bmpY = 0;  bmpY < srcBitmap->dwHeight; bmpY++)
    ;;         	for(bmpX = 0;  bmpX < srcBitmap->dwWidth; bmpX++) {
    ;; 		        screenX = centerX + bmpX - srcBitmap->dwWidth/2;
    ;; 		        screenY = centerY + bmpY - srcBitmap->dwHeight/2;
    ;; 	
    ;; 			if (srcBitmap->lpBytes[bmpY*srcBitmap->dwWidth+bmpX] == srcBitmap->bTransparent &&
    ;; 			    screenX >= 0 && screenX <= 639 &&
    ;; 			    screenY >= 0 && screenY <= 479)
    ;; 				lpDisplayBits[screenY*dwPitch + screenX] =
    ;; 					srcBitmap->lpBytes[bmpY*srcBitmap->dwWidth+bmpX]; 
    ;; 				
    ;; 		}
    	
    
    ret             ;; Don't delete this line
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

BlitReg ENDP


.DATA
		
StarBitmap EECS205BITMAP <32, 36, 0ffh,, offset StarBitmap + sizeof StarBitmap>
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh
	BYTE 0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh
	BYTE 0feh,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0fdh
	BYTE 0f9h,0f9h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0fdh
	BYTE 0f8h,0f8h,0fdh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0fdh
	BYTE 0f8h,0f8h,0f8h,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0fdh
	BYTE 0f8h,0f8h,0d8h,0f9h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0f9h
	BYTE 0f8h,0f8h,0d8h,0d8h,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0fdh,0f8h
	BYTE 0f8h,0f4h,0f8h,0d8h,0d9h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fah,0feh,0fdh,0f8h
	BYTE 0f8h,0f4h,0f8h,0d8h,0d8h,0fdh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0fdh,0f8h
	BYTE 0f4h,0f4h,0f4h,0f8h,0f8h,0d4h,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0feh,0f9h,0d4h
	BYTE 0f8h,0f4h,0f4h,0d4h,0f8h,0f8h,0d4h,0feh,0feh,0feh,0feh,0feh,0feh,0feh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0f9h,0fdh,0f8h,0f8h
	BYTE 0f4h,0f8h,0f4h,0f4h,0f8h,0d4h,0d4h,0f8h,0d9h,0d9h,0d9h,0f9h,0d9h,0f9h,0d9h,0fah
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0fdh,0f9h,0f8h,0f8h,0f8h,0f8h
	BYTE 0f8h,0d4h,0f8h,0f8h,0f4h,0f8h,0f8h,0d8h,0f8h,0f8h,0f8h,0f8h,0d8h,0d4h,0d5h,0feh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0feh,0f9h,0f9h,0f8h,0f8h,0fch,0fch,0f8h,0f8h
	BYTE 0f8h,0f8h,0f8h,0f8h,0f4h,0f8h,0b0h,0d8h,0d8h,0f8h,0f8h,0f4h,0f8h,0d8h,0d9h,0feh
	BYTE 0ffh,0ffh,0feh,0fdh,0f9h,0f8h,0f8h,0f8h,0f8h,0f8h,0fdh,0fdh,0f8h,0f8h,0f8h,0f8h
	BYTE 0f8h,0b0h,0d8h,0f8h,0f8h,0f8h,044h,08ch,0d4h,0d8h,0d4h,0d4h,0d4h,0d4h,0feh,0ffh
	BYTE 0feh,0feh,0d9h,0d8h,0f8h,0f8h,0fch,0fch,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0fch
	BYTE 0f8h,06ch,06ch,0fch,0f8h,0d8h,06ch,06ch,0d4h,0f8h,0d4h,0d4h,0d4h,0d5h,0ffh,0ffh
	BYTE 0ffh,0dah,0d4h,0d4h,0f8h,0f8h,0f8h,0f8h,0f4h,0f4h,0f4h,0f8h,0f8h,0f8h,0fch,0fch
	BYTE 0fdh,06ch,06ch,0fdh,0fch,0d8h,048h,068h,0f8h,0d4h,0d4h,0d4h,0d4h,0feh,0ffh,0ffh
	BYTE 0ffh,0ffh,0feh,0d8h,0d4h,0f4h,0f8h,0f4h,0f4h,0f4h,0f8h,0f8h,0f8h,0f8h,0fch,0fch
	BYTE 0fdh,048h,048h,0fdh,0fch,0fch,044h,024h,0f8h,0d4h,0d4h,0d4h,0d9h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0feh,0f9h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0fch,0fch,0fch
	BYTE 0fdh,048h,000h,0fdh,0fch,0f8h,048h,024h,0f8h,0f4h,0d4h,0d5h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0feh,0f9h,0f8h,0f8h,0d8h,0f8h,0f8h,0f8h,0f8h,0fch,0fch,0fch
	BYTE 0fch,06ch,020h,0f8h,0fch,0fch,090h,044h,0f8h,0f4h,0d4h,0fah,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fdh,0f9h,0d8h,0d8h,0f8h,0f8h,0f8h,0fch,0fch,0fch
	BYTE 0fch,0b4h,020h,0fdh,0fch,0fch,0d8h,0d8h,0f8h,0f4h,0d5h,0feh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f9h,0d8h,0f8h,0f8h,0f8h,0fch,0fch,0fch
	BYTE 0fch,0fch,0fch,0fch,0fch,0fch,0f8h,0d8h,0f8h,0f4h,0d5h,0feh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f9h,0f8h,0f8h,0f8h,0fch,0fch,0fch
	BYTE 0fch,0fch,0fch,0fch,0fch,0fch,0fch,0d8h,0f8h,0d4h,0d4h,0feh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f8h,0f8h,0f8h,0f8h,0fch,0fch
	BYTE 0fch,0fch,0fch,0fch,0fch,0f8h,0f8h,0d8h,0f8h,0d4h,0d4h,0feh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f8h,0f8h,0f8h,0f8h,0f8h,0fch
	BYTE 0fch,0fch,0fch,0fch,0f8h,0f8h,0f8h,0d8h,0d4h,0d4h,0d4h,0feh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h
	BYTE 0f8h,0fch,0f8h,0f8h,0f8h,0f8h,0d8h,0f8h,0f4h,0d4h,0d4h,0f9h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f8h,0f8h,0f4h,0f8h,0f8h,0f8h
	BYTE 0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0d4h,0d4h,0d4h,0f4h,0f9h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fah,0f8h,0f4h,0f4h,0f8h,0f8h,0f8h
	BYTE 0f8h,0f8h,0f8h,0f8h,0d4h,0d4h,0d4h,0d4h,0d4h,0d4h,0d4h,0d5h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fah,0f8h,0f4h,0f4h,0f4h,0f4h,0d4h
	BYTE 0d4h,0d8h,0d4h,0f9h,0f9h,0d5h,0b0h,0d4h,0d4h,0d4h,0d4h,0d4h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f9h,0f8h,0f4h,0f4h,0f4h,0d4h,0d4h
	BYTE 0d8h,0d4h,0feh,0ffh,0ffh,0ffh,0feh,0d5h,0d5h,0d4h,0d4h,0d5h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f9h,0f8h,0f4h,0f4h,0f4h,0d4h,0d8h
	BYTE 0d5h,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fah,0d5h,0b5h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f9h,0f4h,0f4h,0f4h,0d4h,0d4h,0f9h
	BYTE 0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0d9h,0d8h,0d4h,0d4h,0d5h,0fah,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fah,0d4h,0d4h,0d5h,0feh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dah,0d5h,0d4h,0feh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f9h,0feh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		

END

