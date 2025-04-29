function tst0_demo_timed

% 1. put the compiler in the path
path(path,'../pn_to_plc_compiler')

% 2. choose one of the two hardware setups available in the lab
plc_z_code_helper('config_get'); % do not ask if saved before

% 3. the compiler just needs PN, input_map, output_map
PN        = define_petri_net;
input_map = define_input_mapping;
output_map= define_output_mapping;

% 4. from here it is automatic
ofname= 'tst0_mk_program_res.txt';
plc_make_program( ofname, PN, input_map, output_map )

return; % end of main program


function PN= define_petri_net

% Define the Petri Net
%
mu0= [1 0 0]';
pre= [1 0 0; 0 1 0; 0 0 1]';
pos= [0 1 0; 0 0 1; 1 0 0]';

% define priority transitions (empty indicates no specific priorities)
tprio= [];

% 0.5 seconds timeout from places p1, p2 and p3 to transitions t1 t2 t3
T= 0.5;
ttimed= [T 1 1; T 2 2; T 3 3]; % column2=place, column3=transition

% output structure
PN= struct('pre',pre, 'pos',pos, 'mu0',mu0, 'tprio',tprio, 'ttimed',ttimed);


function inp_map= define_input_mapping
inp_map= {}; % empty input map


function output_map= define_output_mapping(hwInfo)
% map PN places 1..3 to the first output bits outpMin + 0..2
zCode= plc_z_code_helper('config_get');
output_map= { ...
    1, zCode.outpMin+0 ; ...
    2, zCode.outpMin+1 ; ...
    3, zCode.outpMin+2 ;
    };
