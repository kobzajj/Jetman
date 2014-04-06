; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;	Jacob Kobza 2/14/14
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include trig.inc	

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  256 / PI   (use this to find the table entry for a given angle
	                        ;;              it is easier to use than divison would be)

.CODE

;calculates the sine of a specified angle using a sine table and trig identities
FixedSin PROC USES ebx ecx edx dwAngle:FIXED
LOCAL angleadjusted:DWORD, negative:DWORD


mov negative, 0
mov eax, dwAngle
mov angleadjusted, eax
checksign:
	;checks for sign of the angle and jumps to the appropriate instruction
	cmp angleadjusted, 0
	jge checkperiodpositive
	jl checkperiodnegative
checkperiodpositive:
	;subtracts 2pi until the value is between 0 and 2pi
	cmp angleadjusted, TWO_PI
	jl checkquadrant
	sub angleadjusted, TWO_PI
	jmp checkperiodpositive
checkperiodnegative:
	;adds 2pi until the value is between 0 and 2pi
	cmp angleadjusted, 0
	jge checkquadrant
	add angleadjusted, TWO_PI
	jmp checkperiodnegative
checkquadrant:
	;checks the quadrant of the angle on the unit circle
	cmp angleadjusted, PI_HALF
	jle quad1
	cmp angleadjusted, PI
	jl quad2
quad34:
	;subtracts pi from the angle and the sine value is negative if the
	;angle is in quadrant 3 or 4
	sub angleadjusted, PI
	mov negative, 1
	jmp checkquadrant
quad2:
	;sin(x) = sin(pi - x) for quadrant 2
	mov ebx, PI
	sub ebx, angleadjusted
	mov angleadjusted, ebx
quad1:
	cmp angleadjusted, PI_HALF
	jne notpiovertwo
	mov ebx, 10000h
	jmp done
notpiovertwo:
	;finds the appropriate value from the sin table to find the trig value
	mov eax, angleadjusted
	mov ecx, PI_INC_RECIP
	imul ecx
	shl edx, 1
	add edx, OFFSET SINTAB
	mov ebx, 0
	mov bx, WORD PTR [edx]
	cmp negative, 0
	je done
	not ebx
	add ebx, 1
done:
	mov eax, ebx
	
ret

FixedSin ENDP

;--------------------------------------------------------------------------------------------------

;calculates cosine of an angle using the sine algorithm written above and trig identities
FixedCos PROC dwAngle:FIXED
LOCAL adjustedangle:DWORD

mov eax, PI_HALF
sub eax, dwAngle
mov adjustedangle, eax
INVOKE FixedSin, adjustedangle

ret

FixedCos ENDP


;; Define the functions FixedSin and FixedCos
;; Since we have thoroughly covered defining functions in class, its up to you from here on out...
;; Remember to include the 'ret' instruction or your program will hang
;; Also, don't forget to set your return values
	
	
END
