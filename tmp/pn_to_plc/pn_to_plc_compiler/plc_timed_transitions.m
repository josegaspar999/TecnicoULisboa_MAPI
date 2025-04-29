function prg_ttrans= plc_timed_transitions ( t_trans_place_lst )
%
% t_trans_place_lst : list of 1x3 : list of [timeout place transition]
% timeout   : 1x1 : timeout in seconds
% place     : 1x1 : id (number) of the Petri net (PN) place
% transition: 1x1 : id (number) of the PN transition to fire if timedout
%
% prg_ttrans: list of strings : lines of structured text

% IST 2015, JG

if nargin<1
    % small demo, fire t1, t2 or t3 if timed out in places p1, p11 or p2
    prg_ttrans= plc_timed_transitions( [30e-3 1 1; 30e-3 11 2; 30e-3 2 3] )
    return
end

% MY_TON_0 (IN := %i0.2.0 (*BOOL*),
%           PT := t#5s (*TIME*),
%           Q => %q0.4.0 (*BOOL*),
%           ET => my_time_0 (*TIME*));
% 
% Timed transition is enabled if all the preconditions are true

prg_ttrans= {''; '(* --- PNC: Timed transitions --- *)'; ''};

for i=1:size(t_trans_place_lst,1)

    tvname= ['my_time_' num2str(i)];
    tname= ['MY_TON_' num2str(i)];
    tstr= encode_time(t_trans_place_lst(i,1));
    ostr= plc_z_code_helper('name_trans', t_trans_place_lst(i,2));
    istr= plc_z_code_helper('name_place', t_trans_place_lst(i,3));
    
    prg_ttrans{end+1,1}= [tname '(IN := INT_TO_BOOL(' istr ') (*BOOL*),'];
    prg_ttrans{end+1,1}= ['          PT := ' tstr ' (*TIME*),'];
    prg_ttrans{end+1,1}= ['          Q => timer_output_flag (*BOOL*),'];
    prg_ttrans{end+1,1}= ['          ET => ' tvname ' (*TIME*));'];
    prg_ttrans{end+1,1}= [ostr ':= BOOL_TO_INT(timer_output_flag);'];
    
end


function tstr= encode_time(t)
% t comes in seconds
% msec -> ms
% sec -> s
if t>=1
    % keep in seconds
    tstr= sprintf('t#%fs', t);
else
    % convert to msec
    tstr= sprintf('t#%dms', round(t*1e3));
end
