/*** asmMult.s   ***/
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0  
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0  
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

    
/********************************************************************
function name: asmMult
function description:
     output = asmMult ()
     
where:
     output: 
     
     function description: The C call ..........
     
     notes:
        None
          
********************************************************************/    
.global asmMult
.type asmMult,%function
asmMult:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
 
.if 0
    /* profs test code. */
    mov r0,r0
.endif
    
    /** note to profs: asmMult.s solution is in Canvas at:
     *    Canvas Files->
     *        Lab Files and Coding Examples->
     *            Lab 8 Multiply
     * Use it to test the C test code */
    
    /*** STUDENTS: Place your code BELOW this line!!! **************/
    
    /* Initializing global variables to 0 */
    /* Set r2 to 0, then store that into every variable that exists */
    ldr r2, =0

    /* Initializing a_Multiplicand */
    ldr r3, =a_Multiplicand
    str r2, [r3]

    /* Initializing b_Multiplier */
    ldr r4, =b_Multiplier
    str r2, [r4]

    /* Initializing rng_Error */
    ldr r5, =rng_Error
    str r2, [r5]

    /* Initializing a_Sign */
    ldr r6, =a_Sign
    str r2, [r6]

    /* Initializing b_Sign */
    ldr r7, =b_Sign
    str r2, [r7]

    /* Initializing prod_Is_Neg */
    ldr r8, =prod_Is_Neg
    str r2, [r8]

    /* Initializing a_Abs */
    ldr r9, =a_Abs
    str r2, [r9]

    /* Initializing b_Abs */
    ldr r10, =b_Abs
    str r2, [r10]

    /* Initializing init_Product */
    ldr r11, =init_Product
    str r2, [r11]

    /* Initializing final_Product */
    ldr r12, =final_Product
    str r2, [r12]
    
    
    
    
    /* Copy a_Multiplicand to r0 */
    ldr r0, [r3]
    
    /* Store the Sign Bit of r0 into r2, then store that into a_sign */
    lsr r2, r0, #31
    str r2, [r6]
    
    /* Check if r0 is out of range */
    ldr r2, =32767
    cmp r0, r2       /* Maximum positive value for signed 16-bit */
    bgt error_check   /* Branch if r0 is greater than 32767 */
    cmp r0, #-32768     /* Minimum negative value for signed 16-bit */
    blt error_check   /* Branch if r0 is less than -32768 */
    
    /* Copy b_Multiplier to r1 */
    ldr r1, [r4]
    
    /* Store the Sign Bit of r1 into r2, then store that into a_sign */
    lsr r2, r1, #31
    str r2, [r7]
    
    /* Check if r1 is out of range */
    ldr r2, =32767
    cmp r1, r2       /* Maximum positive value for signed 16-bit */
    bgt error_check   /* Branch if r1 is greater than 32767 */
    cmp r1, #-32768     /* Minimum negative value for signed 16-bit */
    blt error_check   /* Branch if r1 is less than -32768 */
    b prod_is_pos_or_neg /* Branch to see if the product will be  pos or neg */
    
    error_check:
	    /* Setting rng_Error to 1, and r0 to 0 */
	    ldr r2, =1
	    str r2, [r5]
	    ldr r0, =0
	    b done /* Branching to done */

    prod_is_pos_or_neg:
    /* Check sign bits and decide the sign of the final product */
    ldr r6, [r6] /* Load the value from a_sign into r6 */
    ldr r7, [r7] /* Load the value from b_sign into r7 */
    eor r2, r6, r7 /* If only either r6 and r7 are 1, then result is neg (1) */
    str r2, [r8] /* Store the result in the prod_Is_Neg variable */
    //ldr r6, =a_Sign /* Set r6 equal back to the memory address of a_Sign */
    //ldr r7, =b_sign  /* Set r7 equal back to the memory address of a_Sign */
    
    cmp r6, #1 // Compare to see if the the Multiplicand is Negative
    beq make_a_into_pos // If so, then use NEG to make it positive
    bne store_a_regularly // Otherwise, just branchh regularly
    
    // Commands for making the multiplicand bit-flipped, and storing it
    make_a_into_pos:
	neg r2, r0
	str r2, [r9]
	b b_calculation
	
    store_a_regularly:
	str r0, [r9]
	b b_calculation
    
    b_calculation:
	cmp r7, #1 // Compare to see if the the Multiplier is Negative
	beq make_b_into_pos // If so, then use NEG to make it positive
	bne store_b_regularly // Otherwise, just branchh regularly
    
    // Commands for making the multiplier bit-flipped, and storing it
    make_b_into_pos:
	neg r2, r1
	str r2, [r10]
	b shift_and_add
	
    store_b_regularly:
	str r1, [r10]
	b shift_and_add
	
    shift_and_add:
    ldr r2, =0 // This will be our product value
    ldr r9, [r9] // This is the Absolute Value of the Multiplicand
    ldr r10, [r10] // This is the Absolute Value of the Multiplier
    
    loop:
	cmp r10, #0
	beq end_loop
	
	add r2, r2, r9
	sub r10, r10, #1
	b loop
	
    end_loop:
	str r2, [r11]
	
	ldr r8, [r8]
	cmp r8, #1
	beq convert_to_negative
	bne store_normally
    
    convert_to_negative:
    neg r2, r2 // We will have to use NEG to turn our initial result negative
    str r2, [r12] // Storing the Final result into final_Product
    
    store_normally:
    str r2, [r12] // Since our Initial Result is positive, we can store it
		  // Without using NEG
    
    mov r0, r2 // Copying the Final Result to r0
	
    /* Branching to done */
    /* This should be the final line. Write everythingn else above this. */
    b done
    
    /*** STUDENTS: Place your code ABOVE this line!!! **************/

done:    
    /* restore the caller's registers, as required by the 
     * ARM calling convention 
     */
    mov r0,r0 /* these are do-nothing lines to deal with IDE mem display bug */
    mov r0,r0 

screen_shot:    pop {r4-r11,LR}

    mov pc, lr	 /* asmMult return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




