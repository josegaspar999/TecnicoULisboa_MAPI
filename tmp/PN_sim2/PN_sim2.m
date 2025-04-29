function [t, M, yout, qin]= PN_sim2( varargin )
% 
% function [t, M, yout, qin]= PN_sim2(Pre, Post, M0, ti_tf, varargin)
% 
% Simulating a Petri net, using a SFC/Grafcet simulation methodology.
% See book "Automating Manufacturing Systems", by Hugh Jack, 2008
% (ch20. Sequential Function Charts)
%
% Petri net model:
%  M(k+1) = M(k) +(Post-Pre)*q(k)
%  Pre and Post are NxM matrices, meaning N places and M transitions
%
% Input:
%  Pre  : NxM : preconditions matrix
%  Post : NxM : postconditions matrix
%  M0   : Mx1 : intial marking
%  ti_tf: 1x2 : init and final time
%
% Output:
%  t   : NTx1 : time vector (steps of 5ms)
%  M   : NTxM : states of the PN along time
%  yout: NTxNO: output of the PN along time
%
% Requires the following auxiliary functions:
%  function act=  PN_s2act(MP)
%  function yout= PN_s2yout(MP)
%  function qk=   PN_tfire(MP, t)

% Nov2011, Nov2016 (output structure), May2020 (extended PN), J. Gaspar
% Jun2021 (allows PN_*.m as arguments), J. Gaspar

[Pre, Post, M0, ti_tf, options, moreargs]= parse_arguments( varargin );
if ~isempty(Pre)
    if nargout==1
        t= PN_sim2_main(Pre, Post, M0, ti_tf, options, moreargs);
    else
        [t, M, yout, qin]= PN_sim2_main(Pre, Post, M0, ti_tf, options, moreargs);
    end
end
return; % end of main function


function [t, M, yout, qin]= PN_sim2_main(Pre, Post, M0, ti_tf, options, varargin)

% 0. Start PN at state M0
%
dt= 5e-3; if length(ti_tf)>=3, dt= ti_tf(3); end
PN= struct('MP',M0, 'trans',zeros(size(Pre,2),1), 'yout',[], ...
    'Pre',Pre, 'Post',Post, ...
    'ti',ti_tf(1), 'tf',ti_tf(2), 'tm',ti_tf(1), 'dt',dt );
if isfield(options, 'PN_tfire'),  PN_tfire = options.PN_tfire; end
if isfield(options, 'PN_s2act'),  PN_s2act = options.PN_s2act; end
if isfield(options, 'PN_s2yout'), PN_s2yout= options.PN_s2yout; end

tSav= (PN.ti:PN.dt:PN.tf)';
MPSav= zeros(length(tSav), length(PN.MP));
youtSav= zeros(length(tSav), length(PN_s2yout(PN.MP)));

h = waitbar(0,'Please wait...');
for i= 1:length(tSav)
    
    PN.tm= tSav(i);

    % 1. Check transitions and update state
    %    ik = PN outputs = system to control inputs
    %    qk = PN inputs  = system to control outputs
    ik=  PN_s2act(PN.MP);
    qk=  PN_tfire(ik, PN.tm);
    %[PN.MP, qk2]= PN_state_step(PN.MP, Post, Pre, qk);
    [PN.MP, ~]= PN_state_step(PN.MP, Post, Pre, qk);
    
    % 2. Define results given the current PN state
    yout= PN_s2yout(PN.MP);
    
    % Log main data i.e. states, enabled firings, results
    MPSav(i,:)= PN.MP';
    qkSav(i,:)= qk'; %qk2';
    youtSav(i,:)= yout;

    waitbar((PN.tm-PN.ti)/(PN.tf-PN.ti), h);

end; % while
close(h);

% define the output arguments i.e. time t, states M, results yout
% (currently not returning inputs/outputs i.e. ik/qk)
%
if nargout==1
    % return data as a structure
    t= struct('t',tSav, 'qin',qkSav, 'M',MPSav, 'yout',youtSav);
else
    % return data separated by various output arguments
    t   = tSav;
    M   = MPSav;
    yout= youtSav;
    qin = qkSav;
end

return


function qk2= filter_possible_firings(M0, Pre, qk)
% verify Pre*q <= M
% try to fire all qk entries

M= M0;
mask= zeros(size(qk));
for i=1:length(qk)
    mask(i)= 1;
    if any(Pre*(mask.*qk) > M)
        % exceeds available markings
        mask(i)= 0;
        %else
        % % mask(i) is ok, apply the firing
        % % (consume some marking)
        % M= M - Pre(:,i)*qk(i);
    end
end
qk2= mask.*qk;


function [MP, qk2]= PN_state_step( MP, Post, Pre, qk )
% Petri net evolution given the desired firing vector qk and
% the incidence matrix D=Post-Pre
%
% MP  : Nx1 : current state, marked places
% Post: NxM : posconditions matrix, marking increment
% Pre : NxM : preconditions matrix, marking decrement (positive entries)
% qk  : Mx1 : desired firing vector
% qk2 : Mx1 : feasible firing vector

qk2= filter_possible_firings(MP, Pre, qk(:));
MP= MP +(Post-Pre)*qk2;


function [Pre, Post, M0, ti_tf, options, moreargs]= parse_arguments( varargin )

options= [];
if nargin<1 && exist( 'PN_sim2_tst.m', 'file' )
    % one default for experiments
    PN_sim2_tst;
    Pre=[]; Post=[]; M0=[]; ti_tf=[]; moreargs=[];
    return
end

if nargin>=4
    % traditional call mode
    % [t, M, yout, qin]= PN_sim2_main(Pre, Post, M0, ti_tf, options)
    Pre= varargin{1}; Post= varargin{2}; M0= varargin{3};
    ti_tf= varargin{4}; moreargs= varargin(5:end);
    return
end

% one input argument, PN as a struct
try
    par= cell2mat(varargin{1});
catch
    par= [];
end
if ~isempty(par)
    % single struct call mode
    % [t, M, yout, qin]= PN_sim2_main(PN, options)

    % define the PN
    if isfield(par, 'Dp') && isfield(par, 'Dm')
        % given Dp and Dm
        Pre = par.Dm;
        Post= par.Dp;
    elseif isfield(par, 'Dp')
        % given just Dp
        D= par.Dp;
        Pre = -D.*(D<0);
        Post=  D.*(D>0);
    else
        % given Pre and Post
        Pre = par.Pre;
        Post= par.Post;
    end
    M0= par.M0;
    
    % simple check and warning
    if any(Pre(:)<0) || any(Post(:)<0) || any(M0(:)<0)
        warning('Found negative entries in Pre, Post or M0')
    end

    % define simulation time
    ti_tf= par.ti_tf;

    % optional args
    if isfield(par, 'options')
       options= par.options;
    end
    if isfield(par, 'PN_tfire'),  options.PN_tfire = par.PN_tfire; end
    if isfield(par, 'PN_s2act'),  options.PN_s2act = par.PN_s2act; end
    if isfield(par, 'PN_s2yout'), options.PN_s2yout= par.PN_s2yout; end
    moreargs= varargin(2:end);
    
    return
end

% no arguments, just return error (future: open a GUI)
error('calling arguments unexpected')

% return; % end of function
