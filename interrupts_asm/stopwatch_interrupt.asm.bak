.equ    RAM, 0x1000
.equ    LEDs, 0x2000
.equ    TIMER, 0x2020
.equ    BUTTON, 0x2030

.equ    LFSR, RAM

br main
br interrupt_handler

main:
    ; Variable initialization for spend_time
    addi t0, zero, 18
    stw t0, LFSR(zero)
	addi t0, zero, 255
	stw t0,LEDs+12(zero)
	call game_reset 
	add t1,zero, zero #t1 = valeur du counter a iteration d avant
	add a0, t1, zero
	call display
	addi t0, zero, COUNTER_AD ;;t0 = adresse de la valeur du counter  
	stw t1, 0(t0) ;; initialement, counter =0
	main_loop: 
		ldw a0, 0(t0) ;; nouvelle valeur du counter
		beq a0, t1, suite_main ;; si a0 = t1, alors coutner a pas changé, donc pas de display
		add t1, zero, a0 ;; t1 = nouvelle valeur 
		call display
		suite_main:
		#to loop back to the main loop (infinite loop)
		beq zero, zero, main_loop

	;;mettre coutner value dans ram a adresse 1000
	;; pour savoir quand call display, avoir dans le main un register t0 qui contient la valeur du timer read avant. Des que celle la change (que tu read ram 1000 et que c est different), ca veut dire que 100 ms se sont ecoulés et tu peux display. Comme ca, display se fait pas pendant spend time. 
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; DO NOT CHANGE ANYTHING ABOVE THIS LINE
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	
    ; WRITE YOUR CONSTANT DEFINITIONS AND main HERE
.equ EDGECAPTURE_AD, 0x2034
.equ COUNTER_AD, 0x1004
interrupt_handler:
    ; WRITE YOUR INTERRUPT HANDLER HERE
	#push the registers 
	addi sp,sp,-64
	stw ra, 0(sp)
	stw t0, 4(sp)
	stw t1, 8(sp)
	stw t2, 12(sp)
	stw t3, 16(sp)
	stw t4, 20(sp)
	stw t5, 24(sp)
	stw t6, 28(sp)
	stw t7, 32(sp)
	stw v0, 36(sp)
	stw v1, 40(sp)
	stw a0, 44(sp)
	stw a1, 48(sp)
	stw a2, 52(sp)
	stw a3, 56(sp)
	stw ea ,60(sp)
	
	#read the ipending register to identify the source 
	rdctl t0, ipending ;;to = ipending
	addi t1, zero, 1 ;;mask for timer
	and t2, t0, t1
	beq t2,zero, check_buttons	
	#si ipending(0) = 1, appeler routine timer 2
	;; incrementer la valeur dans la ram(1000)
	addi t4, zero, COUNTER_AD
	ldw t5, 0(t4)
	addi t5, t5, 1
	stw t5, 0(t4)
	#set tO to 0 (interrupt has been handled) 
	addi t5, zero, 0b10
	sub t5, zero, t5
	addi t5,t5,-1
	addi t1, zero, TIMER
	addi t1,t1,0xC
	stw t5, 0(t1)
	check_buttons:
	addi t1, zero, 0b100 ;;mask for buttons
	and t2, t0, t1
	beq t2,zero, IRQ_handled
	#si ipending(2) = 1, appeler routine 1
	call button_IRQ
	IRQ_handled:
	
	#restore registers from the stack
	ldw ra, 0(sp)
	ldw t0, 4(sp)
	ldw t1, 8(sp)
	ldw t2, 12(sp)
	ldw t3, 16(sp)
	ldw t4, 20(sp)
	ldw t5, 24(sp)
	ldw t6, 28(sp)
	ldw t7, 32(sp)
	ldw v0, 36(sp)
	ldw v1, 40(sp)
	ldw a0, 44(sp)
	ldw a1, 48(sp)
	ldw a2, 52(sp)
	ldw a3, 56(sp)
	ldw ea, 60(sp)
	addi sp, sp, 64
	#correct the exception return adress 
	addi ea, ea, -4
	eret 
