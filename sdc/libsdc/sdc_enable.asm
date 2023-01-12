sdc_enable:
;;; enable command mode
	sty _old_y
	ldy #sdc_param1
	lda #sdc_cmd_mode
	sta sdc_ctrl_latch
	lbsr _nobusy
	rts

sdc_disable:
;;; disable command mode
	clr sdc_ctrl_latch
	lbsr _nobusy
	ldy _old_y
	pshs cc
	puls cc,pc
