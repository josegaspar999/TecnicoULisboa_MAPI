function plc_make_program(ofname, PN, input_map, output_map, show_places)
%
% Write to file a PLC program (structured text) given a Petri net (PN),
% and given the input/output physical mappings. May also add a list of
% places (only one active at each moment), to be shown as PLC outputs.

% IST 2015, JG

if nargin<1
    demo
    return
end
if nargin<5
    show_places= [];
end

% Create PLC code to map PLC inputs to PN transistions
prg_tfire= plc_map_inputs( input_map );

% Create PLC code to make timed transitions (fire after timeouts)
prg_ttrans= {};
if isfield(PN, 'ttimed') && ~isempty(PN.ttimed)
    prg_ttrans= plc_timed_transitions( PN.ttimed );
end

% Create PLC code to run the Petri Net
%[prg_pn_ini, prg_pn]= plc_encode_petri_net( PN.pre, PN.pos, PN.mu0, PN.tprio );
[prg_pn_ini, prg_pn]= plc_encode_petri_net( PN );

% Create PLC code to map PN places to PLC outputs
prg_act= plc_output_if_any_place( output_map );

% Create PLC code to output debug/monitor info
prg_yout= {};
if ~isempty(show_places)
    prg_yout= plc_encode_places( show_places{1}, show_places{2});
end

% Save all code to a text file
if ischar(ofname), fprintf(1, '-- Writing "%s"...', ofname); end
text_write(ofname, ...
    prg_pn_ini, ...
    prg_tfire, ...
    prg_ttrans, ...
    prg_pn, ...
    prg_act, ...
    prg_yout)
if ischar(ofname), fprintf(1, ' done.\n'); end

return


function text_write(filename, varargin)

if isnumeric(filename)
    % received a fileId, no need the fopen
    fid= filename;
else
    % filename is string, use fopen
    fid = fopen(filename, 'wt');
    if fid<1
        error(['Opening file: ' filename])
    end
end

for j=1:length(varargin)
    y= varargin{j};
    for i=1:length(y)
        fprintf(fid, '%s\n', y{i});
    end
end

if ~isnumeric(filename)
    % created a fileId hence need the fclose
    fclose(fid);
end


function demo

% write to stdout (change to a string to generate an output file)
ofname= 1;

% make a Petri net with two places, timed transitions
PN= struct('pre',[1 0;0 1]', 'pos',[0 1; 1 0]', 'mu0',[1;0], ...
    'ttimed', [0.5 1 1; 0.5 2 2]);

% use no inputs
input_map= [];

% map one place to the buzzer and the other to a LED
output_map= [1 16; 2 17];

% show the resulting structured text
plc_z_code_helper('config', 's3_DMY28FK');
plc_make_program(ofname, PN, input_map, output_map)