#TODO FIX BUTTON_IRQ (CALL SPEND TIME)  ET LA PERIODE DU COUNTER!!
button_IRQ:
	#disable ienable for buttons
	addi t0, zero, 0b001
	wrctl ienable, t0
	#reactivate IRQ => PIE =1
	addi t0, zero, 1
	wrctl status, t0
	#reste : 
	addi t0, zero, EDGECAPTURE_AD #t0 = adresse de edgecapture
	ldw t1, 0(t0) #t1 = edgecapture 
	andi t1,t1, 0b1 #mask t1 to only consider the first buttons
	beq t1, zero,endbis_for_edge  #si edgecpature=0 va a la fin
	stw zero, 0(t0);; store the cleared value of edgecapture
	addi sp,sp,-64
	stw ra, 0(sp)
	stw t0, 4(sp)
	stw t1, 8(sp)
	stw t2, 12(sp)
	stw t3, 16(sp)
	stw t4, 20(sp)
	stw t5, 24(sp)
	stw t6, 28(sp)
	stw t7, 32(sp)
	stw v0, 36(sp)
	stw v1, 40(sp)
	stw a0, 44(sp)
	stw a1, 48(sp)
	stw a2, 52(sp)
	stw a3, 56(sp)
	stw ea ,60(sp)
	#buttn 1 a ete activé :
	call spend_time 
	ldw ra, 0(sp)
	ldw t0, 4(sp)
	ldw t1, 8(sp)
	ldw t2, 12(sp)
	ldw t3, 16(sp)
	ldw t4, 20(sp)
	ldw t5, 24(sp)
	ldw t6, 28(sp)
	ldw t7, 32(sp)
	ldw v0, 36(sp)
	ldw v1, 40(sp)
	ldw a0, 44(sp)
	ldw a1, 48(sp)
	ldw a2, 52(sp)
	ldw a3, 56(sp)
	ldw ea, 60(sp)
	addi sp, sp, 64
	jmpi end_button_IRQ
	endbis_for_edge: 
	stw zero, 0(t0);; store the cleared value of edgecapture
	end_button_IRQ:	
	;stw t0, zero, 1
	;sub t0, zero, t0
	;addi t0,t0,-1
	wrctl status, zero ;; on remet le PIE a zero
	#reenable interrupts for the button:
	addi t0, zero, 0b101
	wrctl ienable, t0
	ret 


