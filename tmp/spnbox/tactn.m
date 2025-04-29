function [Dma, Dpa, Dmra, Dpra, TA, unique] = tactn(Dm, Dp, T, X, Dcm, Dcp)

% TACTN - Computes a T-minimal active subnet of a Petri net
%
% [Dma, Dpa, Dmra, Dpra, TA] = tactn(Dm, Dp, T, Z)
% [Dma, Dpa, Dmra, Dpra, TA, unique] = tactn(Dm, Dp, T, Z)
%
% This function computes a subnet of the Petri net structure (Dm, Dp), 
% such that
% (a) the subnet can be made live
% (b) it contains the transitions in T and no transitions in Z
% (c) there is no other subnet satisfying (a) and (b) and having less 
%     transitions.
%
%  -  (Dma, Dpa) and (Dmra, Dpra) are incidence matrix representations
%     of the computed subnet.
%  -  TA is the set of transitions of the subnet.
%  -  unique = 1 if there is a unique subnet satisfying (a), (b) and (c).
%
% When no subnet satisfying (a) and (b) exists, the procedure yields a 
% subnet such that
% (a) the subnet can be made live
% (b) it does not contain the transitions in Z
% (c) there is no other subnet satisfying (a) and (b) and having more 
%     transitions in T.
%
%  -  unique = 1 if there is a unique subnet satisfying (a), (b) and (c).
%
% The function can be employed to do only an update in the following format
%
% [Dma, Dpa, Dmra, Dpra] = tactn(Dm, Dp, T, Z, Dma, Dpa)
%
% In this format only an update is made: the transitions of the
% active subnet are found based only on the former subnet given 
% by Dma and Dpa.
%
% For convenience, the outcome is produced as matrices of the 
% same size as (Dm, Dp): (Dma, Dpa) and also at reduced size: 
% (Dmra, Dpra), where 'm' stands for '-' and 'p' for '+'.
%
% The default values for T and Z are T - the total set of transitions
% and Z - empty. Therefore the following simplified formats can be used:
%
% [Dma, Dpa, Dmra, Dpra] = tactn(Dm, Dp)
%
% [Dma, Dpa, Dmra, Dpra] = tactn(Dm, Dp, T)
%
% When only two arguments are used, TACTN is equivalent to ACTN: it 
% computes the maximal active subnet.
%
% See also ACTN and NLTRAN. 

% Written by Marian V. Iordache, miordach@nd.edu

% Marian V. Iordache, Sep. 5, 2000.
% Revised on Oct. 24, 2001, and enhanced in February 2002.

upd = 1;
[m, n] = size(Dm);

if nargin < 6, upd = 0; end
if nargin < 4, X = []; end
if nargin < 3, T = 1:n; end
if nargin < 2, [Dm, Dp] = d2dd(Dm); end
if ~T, T = 1:n; end
if ~X, X = []; end

D = Dp - Dm;
v = ones(1,n); v(X) = 0;
t = zeros(1,n); x0 = t'; t(T) = 1;
if upd == 1
   [m0, n0] = size(Dcm);
   tl0 = [sum(Dcm+Dcp,1), zeros(1,n-n0)];  
   tl1 = [zeros(1, n0), ones(1, n-n0)];
   pl1 = [zeros(m0, 1); ones(m-m0, 1)];
   % tl0: the transitions of the given act. subnet
   % tl1 and pl1: the new places and transitions
   tl = tl0;
   while ~isempty(find(tl))
      pl = and(pl1, sum(Dm(:,find(tl)),2)); % pl = \bullet tl\cap pl1
      tl = and(tl1, sum(Dp(find(pl),:),1));
      tl0 = tl0 + tl;
   end
   TA = tl0(:);
   if nargout > 5
       warning('TACTN, update mode: Too many output arguments.');
   end
else
   % Checking the feasibility
   ind = find(v);
   if isempty(ind)
      TA = 0;
   else
      vlb = t(ind);
      vub = Inf*ones(1, length(ind));
      Dx = D(:,ind);
      f = ones(1, length(ind));
      B = zeros(m, 1); 
      opt = optimset('Display','off','LargeScale','off');      
      % opt = optimset('Display','off');% to be used for the future version of linprog
      [x, f, flag] = linprog(f, -Dx, -B, [], [], vlb, vub, [], opt); 
      %[x, lam, how] = lp(f, -Dx, -B, vlb, vub, [], 0, -1);
      x = x .* (abs(x) > 1e-10);
      %flag = -2*(grp(how, 'infeasible')) + 1; 
      
      if flag <= 0 % if infeasible, find a T'-minimal approximation
         if ~flag
            warning('LINPROG failure ...');
         end
         TA = maxactn(D, t, v); % the transitions are in find(TA)
      else  % if feasible, find the T-minimal subnet
         x0(ind) = x;
         TA = minactn(x0, D, t);
      end
   end
