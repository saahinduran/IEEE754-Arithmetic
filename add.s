    .syntax unified
    .cpu cortex-m7
    .thumb

.global     float_add
.section    .text
.type       float_add, %function

float_add:
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
	mov r0,r1 		// put r0 to resultant exponent to carry to sticky_exit subroutine

	blt sticky_exit

    mov r0, #0   		// first exponent is now scratch
    mov r5,#0x800000 	//generate mask for sticky bit check
    sub r5,#1
    ands r5,r3,r5


	lsr r3,r2			// shift the mantissa, mantissa is aligned now
    add r3,r4			// add mantissas, r3 is the resultant mantissa
	mov r2,r1			// r2 is the resultant exponent

    beq exit_add     // sticky bit failed
    add r3,#0x1			// sticky bit continues


    b exit_add

align_second:
    mov r6,r5
    mov r5,r3
    mov r3,r4
    neg r7,r7

    mov r1,#0x800000 //generate mask for stick bit check
    sub r1,#1
    ands r4,r4,r1


    lsr r1,r4,r7
    beq sticky_exit             // sticky bit failed

    cmp r2,r10
    IT ge                   // if sticky bit will remain ? i.e. is shift > 24?
    addge r5,#0x1

sticky_exit:

    sub r2, #0x1     // round bit control
    lsr r5,r3,r2
    ands r5, #0x1
    add r2, #0x1

	lsr r3,r2
	IT ne
    addne r3,#0x1   // round bit occured


add_mantissas:

	mov r2,r0       // restore resultant exponent
    add r3,r4       // add mantissas
    mov r5,#0x1000000   // generate mask for overflow
    ands r0,r3,r5

    ITT ne				// check if overflow
    lsrne r3, #1        // overflow occured
	addne r2, #1




exit_add:  // r2 holds the resultant exponent, r3 holds resultant mantissa
	bfc r3,#23,#1
	lsl r0, r2, #23 // put resultant exponent

    orr r0, r3 // put resultant mantissa

    pop     {r7}
    bx lr
