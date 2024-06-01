  .syntax unified
  .cpu cortex-m7
  .fpu softvfp
  .thumb

.global  float_div

.section  .text
  .type  float_div, %function
float_div:
	push     {r7}
	mov r7,0
	mov r8,0
	mov r9,#25   // iteration number = 23 bit fraction, 1 bit hidden 1, 1 bit extra for rounding
	/* Extract the first argument's mantissa */
	ubfx r3,r0,#0,#23
	orr r3,0x800000

	/* Extract the second argument's mantissa */
	ubfx r4,r1,#0,#23
	orr r4,0x800000



	ubfx r5,r0,#23,#8  		// extract the exponent
	ubfx r6,r1,#23,#8		// extract the exponent

	cmp r3,r4 // check if a > b
	ITT mi    // if we cannot divide mantissas,
	lslmi r3,r3,#1  // shift the first mantissa to the left once
	submi r5,#1     // subtract one from exponent since we doubled mantissa

	sub r6,r5,r6			// subtract the exponents er= e1 - e2
	add r6,#127				// normalize the exponents er= er + 127
	lsl r6,#23				// put the exponent to correct pos


calculate_mantissa:     // this is the part where fixed point division happens
	cmp r3,r4

	ITT ge
	subge r3,r3,r4  		// if a > b , r3 = a-b
	orrge r7,#1				// if a >= b, put a 1 to result register
	lsl r3,r3,#1  		 	// a = a << 1 i.e. append 0 to right


	lsl r7,#1				// shift the result register to the left in any condition
	add r8,#1				// increment counter
	cmp r8,r9				// check if we iterated 23 times
	blt calculate_mantissa		// if not, continue dividing
							// if so, continue to construct the number

__rounding:
	and r3,r7,0x02          // extract the last two bits
	mov r11,#0x02
	cmp r3,r11				// if there is a 1 after the lsb of the result

	lsr r7,r7,#2			// get rid of last two bits since they won't present in result

	IT eq
	addeq r7,#0x1			// increment mantissa by one (round to nearest even)

__exit:
	bfc r7,#23, #1			// clear the hidden one 1
	eors r2,r0,r1			// compute sign

	mov r0,#0				// construct the final result
	IT mi					// if negative
	orrmi r0,#0x80000000	// put sign


	orr r0,r6				// construct the final result
	orr r0,r7				// construct the final result


	pop     {r7}			// return
	bx lr

