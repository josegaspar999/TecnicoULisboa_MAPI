function [l, hw] = admcon(s_list,Dm,Dp,ipl,dpl,opl,apl,ntr,M,Tuc,Tuo,DI)

% ADMCON - A procedure to find admissible constraints for siphon control
%
% [a, how] = admcon(s_list, Dm, Dp, ipl, dpl, opl, apl, ntr, M, Tuc, Tuo, Di)
%
% s_list: s_list(i) = 1 if place i is in the siphon, else 0. (Place i 
% has the index i in the incidence matrix D.)
%
% Dm and Dp: the input and output incidence matrices of the Petri net
% (places -> rows and transitions -> columns.)
%
% ipl, dpl, opl: the set of independent, dependent and original places.
%
% apl: the set of places of the active subnet.
%
% ntr: the set of new transitions (those resulted through transition split).
%
% M: the matrix expressing the marking of dpl in terms of that of ipl.
%
% Tuc, Tuo: the sets of the uncontrollable and unobservable transitions
% of the original (target) Petri net. 
%
% Di: the incidence matrix of the target Petri net; Tuc, Tuo are specified
% with respect to Di.
%
% For unspecified arguments, use the empty array [].
%
% a - is a vector such that a'*m >= 1 is admissible.
% 
% how - is set to 0 if no admissible constraint could be found.

% Written by Marian V. Iordache, miordach@nd.edu

hw = 1;

[m, n] = size(Dm);

l = reshape(s_list~=0, m, 1);

if isempty(Tuc) & isempty(Tuo), return; end

D = Dp - Dm;
Ds = D(:,ntr);
d = zeros(m,1); d(apl) = 1;
% npr - is the set of new places which resulted through transition split;
% npr is the postset of ntr.

npr = sum(Dp(:,ntr),2);

% We are interested only in indep places of opl and dep. places of 
% opl in order to check admissibility with regard to Tuc and Tuo.

idx = [];
for i=1:length(ipl)
    if ~isempty(find(opl == ipl(i)))
        idx = [idx, i];
    end
end
mx = max([max(opl), max(ipl), max(dpl)]);
%bopl = zeros(1,mx); bdpl = bopl; bopl(opl) = 1;
%for i = 1:length(dpl)
%    bdpl(dpl(i)) = i;
%end
%ipl = find(bopl(ipl));
%dpl = find(bopl(dpl)); % dependent places which are original, if any
%%M = M(bdpl(dpl),:);

mi = length(ipl);
md = length(dpl);
E = eye(mi);
Z = zeros(mi+md, mi);
for i = 1:mi
    Z(ipl(i),:) = E(i,:);
end
for i = 1:md
    Z(dpl(i),:) = M(i,:);
end
Z = Z(:,idx);
%Z = Z(:,opl);

Auc = Z*DI(:,Tuc); Auo = Z*DI(:,Tuo);
si = find(s_list);

DX = [Auc, Auo, -Auo, -Ds, d]';

[m1, n1] = size(DX); 
b = zeros(m1, 1); b(m1) = 1;

if DX*l >= b
    return
end
np = nlplace(DX(:,si), b); % nlplace is defined below
p = si(find(~np));
bapl = zeros(1,mx); bapl(apl) = 1;
pr = find(bapl(p));
if length(pr) < 2 % failure if less than two places of p in the active subnet
    hw = 0;
    return
end
EX = eye(length(p)); 
DY = DX(:,p);
[z, u] = size(DY);
A  = [EX; DY]; B = [ones(length(p),1); b];
f  = sum(Dm.*(D<0),2); f = f(p); % attempt to minimize the weight of output 
% connections which result for the control place enforcing the admissible 
% constraint. This is a suboptimal solution. 

%[res, how] = solve_ip(f, A, B);
[res, how] = ip_solve(A, B, f);
l = zeros(mx,1);

if length(how) == 2
    if how == 'ok'
        l(p) = res;
    else 
        hw = 0;
    end
end


% -----------------------------------
% A procedure very similar to nltrans

function [dtr] = nlplace(D, b)

[m0, n0] = size(D);

A = [D'; -eye(m0)];

m = m0+n0;          % A is m by n
n = m0;

cov = zeros(n0,1);  % cov(i) will be set to 1 if t_i
                    % belongs to some nonnegative invariant
                    % x, i.e. x'*A = 0 and x >= 0

B = b;
B(n+1) = 1;
f = ones(m,1);
vlb = zeros(m,1);
vub = 1e6*ones(m,1);

ilst = ones(1,n0); ilist = find(ilst);
opt = optimset('Display','off','LargeScale','off');
% opt = optimset('Display','off');% to be used for the future version of linprog

for i = ilist
    if cov(i) == 0
        v = zeros(1,m);
        v(i) = 1;
        M = [A'; v]; xlen = length(B);
        Meq = M(1:n,:); Beq = B(1:n); Min = M(n+1:xlen,:); Bin = B(n+1:xlen);
        %[x, lam, how] = lp(f, -M, -B, vlb, vub, [], n, -1);
        [x, lam, flag] = linprog(f, -Min, -Bin, Meq, Beq, vlb, vub, [], opt);

        %if grp(how, 'infeasible') == 0
        if flag > 0
            x = x .* (abs(x) > 1e-10);
            cov = cov | x(1:n0);
        end
    end
end

dtr = ~cov(1:n0);

