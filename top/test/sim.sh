iverilog \
	\
	-D ROM_PRG=\"%1\" \
	-D SPM_PRG=\"%2\" \
	-D SIM_CYCLE=%3 \
	\
	-o chip_top.out \
	-s chip_top_test \
	\
	-I ../../top/include \
	-I ../../cpu/include \
	-I ../../bus/include \
	-I ../../io/rom/include \
	-I ../../io/timer/include \
	-I ../../io/uart/include \
	-I ../../io/gpio/include \
	\
	-y ../../top/lib \
	\
	../../top/test/chip_top_test.v \
	../../top/rtl/*.v \
	../../io/rom/rtl/*.v \
	../../io/uart/rtl/*.v \
	../../io/timer/rtl/*.v \
	../../io/gpio/rtl/*.v \
	../../cpu/rtl/*.v \
	../../bus/rtl/*.v 

vvp chip_top.out
pause