
Convert Petri Net to PLC Structured Text
IST 2015, JG
----------------------------------------

Assuming:
Schneider PLC Premium, "TSX P57",
with an input/output module "TSX DMY 28FK" mounted in slot3.

Code limited to using PLC memory %MW100..%MW299 therefore allowing:
99 transitions
99 places

Main program:
function plc_make_program(ofname, PN, input_map, output_map, show_places)

Demo:
>> plc_make_program

Notes:
need to declare in Unity-Pro some variables / functions
  output            : DINT
  output_flag       : BOOL
  timer_output_flag : BOOL
  my_time_i         : TIME (i indicates 1, 2, ...)
  MY_TON_i          : TON timers
