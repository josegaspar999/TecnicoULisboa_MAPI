function prg_tfire = plc_map_inputs( inp_bits_lst, trans_lst, options )
%
% inp_bits_lst : 1xN : PLC input module list of bits
% trans_lst : 1xN : Petri net transitions list (indexes, not strings)
%
% prg_tfire : list of strings : lines of structured text

% IST 2015, JG

if nargin<3
    options= [];
end
if nargin<1
    % do a simple test
    prg_tfire = plc_map_inputs( [1 2 3], [4 5 6] );
    return
end
if isempty(inp_bits_lst)
    prg_tfire= {};
    return
end

prg_tfire= {''; '(* --- PNC: Map inputs --- *)'; ''};

if ~iscell(inp_bits_lst)
    % single mapping instruction (N columns => N outputs)
    prg_tfire = plc_map_inputs_from_array( prg_tfire, inp_bits_lst, trans_lst, options );

else % if iscell(inp_bits_lst)
    % multiple mapping instructions in a list, N*size(inp_bits_lst,1) outputs
    for i=1:size(inp_bits_lst,1)
        inp_bits_lst2= inp_bits_lst{i,1};
        trans_lst2= inp_bits_lst{i,2};
        prg_tfire = plc_map_inputs_from_array( prg_tfire, inp_bits_lst2, trans_lst2, options );
    end
    
end

return; % end of main function


% --------------------------------------------------------------------
function prg_tfire = plc_map_inputs_from_array( prg_tfire, inp_bits_lst, trans_lst, options )

if isstruct(inp_bits_lst)
    prg_tfire = plc_map_inputs_from_struct( prg_tfire, inp_bits_lst, options );
    return;
end

for i=1:size(inp_bits_lst,2)
    src= conjunction_of_inputs(inp_bits_lst(:,i));
    dst= plc_z_code_helper('name_trans', trans_lst(i));
    str= [dst ' := BOOL_TO_INT( ' src ' );'];
    prg_tfire{end+1,1}= str;
end


function prg_tfire = plc_map_inputs_from_struct( prg_tfire, in_out, options )
% multiKeyTrue= struct('op','OR_of_ANDs', 'transId',28, ...
%     'lst', {[0 1], [0 2], [0 3], [1 2], [1 3], [2 3]} );
% inp_map{end+1,1}= multiKeyTrue;
% 
% multiKeyFalse= struct('op','NOR_of_ANDs', 'transId',29, ...
%     'lst', {[0 1], [0 2], [0 3], [1 2], [1 3], [2 3]} );
% inp_map{end+1,1}= multiKeyFalse;

% for all items of lst, create a conjunction string
% join all strings into a global OR

switch in_out.op
    case 'OR_of_ANDs'
        src= or_of_ands(in_out.lst);
    case 'NOR_of_ANDs'
        src= ['NOT( ' or_of_ands(in_out.lst) ' )'];
    otherwise
        error('inv op')
end

dst= plc_z_code_helper('name_trans', in_out.transId);

str= [dst ' := BOOL_TO_INT( ' src ' );'];
prg_tfire{end+1,1}= str;


% --------------------------------------------------------------------
function str= name_inp(inp_bit)
if inp_bit>=0
    % positive input
    str= plc_z_code_helper('name_inp', inp_bit);
elseif inp_bit<=100
    % negative input
    str= -(inp_bit+100); % e.g. converts -103 to 3
    str= ['NOT(' plc_z_code_helper('name_inp', str) ')'];
else
    error('found input in the range -99:-1');
end


function src= conjunction_of_inputs(inp_bits_lst)
if size(inp_bits_lst,1)>1 && size(inp_bits_lst,2)>1
    error('inp_bits_lst must be a vector, not a matrix');
end
for j=1:length(inp_bits_lst)
    tmp= name_inp(inp_bits_lst(j));
    if j==1
        src= tmp;
    else
        src= [src ' AND ' tmp];
    end
end


function str= or_of_ands(lst)
for i=1:length(lst)
    inp_bits_lst= lst{i};
    if i==1
        str= ['(' conjunction_of_inputs(inp_bits_lst) ')'];
    else
        str= [str ' OR (' conjunction_of_inputs(inp_bits_lst) ')'];
    end
end
