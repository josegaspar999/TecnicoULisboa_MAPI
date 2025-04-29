function prg_act = plc_output_if_any_place( places_lst_main, outp_bit_main )
%
% If it is marked any place of a list of places then output true the
% indicated output bit
%
% places_lst_main : 1xN : list of places to check
% outp_bit_main : 1x1 : PLC output bit

% IST 2015, JG

if nargin<1
    prg_act= plc_output_if_any_place( [1, 4:7], 20);
    return
end

prg_act= {''; '(* --- PNC: Output bits --- *)'; ''};

if iscell(places_lst_main)
    % places_lst has all the information in a Nx2 cell (nargin==1)
    for i=1:size(places_lst_main,1)
        places_lst= places_lst_main{i,1};
        outp_bit  = places_lst_main{i,2};
        prg_act   = plc_output_if_any_place_main( prg_act, places_lst, outp_bit );
    end
elseif nargin==1
    % multiple maps one to one (places_lst_main is Nx2)
    for i=1:size(places_lst_main,1)
        places_lst= places_lst_main(i,1);
        outp_bit  = places_lst_main(i,2);
        prg_act   = plc_output_if_any_place_main( prg_act, places_lst, outp_bit );
    end
elseif nargin==2
    % single bit output (nargin==2)
    prg_act = plc_output_if_any_place_main( prg_act, places_lst_main, outp_bit_main );
else
    error('wrong input arguments')
end

return; % end of main function


function prg_act = plc_output_if_any_place_main( prg_act, places_lst, outp_bit )
if isempty(places_lst)
    % nothing more to do
    return
end

str= ['IF INT_TO_BOOL(' namePi(places_lst(1)) ')'];
for i=2:length(places_lst)
    str= [str ' OR INT_TO_BOOL(' namePi(places_lst(i)) ')'];
end
prg_act{end+1,1}= [str];
prg_act{end+1,1}= ['THEN SET(' nameOutput(outp_bit) ');'];
prg_act{end+1,1}= ['ELSE RESET(' nameOutput(outp_bit) ');'];
prg_act{end+1,1}= ['END_IF;'];

return; % end of main program


function str= nameOutput(ind)
str= plc_z_code_helper('name_outp', ind);

function str= namePi(ind)
str= plc_z_code_helper('name_place', ind);