end

ltn = find(TA);
lpn = find(sum(Dp(:,ltn),2)); % lpn = ltn\bullet

Dma = zeros(m,n); Dpa = Dma;
Dmra = Dm(lpn, ltn);
Dpra = Dp(lpn, ltn);
Dma(lpn, ltn) = Dmra;
Dpa(lpn, ltn) = Dpra;
if nargout > 5 % set unique to zero if this is not the only TA&t -minimal act. sbn.
    unique = isunique(D, TA(:)', t, v); 
end
TA = ltn;

% ========================================================================

function [TA] = maxactn(D, t, z) % t must be such that t(i) = 1 iff t_i is in T
                                 % also z is such that z(i) = 0 iff t_i is in Z

[m,n] = size(D);   
vub = Inf*ones(1,n);
vlb = zeros(1,n);
x = zeros(n,1);
t0 = t(:);
t = t & z;
opt = optimset('Display','off','LargeScale','off');      
% opt = optimset('Display','off');% to be used for the future version of linprog
while sum(t)                                  
   ind = find(t);
   nx = length(ind);
   Dx = [D(:,ind); ones(1, nx)];
   f = ones(1, nx);
   B = [zeros(m, 1); 1]; 
   [x1, f, flag] = linprog(f, -Dx, -B, [], [], vlb(ind), vub(ind), [], opt); 
   %[x1, lam, how] = lp(f, -Dx, -B, vlb(ind), vub(ind), [], 0, -1);
   x1 = x1 .* (abs(x1) > 1e-10);
   %flag = -2*(grp(how, 'infeasible')) + 1;
   
   if flag <= 0
      if ~flag
         warning('LINPROG failure ...');
      end
      t = 0;
   else
      x(ind) = x(ind) + x1;
      t(ind(find(x1))) = 0;
   end
end
TA = minactn(x, D, t0 & x);
   
% =====================================================

function [TA] = minactn(x, D, t) % t must be such that t(i) = 1 iff t_i is in T

[m,n] = size(D);   
vub = Inf*ones(1, n);
opt = optimset('Display','off','LargeScale','off');      
% opt = optimset('Display','off');% to be used for the future version of linprog
for i = 1:n
   if x(i) & (~t(i))
      v = x; v(i) = 0;
      x0 = zeros(n, 1);
      ind = find(v);
      Dx = D(:,ind);
      f = ones(1, length(ind));
      B = zeros(m, 1); 
      [x1, f, flag] = linprog(f, -Dx, -B, [], [], t(ind), vub(ind), [], opt); 
      %[x1, lam, how] = lp(f, -Dx, -B, t(ind), vub(ind), [], 0, -1);
      x1 = x1 .* (abs(x1) > 1e-10);
      %flag = -2*(grp(how, 'infeasible')) + 1;
      
      if flag <= 0
         if ~flag
            warning('LINPROG failure ...');
         end
         break;
      else
         x0(ind) = x1;
         x = x0;
      end
   end
end
TA = x;      

% =========================================================

function unique = isunique(D, x, t, z)  % t must be such that t(i) = 1 iff t_i is in T
                                        % also z is such that z(i) = 0 iff t_i is in Z
unique = 1;
v = x & ~t & z; % the transitions not in T and X of the act. sbn.
vlb = t&x;
vub = Inf*ones(1,length(v));
[m, n] = size(D);
opt = optimset('Display','off','LargeScale','off');      
% opt = optimset('Display','off');% to be used for the future version of linprog
for i = find(v(:)')
    z1 = z;
    z1(i) = 0;
    ind = find(z1);
    Dx = [D(:,ind); ones(1,length(ind))]; B = [zeros(m, 1); 1];
    f = ones(1,length(ind));
    [x1, f, flag] = linprog(f, -Dx, -B, [], [], vlb(ind)', vub(ind)', [], opt); 
    if flag >= 0 % flag > 0 if feasible
        if ~flag
            warning('LINPROG failure ...');
        end
        unique = 0;
        break;
    end
end


