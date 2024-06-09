    .syntax unified
    .cpu cortex-m7
    .thumb

.global     float_sub
.section    .text
.type       float_sub, %function

float_sub:
	mov r11,0
	tst r1,0x80000000		// check if second argument is negative
	beq 1f
	ITTT ne
	movne r2,r0
	movne r0,r1
	movne r1,r2				// if so, swap first and second argument and make second negv
	tst r0, 0x80000000
	ITTT ne
	eorne r0,0x80000000
	eorne r1,0x80000000
	bne 2f
1:
	tst r0, 0x80000000
	IT ne
	eorne r1,0x80000000
	bne	 float_add
2:



    push     {r7}
    mov r7,0

    /* Extract the first argument's mantissa */
    ubfx r3,r0,#0,#23
    orr r3,0x800000

    /* Extract the second argument's mantissa */
    ubfx r4,r1,#0,#23
    orr r4,0x800000

    ubfx r0,r0,#23,#8       // extract the exponent
    ubfx r1,r1,#23,#8       // extract the exponent

    subs   r2,r0,r1 // check if expA > expB

    bgt   align_second 	// at that case, r1 is the resultant exponent
    blt   align_first

    mov   r7,r0
	beq   sub_mantissas

align_second:
	mov r7,r0
    mov r0,#24
	cmp r2,r0

	blt round_check2

    mov r0, #0   		// first exponent is now scratch
    mov r5,#0x800000 	//generate mask for sticky bit check
    sub r5,#1
    ands r5,r4,r5
    beq round_check2

sticky_exit2:
	lsr r4,r2			// shift the mantissa, mantissa is aligned now
	mov r2,r0			// r2 is the resultant exponent

    beq sub_mantissas     // sticky bit failed14

    IT ne
    addne r4,#0x1			// sticky bit continues
round_check2:
	sub r2, #0x1     // round bit control
    lsr r5,r4,r2
    ands r5, #0x1
    add r2, #0x1

	lsr r4,r2
	IT ne
    addne r4,#0x1   // round bit occured

    b sub_mantissas


align_first:
	neg r2,r2
	mov r7,r1
    mov r0,#24
	cmp r2,r0

	blt round_check1

    mov r0, #0   		// first exponent is now scratch
    mov r5,#0x800000 	//generate mask for sticky bit check
    sub r5,#1
    ands r5,r3,r5
	beq round_check1
sticky_exit1:
	lsr r4,r2			// shift the mantissa, mantissa is aligned now
	mov r2,r0			// r2 is the resultant exponent

    beq sub_mantissas     // sticky bit failed14

    IT ne
    addne r3,#0x1			// sticky bit continues
round_check1:
	sub r2, #0x1     // round bit control
    lsr r5,r3,r2
    ands r5, #0x1
    add r2, #0x1

	lsr r3,r2
	IT ne
    addne r3,#0x1   // round bit occured

    b sub_mantissas


sub_mantissas:


	mov r2,r7       // restore resultant exponent
    subs r3,r3,r4       // add mantissas
	beq result_is_zero

	ITTE mi			// if the result is negative?
	negmi r3,r3
	movmi   r4, 0x80000000
	movpl   r4, 0x0
normalize_loop:
    tst r3,#0x800000   // test if there is underflow

    ITT eq				// check if underflow
    lsleq r3, #1        // underflow occured
	subeq r2, #1
    tst r3,#0x800000   // test if there is underflow
    beq normalize_loop





exit_add:  // r2 holds the resultant exponent, r3 holds resultant mantissa
	bfc r3,#23,#1
	lsl r0, r2, #23 // put resultant exponent

    orr r0, r3 // put resultant mantissa
	orr r0, r4 // put sign
    pop     {r7}
    bx lr

 result_is_zero:
 	mov r0,0
 	pop {r7}
 	bx lr
