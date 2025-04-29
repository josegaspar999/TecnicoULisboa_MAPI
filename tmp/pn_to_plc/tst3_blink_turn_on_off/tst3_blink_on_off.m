function tst3_blink_on_off
%
% Demo of creating PLC Structured Text from a Petri net with IO
%
% May 2020, April 2021 (+1 I/O), J. Gaspar

% 1. assume the compiler in the path
% path(path,'../pn_to_plc_compiler')

% 2. choose hardware modules or memory IO
plc_z_code_helper('config', 'm0-9_m10-19', [300 399 400 499]);

% 3. the compiler just needs PN, input_map, output_map
PN        = define_petri_net;
input_map = define_input_mapping;
output_map= define_output_mapping;

% 4. from here it is automatic, create code for the PLC
ofname= 'tst3_mk_program_res.txt';
plc_make_program( ofname, PN, input_map, output_map )

return; % end of main program


% --------------------------------------------------------------
function PN= define_petri_net

% Define the Petri Net
%  write incidence matrix D by columns (and transpose it)
%  get "pre" (D-) from negative entries of D
%  get "pos" (D+) from positive entries of D
%  define initial marking "mu0"
%
D=[ -1     0     1    -1     1    -1     1
     1    -1     0     0     0     0     0
     0     1    -1     0     0     0     0
     0     0     0     1    -1     0     0
     0     0     0     0     0     1    -1 ];
pre= -D.*(D<0);
pos=  D.*(D>0);
mu0= [1 0 0 0 0]';

% define priority transitions (empty indicates no specific priorities)
tprio= [4 6];

% 0.5 seconds timeout from places p1, p2 and p3 to transitions t1 t2 t3
T= 0.5;
ttimed= [T 1 1; T 2 2; T 3 3]; % column2=place, column3=transition

% output structure
PN= struct('pre',pre, 'pos',pos, 'mu0',mu0, 'tprio',tprio, 'ttimed',ttimed);


% --------------------------------------------------------------
function inp_map= define_input_mapping
% map input bit inpMin+0 and its negation to transitions 4 and 5
zCode= plc_z_code_helper('config_get');
neg= @(x) (-(x+100));

inp_map= { ...
    zCode.inpMin+0,      4 ; ... % input0 fires transition4
    neg(zCode.inpMin+0), 5 ; ... % negative input0 fires t5
    zCode.inpMin+1,      6 ; ... % input1 fires transition6
    neg(zCode.inpMin+1), 7 ; ... % negative input1 fires t7
    };


% --------------------------------------------------------------
function output_map= define_output_mapping
% map PN places 1..3 to the first output bits outpMin + 0..2
zCode= plc_z_code_helper('config_get');

output_map= { ...
    1, zCode.outpMin+0 ; ...
    2, zCode.outpMin+1 ; ...
    3, zCode.outpMin+2 ; ...
    5, zCode.outpMin+3 ;
    };
