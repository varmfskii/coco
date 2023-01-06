	section code
	include sdccmd_h.asm
	export start
start:
	lbsr sdc_enable
	ldu #patt
	lbsr sdc_dir_init
	ldu #$0400
	lbsr sdc_dir_page
	lbsr sdc_disable
	rts
patt:	.ascii "*.*"
	endsection