game_reset : 
	#Q :enable interrupts by writing 1 to the PIE  => Q : faut aussi ecrire 1 dans le EPIE?
	addi t0, zero, 1
	wrctl status, t0
	#enabeling IRQS for buttons and timer
	addi t0, zero, 0b101
	wrctl ienable, t0
	#initialize stack pointer : Q => valeur particuliere? 
	addi t0, zero, 0x2000
	add sp, zero, t0
	#set la periode du timer a 100 ms ( 5millions)  
	addi t0, zero, 0b1001100
	slli t0, t0, 16
	addi t0,t0, 0b0100101101000000
	addi t1, zero, TIMER
	addi t1,t1,4
	stw t0, 0(t1)
	# pour demarer le timer : start = 1, cont = 1, ito = 1 
	addi t0, zero, 0b1011
	addi t1, zero, TIMER
	addi t1,t1,8
	stw t0, 0(t1)
	ret  
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; DO NOT CHANGE ANYTHING BELOW THIS LINE
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ----------------- Common functions --------------------
; a0 = tenths of second
display:
    addi   sp, sp, -20
    stw    ra, 0(sp)
    stw    s0, 4(sp)
    stw    s1, 8(sp)
    stw    s2, 12(sp)
    stw    s3, 16(sp)
    add    s0, a0, zero
    add    a0, zero, s0
    addi   a1, zero, 600
    call   divide
    add    s0, zero, v0
    add    a0, zero, v1
    addi   a1, zero, 100
    call   divide
    add    s1, zero, v0
    add    a0, zero, v1
    addi   a1, zero, 10
    call   divide
    add    s2, zero, v0
    add    s3, zero, v1

    slli   s3, s3, 2
    slli   s2, s2, 2
    slli   s1, s1, 2
    ldw    s3, font_data(s3)
    ldw    s2, font_data(s2)
    ldw    s1, font_data(s1)

    xori   t4, zero, 0x8000
    slli   t4, t4, 16
    add    t5, zero, zero
    addi   t6, zero, 4
    minute_loop_s3:
    beq    zero, s0, minute_end
    beq    t6, t5, minute_s2
    or     s3, s3, t4
    srli   t4, t4, 8
    addi   s0, s0, -1
    addi   t5, t5, 1
    br minute_loop_s3

    minute_s2:
    xori   t4, zero, 0x8000
    slli   t4, t4, 16
    add    t5, zero, zero
    minute_loop_s2:
    beq    zero, s0, minute_end
    beq    t6, t5, minute_s1
    or     s2, s2, t4
    srli   t4, t4, 8
    addi   s0, s0, -1
    addi   t5, t5, 1
    br minute_loop_s2

    minute_s1:
    xori   t4, zero, 0x8000
    slli   t4, t4, 16
    add    t5, zero, zero
    minute_loop_s1:
    beq    zero, s0, minute_end
    beq    t6, t5, minute_end
    or     s1, s1, t4
    srli   t4, t4, 8
    addi   s0, s0, -1
    addi   t5, t5, 1
    br minute_loop_s1

    minute_end:
    stw    s1, LEDs(zero)
    stw    s2, LEDs+4(zero)
    stw    s3, LEDs+8(zero)

    ldw    ra, 0(sp)
    ldw    s0, 4(sp)
    ldw    s1, 8(sp)
    ldw    s2, 12(sp)
    ldw    s3, 16(sp)
    addi   sp, sp, 20

    ret

flip_leds:
    addi t0, zero, -1
    ldw t1, LEDs(zero)
    xor t1, t1, t0
    stw t1, LEDs(zero)
    ldw t1, LEDs+4(zero)
    xor t1, t1, t0
    stw t1, LEDs+4(zero)
    ldw t1, LEDs+8(zero)
    xor t1, t1, t0
    stw t1, LEDs+8(zero)
    ret

spend_time:
    addi sp, sp, -4
    stw  ra, 0(sp)
    call flip_leds
    ldw t1, LFSR(zero)
    add t0, zero, t1
    srli t1, t1, 2
    xor t0, t0, t1
    srli t1, t1, 1
    xor t0, t0, t1
    srli t1, t1, 1
    xor t0, t0, t1
    andi t0, t0, 1
    slli t0, t0, 7
    srli t1, t1, 1
    or t1, t0, t1
    stw t1, LFSR(zero)
    slli t1, t1, 15
    addi t0, zero, 1
    slli t0, t0, 22
    add t1, t0, t1

spend_time_loop:
    addi   t1, t1, -1
    bne    t1, zero, spend_time_loop
    
    call flip_leds
    ldw ra, 0(sp)
    addi sp, sp, 4

    ret

; v0 = a0 / a1
; v1 = a0 % a1
divide:
    add    v0, zero, zero
divide_body:
    add    v1, a0, zero
    blt    a0, a1, end
    sub    a0, a0, a1
    addi   v0, v0, 1
    br     divide_body
end:
    ret



font_data:
    .word 0x7E427E00 ; 0
    .word 0x407E4400 ; 1
    .word 0x4E4A7A00 ; 2
    .word 0x7E4A4200 ; 3
    .word 0x7E080E00 ; 4
    .word 0x7A4A4E00 ; 5
    .word 0x7A4A7E00 ; 6
    .word 0x7E020600 ; 7
    .word 0x7E4A7E00 ; 8
    .word 0x7E4A4E00 ; 9
    .word 0x7E127E00 ; A
    .word 0x344A7E00 ; B
    .word 0x42423C00 ; C
    .word 0x3C427E00 ; D
    .word 0x424A7E00 ; E
    .word 0x020A7E00 ; F
