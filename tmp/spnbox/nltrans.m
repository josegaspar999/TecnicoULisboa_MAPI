function [dtr] = nltrans(Dm, Dp, X)

% NLTRANS - Find all transitions that cannot be made live
%
% [nlt] = nltrans(D)
%
% [nlt] = nltrans(D^-, D^+, X)
%
% nlt is a vector, nlt(i) = 0 if t_i can be made live.
%
% X is a vector indicating transitions which cannot be made live for 
% other reasons. E.g. X = [1, 3, 6] indicates the transitions t_1, t_3
% and t_6.

% Written by Marian V. Iordache, miordach@nd.edu

if nargin >= 2
    chk_data(Dm,Dp);
    D = Dp - Dm;
elseif nargin == 1
    D = Dm;
end

if nargin < 3
    X = zeros(0,1);
end

[m0, n0] = size(D);

Z = zeros(length(X), n0);
for i = 1:length(X)
    Z(i,X(i)) = 1;
end
Z = [Z; -Z];
D = [D; Z];
[m0, n0] = size(D);
A = [D'; -eye(m0)];

m = m0+n0;          % A is m by n
n = m0;

cov = zeros(n0,1);  % cov(i) will be set to 1 if t_i
                    % belongs to some nonnegative invariant
                    % x, i.e. x'*A = 0 and x >= 0

B = zeros(n+1,1);
B(n+1) = 1;
f = ones(m,1);
vlb = zeros(m,1);
vub = 1e6*ones(m,1);

ilst = ones(1,n0); ilst(X) = 0; ilist = find(ilst);
opt = optimset('Display','off','LargeScale','off');
% opt = optimset('Display','off');% to be used for the future version of linprog

while sum(~cov)
    M = [A'; ~cov', zeros(1,m-n0)]; xlen = length(B);
    Meq = M(1:n,:); Beq = B(1:n); Min = M(n+1:xlen,:); Bin = B(n+1:xlen);
    %[x, lam, how] = lp(f, -M, -B, vlb, vub, [], n, -1);
    [x, lam, flag] = linprog(f, -Min, -Bin, Meq, Beq, vlb, vub, [], opt);
   
    %if grp(how, 'infeasible') == 0
    if flag > 0
        x = x .* (abs(x) > 1e-10);
        cov = cov | x(1:n0);
        x = vlb;
    else
        break
    end
end

dtr = ~cov;
