function ret= plc_z_code_helper(op, a1, a2)
%
% Convert indexes into PLC physical addresses (memory, input, output).
% Memory is used to represent Petri net transitions and places.

% IST 2015, JG

global zCodeConfig

if nargin<1
    op= 'config_get';
end
if ~isempty(zCodeConfig)
    zCode= plc_z_code_helper_config();
end

switch op
    case 'config'
        % choose the hardware to output code for
        tpMem= [100 199 200 299];
        if nargin>=2
            hwStr= a1;
        else
            hwStr= plc_z_code_helper_config_questdlg;
        end
        if nargin>=3
            tpMem= a2;
        end
        zCodeConfig= struct('hw', hwStr, 'tpMem', tpMem);
        ret= plc_z_code_helper_config();
        
    case 'config_tpmem'
        if isempty(zCodeConfig)
            plc_z_code_helper('config'); % ask info to the user
        end
        zCodeConfig.tpMem= a1;
        ret= zCodeConfig;

    case 'config_get'
        % get current hardware configuration
        if ~isempty(zCodeConfig)
            ret= zCode; % return current info
        else
            ret= plc_z_code_helper('config'); % ask info to the user
        end
        
    case 'name_trans'
        % Petri net transitions t1..t99 (t0 can be a reset transition)
        error_if_not_in_range(a1, 0, zCode.transMax-zCode.transMin);
        ret= [zCode.trans sprintf('%d', zCode.transMin+a1)];
        
    case 'name_place'
        % Petri net places p1..p99 (p0 usually not used)
        error_if_not_in_range(a1, 0, zCode.placeMax-zCode.placeMin);
        ret= [zCode.place sprintf('%d', zCode.placeMin+a1)];
        
    case 'name_inp',
        % PLC input can be %i0.3.0 .. %i0.3.15
        error_if_not_in_range(a1, zCode.inpMin, zCode.inpMax);
        ret= [zCode.inp sprintf('%d', a1)];
        
    case 'name_outp',
        % ** REWRITE **
        % http://users.isr.tecnico.ulisboa.pt/~jag/course_utils/plc_io/io_maps.html
        % PLC output can be %i0.3.16 .. %i0.3.27
        error_if_not_in_range(a1, zCode.outpMin, zCode.outpMax);
        ret= [zCode.outp sprintf('%d', a1)];
        
    case 'report'
        % tell things to do e.g. in Unity
        error('not implemented yet')
        
    otherwise
        error('Invalid input arg "op"');
end


function error_if_not_in_range(a1, a1_min, a1_max)
if a1<a1_min || a1_max<a1
    error(['Value ' num2str(a1) ' is outside valid range ' ...
        num2str(a1_min) '..' num2str(a1_max) ' .']);
end


function zCode= plc_z_code_helper_config()
global zCodeConfig

zCode= [];
zCode= add_field( zCode, 'trans', '%mw', zCodeConfig.tpMem(1:2)); %[100 199]);
zCode= add_field( zCode, 'place', '%mw', zCodeConfig.tpMem(3:4)); %[200 299]);

switch zCodeConfig.hw
    case 's3_DMY28FK'
        zCode= add_field( zCode, 'inp',  '%i0.3.', [0 15] );
        zCode= add_field( zCode, 'outp', '%q0.3.', [16 27] );

    case 's2_DEY16D2_s4_DSY16T2'
        zCode= add_field( zCode, 'inp',  '%i0.2.', [0 15] );
        zCode= add_field( zCode, 'outp', '%q0.4.', [0 15] );

    case 'm0-9_m10-19'
        zCode= add_field( zCode, 'inp',  '%m', [0 9] );
        zCode= add_field( zCode, 'outp', '%m', [10 19] );

    otherwise
        error('invalid zCodeConfig global string')
end


function zCode= add_field( zCode, name, addr, minMax )
zCode= setfield( zCode, name, addr );
zCode= setfield( zCode, [name 'Min'], minMax(1) );
zCode= setfield( zCode, [name 'Max'], minMax(2) );


function hwInfo= plc_z_code_helper_config_questdlg
hwInfo= questdlg('Select PLC IO modules or memory interface', 'PLC config', ...
    's2_DEY16D2_s4_DSY16T2', 's3_DMY28FK', 'm0-9_m10-19', 'm0-9_m10-19');
