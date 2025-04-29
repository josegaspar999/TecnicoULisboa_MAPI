function [prg_pn1, prg_pn2] = plc_encode_petri_net ( pre, pos, mu0, tprio, options )
%
% Convert a Petri net to PLC (structured text) code
%
% pre: NxM : N places M transitions Petri net D- matrix
% pos: NxM : N places M transitions Petri net D+ matrix
% mu0: Nx1 : initial state
% tprio: 1xT : (facultative) list of priority transitions (default is empty)
%
% prg_pn1: list of strings : initialization code (lines in structured text)
% prg_pn2: list of strings : Petri net run (lines in structured text)
%
% Usages:
% [prg_pn1, prg_pn2] = plc_encode_petri_net ( pre, pos, mu0, tprio, options )
% [prg_pn1, prg_pn2] = plc_encode_petri_net ( PN, options )

% Note: in a future version the input arguments may be a structure
% including pre, pos, mu0, tprio and an aditional parameter referring to
% timed transitions (ttrans).

% IST 2015, JG

if nargin<1
    demo
    return
end

% ------------------
% Usage1: [prg_pn1, prg_pn2] = plc_encode_petri_net ( PN, options )
% PN is given as a structure

if isstruct(pre)
    PN= pre;
    tprio= [];
    if isfield(PN, 'tprio')
        tprio= PN.tprio;
    end
    if nargin<2, options= []; else options= pos; end
    [prg_pn1, prg_pn2] = plc_encode_petri_net ( PN.pre, PN.pos, PN.mu0, tprio, options );
    return
end

% ------------------
% Usage2: [prg_pn1, prg_pn2] = plc_encode_petri_net ( pre, pos, mu0, tprio, options )

if nargin<4
    tprio= [];
end
if nargin<5
    options= [];
end

if nargout<2
    % single output containing initialization and state update
    mysprintf_ini;
    encode_PN_mu0( mu0 );
    encode_PN_pre_pos( pre, pos, tprio(:)' );
    prg_pn1= mysprintf_get;
else
    % separate initialization and state update
    mysprintf_ini;
    encode_PN_mu0( mu0 );
    prg_pn1= mysprintf_get;
    % make state update code
    mysprintf_ini;
    encode_PN_pre_pos( pre, pos, tprio(:)' );
    prg_pn2= mysprintf_get;
end

return; % end of main program


function encode_PN_mu0( mu0)
mysprintf( '\n(* --- PNC: Petri net initialization --- *)');
mysprintf( '\nIF %s=0 THEN', nameTi(0));
mysprintf( '');
for i=1:length(mu0)
    mysprintf_cat( ' %s:=%d;', namePi(i), round(mu0(i)));
end
mysprintf( ' %s:=1;', nameTi(0));
mysprintf( 'END_IF;');


function encode_PN_pre_pos( pre, pos, tprio )
mysprintf( '\n(* --- PNC: Petri net loop code --- *)');
iRange= 1:size(pre,2);
tmp= setdiff(iRange, tprio);
iRange= [tprio tmp];
for i= iRange
    encode_PN_transition( i, pre(:,i), pos(:,i))
end


function encode_PN_transition( ti, ti_pre, ti_pos)
% write the checking of qk(i) and the pre-conditions
% IF trans01>0 AND place01>=pre(1,1) AND place02>=pre(1,1)
% THEN place01-=trans01; place02-=trans01;
%  place03+=pos(3,1); place04+=pos(4,1);
% END_IF;

mysprintf( '\nIF %s>0', nameTi(ti));
for i=1:length(ti_pre)
    if ti_pre(i)>0
        mysprintf_cat( ' AND %s>=%d', namePi(i), ti_pre(i));
    end
end

mysprintf( 'THEN\n');
for i=1:length(ti_pre)
    if ti_pre(i)>0
        mysprintf_cat( ' %s:=%s-%d;', namePi(i), namePi(i), ti_pre(i));
    end
end
mysprintf( '');
for i=1:length(ti_pos)
    if ti_pos(i)>0
        mysprintf_cat( ' %s:=%s+%d;', namePi(i), namePi(i), ti_pos(i));
    end
end
mysprintf( 'END_IF;');


function str= nameTi(ind)
str= plc_z_code_helper('name_trans', ind);

function str= namePi(ind)
str= plc_z_code_helper('name_place', ind);


function mysprintf_ini
global MYSPR
MYSPR= {};

function mysprintf(varargin)
global MYSPR
MYSPR{end+1,1}= sprintf(varargin{:});

function mysprintf_cat(varargin)
global MYSPR
str= sprintf(varargin{:});
if length(MYSPR{end,1})+length(str)<76
    MYSPR{end,1}= [MYSPR{end,1} str];
else
    MYSPR{end+1,1}= [str];
end

function sList= mysprintf_get
global MYSPR
sList= MYSPR;


function demo
pre= [1 0 0; 0 1 0; 0 0 1]'; % D-
pos= [0 1 0; 0 0 1; 1 0 0]'; % D+
mu0= [1 0 0];
[prg_pn1, prg_pn2] = plc_encode_petri_net ( pre, pos, mu0 )
return
