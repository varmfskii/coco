	section code
	include sdccmd_h.asm
	export start
start:
	lbsr sdc_enable
	ldu #$0400
	lbsr sdc_img_info
	lbsr sdc_disable
	rts
	endsection
