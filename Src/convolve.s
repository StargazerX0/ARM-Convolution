/*
 * convolve.s
 *
 *  Created on: 29/01/2023
 *      Author: Hou Linxin
 */
   .syntax unified
	.cpu cortex-m4
	.fpu softvfp
	.thumb

.global convolve
.section .bss
.lcomm output_array, 80  // Reserves 80 bytes in the BSS section for output_array

.section .text

convolve:
    PUSH {R4-R11, LR}  // Save callee-saved registers and the Link Register
    
    //R0 = h, R1 = x, R2 = lenH, R3 = lenX
    LDR R4, =output_array  // R4 = output_array
    ADD R5, R2, R3
    SUB R5, R5, #1  //nconv
    MOV R6, #0  //i

conv_loop:
    CMP R6, R5
    BEQ end_conv

// Calculate x_start = MAX(0, i-lenH+1)
    MOV R7, R6       // R7 = i
    SUB R7, R7, R2   // R7 = i - lenH
    ADD R7, R7, #1   // R7 = i - lenH + 1
    CMP R7, #0
    IT LT            // If Less Than
    MOVLT R7, #0     // R7 = 0 if the result of CMP is less than zero (MAX operation)

// Calculate x_end = MIN(i+1, lenX)
    MOV R8, R6       // R8 = i
    ADD R8, R8, #1   // R8 = i + 1
    CMP R8, R3
    IT GT            // If Greater Than
    MOVGT R8, R3     // R8 = lenX if i + 1 is greater than lenX (MIN operation)

 // Calculate h_start = MIN(i, lenH-1)
    MOV R9, R6       // R9 = i
    SUB R10, R2, #1  // R10 = lenH - 1
    CMP R9, R10
    IT GT            // If Greater Than
    MOVGT R9, R10    // R9 = lenH - 1 if i > lenH - 1 (MIN operation)

    
    SUB R11, R4, R6, LSL #2 //output_array[i]
    PUSH {R2-R5} //push unused register, R2, R3, R4, R5
    MOV R4, #0 //sum

kernel_loop:
    CMP R7, R8
    BEQ store_output

    LDR R2, [R0, R9, LSL #2]  // Load h[h_start] into R2
    LDR R3, [R1, R7, LSL #2] // Load x[x_start] into R3

    MUL R5, R2, R3 //h[h_start] * x[j]

    ADD R4, R4, R5 //sum += h[h_start] * x[j]

    SUB R9, R9, #1 //h_start--
    ADD R7, R7, #1 //x_start++
   

    B kernel_loop

store_output:
    STR R4, [R11] //output_array[i] = sum
    POP {R2-R5} //pop unused register, R2, R3, R4, R5
    ADD R6, R6, #1 //i++
    
    B conv_loop

end_conv:
    MOV R0, R11 // R0 = output_array
    POP {R4-R11, LR} // Restore callee-saved registers and the Link Register
    BX LR

