function prg_yout = plc_encode_places( places_lst, outp_bits_lst )
%
% Encode a list of places to a small number of bits,
%  e.g. encode 12 places into 4 bits
%
% if any place in the places_lst then output the code
% if another place and already defined the output, then error
%
% Usage example:
%   prg_yout = plc_encode_places( [6 9 13 7 8 12 5 10 14 4 11 15], [24:27]);
%
% means using PLC digital outputs 24..27 to indicate
% marked p6, p9, ... or p15 (keys 1..12 of a 4x3 keypad)
%
% in this example
%   no key implies output 0000
%   one key imples output 0001 till 1100
%   multiple places marked implies output 1111

% IST 2015, JG

if nargin<1
    places_lst= [6 9 13 7 8 12 5 10 14 4 11 15];
    outp_bits_lst= [24:27];
    prg_yout = plc_encode_places( places_lst, outp_bits_lst )
    return
end

% The code to generate is a simple sequence of IF
% 

prg_yout= {''; '(* --- PNC: Encode places --- *)'; ''};

prg_yout{end+1,1}= 'output_flag:= False;';
prg_yout{end+1,1}= 'output:= 0;';

for i=1:length(places_lst) % 12
    if places_lst(i)<0
        continue;
    end
    prg_yout{end+1,1}= ['IF ' namePi(places_lst(i)) '>0 THEN'];
    prg_yout{end+1,1}= ['  IF output_flag THEN output:=15;']; % error case
    prg_yout{end+1,1}= ['  ELSE output:=' num2str(i) '; output_flag:=True;'];
    prg_yout{end+1,1}= ['  END_IF;'];
    prg_yout{end+1,1}= ['END_IF;'];
end

% convert "output" to the "outp_bits_lst"

for i= 1:length(outp_bits_lst)
    prg_yout{end+1,1}= [nameOutput(outp_bits_lst(i)) ' := ( output & ' num2str(2^(i-1)) ' )<>0;' ];
end

return; % end of main function


function str= nameOutput(ind)
str= plc_z_code_helper('name_outp', ind);

function str= namePi(ind)
str= plc_z_code_helper('name_place', ind);
