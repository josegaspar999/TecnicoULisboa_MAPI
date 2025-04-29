
Example of making a PLC program from a Petri net

2015 JG

------------------------------------------------


1. Test function to run:

>> tst0_demo_timed

The output is writen in
	tst0_mk_program_res.txt

Requires compiler functions
	../pn_to_plc_compiler/*.m

The Petri net is loaded from:
	define_petri_net()

Mapping of the Petri net to physical inputs and outputs is done in:
	define_input_mapping(), define_output_mapping()


2. To do in Unity

- Create project, including the declaration of the hardware

- Create a ST section under MAST, and paste there the code

- Declare in "Variables & FB instances -> Elementary Variables"
timer_output_flag	BOOL
my_time_i		TIME (i indicates 1, 2, ...)

- Declare in "Variables & FB instances -> Elementary FB Instances"
MY_TON_i		Function block TON
 