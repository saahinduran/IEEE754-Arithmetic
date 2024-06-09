  .syntax unified
  .cpu cortex-m7
  .fpu softvfp
  .thumb

.global  float_mul

.section  .text
  .type  float_mul, %function
float_mul:

	push     {r7}
	mov r7,0

	cmp r0,r7
	beq __exit_zero

	cmp r1,r7
	beq __exit_zero

	/* Extract the first argument's mantissa */
	ubfx r3,r0,#0,#23
	orr r3,0x800000

	/* Extract the second argument's mantissa */
	ubfx r4,r1,#0,#23
	orr r4,0x800000

	/* Perform 64 bit multiplication */
	umull r9,r10,r3,r4



	ubfx r5,r0,#23,#8  		// extract the exponent
	ubfx r6,r1,#23,#8		// extract the exponent

	add r5,r6
	sub r5,#127				// normalize the exponent
	tst r10,#0x8000		// check if mantissa overflowed
	IT ne					// if so,
	addne r5,#1				// increment exponent by one

	lsl r5,#23			// put exponent result to correct pos
	beq 	mantissa_not_overflowed

mantissa_overflowed:

	and r12,r9,#0xFF000000  // extract lower 8 bits
	lsr r12,#24				// put them in correct position


	tst r9,#0x800000		// check if round bit is set
	IT ne
	addne r12,#1			// if so, add 1 to mantissa

	orr r7,r12             // construct the final result
	lsl r10,#8
	bfc r10,#23,#2			// get rid of hidden 1
	orr r7,r10
	orr r7,r5
	b __exit_mul

mantissa_not_overflowed:
	mov r2, #0xFF000000
	orr r2, #0x800000
	and r12,r9,r2  // extract lower 9 bits


	lsr r12,#23  // put them in correct position

	tst r9,#0x400000  // check if round bit is set
	IT ne
	addne r12,#1      // if so, add 1 to mantissa


	orr r7,r12       // construct the final result
	lsl r10,#9
	bfc r10,#23,#1   // get rid of hidden 1
	orr r7,r10
	orr r7,r5

__exit_mul:

	eors r2,r0,r1			// compute sign
	mov r0, #0
	IT mi					// if negative
	orrmi r0,#0x80000000	// put sign

	orr r0,r7
	pop {r7}
	bx lr

__exit_zero:
	mov r0,#0
	pop {r7}
	bx lr
