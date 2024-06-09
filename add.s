    .syntax unified
    .cpu cortex-m7
    .thumb

.global     float_add
.section    .text
.type       float_add, %function

float_add:
	mov r11,0
	tst r0,0x80000000		// check if first argument is negative
	beq 1f
	ITTTT ne
	eorne r0,0x80000000
	movne r2,r0
	movne r0,r1
	movne r1,r2				// if so, swap first and second argument and make second negv
	tst r0, 0x80000000
	beq float_sub
	mov r11,0x80000000
	b	2f
1:
	tst r1, 0x80000000
	IT ne
	eorne r1,0x80000000
	bne	float_sub

2:
    push     {r7}
    mov r7,0

    cmp r0,r7 // if first number is zero
	beq exit_zero1
	cmp r1,r7 // if second number is zero
	beq exit_zero2

    /* Extract the first argument's mantissa */
    ubfx r3,r0,#0,#23
    orr r3,0x800000

    /* Extract the second argument's mantissa */
    ubfx r4,r1,#0,#23
    orr r4,0x800000

    ubfx r0,r0,#23,#8       // extract the exponent
    ubfx r1,r1,#23,#8       // extract the exponent

    subs   r2,r1,r0 // check if expA > expB

    bgt   align_first 	// at that case, r1 is the resultant exponent
	beq   add_mantissas
    subs r2,r0,r1 		// if exp A < exp B resultant exponent is r0
    mov r1,r0			// at that case, r0 is the resultant exponent, so put it in r1

    mov r0,r3
    mov r3,r4
    mov r4,r0



align_first:

	mov r0,#24
	cmp r2,r0

	bgt exit_noop // small number is lost

    mov r0, #1   		// first exponent is now scratch
    cmp r2, r0
    beq check_last_bit
    lsl r0, r2			//generate mask for sticky bit check
    sub r0,#1
    ands r5,r3,r0

	mov r0, #1
	sub r2, #1
	lsl r0, r2
	add r2, #1

	lsr r3,r2			// shift the mantissa, mantissa is aligned now

	cmp r5,r0
	IT gt

	addgt r3, #1
	bgt add_mantissa_without_rounding
	b add_mantissas

check_last_bit:
	tst r3,#0x1
	lsr r3,r2			// shift the mantissa, mantissa is aligned now
	IT ne
	addne r3, #1
	beq add_mantissas

add_mantissa_without_rounding:
	mov r2,r1       // restore resultant exponent
    add r3,r4       // add mantissas

    tst r3,#0x1000000   // check if overflow occured
    beq no_overflow
	lsr r3, #1        // overflow occured
	add r2, #1
	b exit_add

add_mantissas:

	mov r2,r1       // restore resultant exponent
    add r3,r4       // add mantissas

    tst r3,#0x1000000   // check if overflow occured
    beq no_overflow

	ubfx r0,r3,#0,#2

	mov r1, #2
	cmp r0, r1
    IT gt
    addgt r3,#0x1

    lsr r3, #1        // overflow occured
	add r2, #1


no_overflow:


exit_add:  // r2 holds the resultant exponent, r3 holds resultant mantissa
	bfc r3,#23,#1
exit_noop:
	lsl r0, r2, #23 // put resultant exponent

    orr r0, r3 // put resultant mantissa
	orr r0, r11 // put sign
    pop     {r7}
    bx lr

exit_zero1:
	cmp r1, r7 // if second number is zero as well
	bne 1f
	mov r0,0
	pop {r7}
	bx lr
1:
	mov r0,r1
	pop {r7}
	bx lr

exit_zero2:
	cmp r0, r7 // if first number is zero as well
	bne 1f
	mov r0,0
	pop {r7}
	bx lr
1:
	pop {r7}
	bx lr
