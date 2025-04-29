function [v] = isadm(pnobj, L, F, C, b)

% ISADM - Checks whether a set of constraints is admissible based
% on reachability analysis.
%
% A constraint is considered to be admissible if its enforcement
% under the assumption that all transitions are controllable and
% observable does not attempt to inhibit uncontrollable transitions 
% and does not detect unobservable transitions. An admissible cons-
% traint must also be satisfied by the initial marking.
%
% In the formats
%
% [v] = isadm(pnobj, L, b)
% [v] = isadm(pnobj, L, F, b)
% [v] = isadm(pnobj, L, F, C, b)
%
% the coverability graph of the closed-loop is computed to check whether 
%  L*m <= b  or
%  L*m + F*q <= b  or
%  L*m + F*q + C*v <= b  
% is admissible; Dm and Dp are the incidence matrices, Tuc and Tuo
% are the sets of uncontrollable and unobservable transitions, and m0 
% is the initial marking. The return value is a vector such that 
% v(i) = 0 if L(i,:)*m <= b(i) is inadmissible, v(i) = 1 if the 
% constraint is admissible, and v(i) = -1 if admissibility couldn't be
% decided. v(i) = -1 may happen when the controller part of the closed-
% loop is unbounded. 
%
% If it is desired to check whether the constraint is admissible for 
% all initial markings, set pnobj.m0 = []. The admissibility check in
% this case is very fast (no coverability graph is computed.)
% 
% When the coverability graph of the plant is available (see PNCGRAPH),
% the following formats can be used
%
% [v] = isadm(pnobj, L, b, graph)
% [v] = isadm(pnobj, L, F, b, graph)
%
% The disadvantage of using a precomputed plant coverability graph is that
% it is more likely to have a v(i) equal to -1.
%
% See LINENF and PNCGRAPH.

% Written by Marian V. Iordache, miordach@nd.edu

if ~ispn(pnobj), error('First argument is not a PN object. Use GETPN!'); end

isgraph = 0; % isgraph = 1 means that 'graph' input is given
if nargin == 5
    x2 = L; x3 = F; x4 = C; x5 = b; 
    if ~strcmp(class(x5),'double') 
        graph = x5; b = x4; isgraph = 1; C = [];
    end
elseif nargin == 4 
    x2 = L; x3 = F; x4 = C;
    C = [];
    if ~strcmp(class(x4),'double')
        graph = x4; b = x3; isgraph = 1; F = []; 
    else
        b = x4;
    end
elseif nargin == 3
    x2 = L; x3 = F;
    C = []; F = []; b = x3;
elseif nargin == 2
    x2 = L; 
    C = []; F = []; b = []; % structural analysis
else
    error('Not enough or too many input arguments');
end

if isempty(L) & isempty(F) & isempty(C), v = []; return; end

Dm = pnobj.Dm; Dp = pnobj.Dp; Tuc = pnobj.Tuc; Tuo = pnobj.Tuo;
m0 = pnobj.m0(:); D = Dp - Dm;

if ~isgraph
    [m, n] = size(Dm);
else
    m = length(m0);
    n = max([Tuc(:); Tuo(:)]);
end

X = [L F C];
p = length(X(:,1)); % the number of constraints
if isempty(L), L = zeros(p,m); end
if isempty(F), F = zeros(p,n); end
if isempty(C), C = zeros(p,n); end
if isempty(b), m0 = []; end % structural analysis

if isempty(m0)
    LDp = max(0, -L*D-C);
    LDm = max(0,  L*D+C);
    LDp = LDp + max(0, F-LDm);
    LDm = max(LDm, F);
    x = [(LDm(:,Tuc) == 0) (LDp(:,Tuo) == LDm(:,Tuo))];
    nx = length(x(1,:));
    v = ones(p,1);
    for i = 1:nx
        v = v & x(:,i);
    end
    v = v';
    return
end

v(1:p) = 0; % begin initialization of v
% Check the initial marking
ind = find(L*m0 <= b);
v(ind) = 1; % complete initialization of v
if isempty(ind), return; end

L = L(ind,:); F = F(ind,:); C = C(ind,:); b = b(ind);
if ~isgraph 
    [Dfm, Dfp, ms0] = linenf(Dm, Dp, L, b, m0, F, C); % get closed loop
    cpn = getpn; cpn.Dm = Dfm; cpn.Dp = Dfp; cpn.m0 = ms0; % closed loop object
    cpn.Tuc = Tuc; cpn.Tuo = Tuo;
    pplaces = 1:length(m0); % plant places
    cplaces = (length(m0)+1):length(ms0); % control places
    [graph, res] = pncgraph(cpn,[0,1],'ts_adm',pplaces,cplaces);
    if length(ind) > 1
        xres = res;
    else
        xres = {res};
    end
    for i = 1:length(xres)
        v(ind(i)) = -1;
        if isempty(xres{i})
            v(ind(i)) = 1; % declare constraint admissible
        end
        for j = 1:length(xres{i})
            if xres{i}{j}.s > 0
                v(ind(i)) = 0; % declare constraint inadmissible
                break 
            end 
        end
    end
    return
end

% This is the case when the 'graph' argument is already given

LDp = max(0, -L*D);
LDm = max(0,  L*D);
LDp = LDp + max(0, F-LDm);
LDm = max(LDm, F);
LD = LDp - LDm;
% Change Tuc to the set of uncontro. trans. which the controller
% might attempt to inhibit
Tuc = Tuc(find(sum(LDm(:,Tuc) > 0,1)));
% Change Tuo to the set of unobserv. trans. which the controller
% might attempt to detect
Tuo = Tuo(find(sum(LD(:,Tuo) ~= 0,1)));

uclist = zeros(1,n); uolist = uclist;
uclist(Tuc) = 1; uolist(Tuo) = 1;
for i = 1:length(graph)
    mark = graph{i}{1};
    if isempty(ind), return; end
    for j = 1:length(graph{i}{3})
        t = graph{i}{3}{j}.t;
        nnode = graph{i}{3}{j}.n;
        nmark = graph{nnode}{1};
        if t <= n 
            if uclist(t) | uolist(t)
                y1 = L*mark; y2 = L*nmark; % ind changed in this if block
                x = 0; y = 0;
                if uclist(t)
                    x = ((y1 <= b) & (y2 > b)) | (y1 + F(:,t) > b);
                end
                if uolist(t)
                    y = y1 - y2;
                end
                x(find(isnan(x))) = 0; y(find(isnan(y))) = 0;
                xind = find(x|y); v(ind(xind)) = 0; 
                yind = find(isnan(y1) | isnan(y2)); 
                v(ind(yind)) = -1; ind(xind) = []; 
                L(xind,:) = []; F(xind,:) = []; b(xind) = []; % update L, F and b
            end
        end
        if isempty(ind), break; end
    end
end
