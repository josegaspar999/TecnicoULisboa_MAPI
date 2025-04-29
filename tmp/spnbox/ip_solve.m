function [res, mhow] = ip_solve(L, B, f, intlist, ub, lb, ctype)

% IP_SOLVE - Interface to the Mixed Integer Program Solver LP_SOLVE
%
% [res, how] = ip_solve(L, B, f, intlist, ub, lb, ctype)
%
% The function minimizes f'*x subject to Lx >= B and lb <= x <= ub.
% x(i) is an integer if intlist(i) is not zero. If ctype is given, 
% the inequality constraints are interpreted as follows:
%  L(i,:)x <= B(i) for ctype(i) = -1
%  L(i,:)x  = B(i) for ctype(i) =  0
%  L(i,:)x >= B(i) for ctype(i) =  1
% 
% The function returns in res the optimal solution, and in how the 
% termination type ('ok', 'not solved', 'unbounded', 'infeasible'). 
% When the problem is infeasible or not solved, res is an empty 
% vector. When the problem is unbounded, res is a feasible solution.
%
% To find a feasible solution to a set of constraints, use f = [] or
% set to 0 all elements of f.
% 
% Default values: if intlist not given, all variables considered to
% be integers; if ub not given, all upper bounds are infinity; if 
% lb not given, all lower bounds are 0; if ctype not given, the
% constraints are Lx >= B.

% Another integer program solver is SOLVE_IP.

% This interface to the LP_SOLVE package has been 
% written by Marian V. Iordache, miordach@nd.edu


if nargin < 3, f = []; end

f = f(:); p = length(f); L0 = L; B0 = B;
[m, n] = size(L);
[m2, xx] = size(B);

if xx > 1 | m2 ~= m
   error('Invalid set of constraints: matrix dimensions do not agree.');
end

if p > 0 & p ~= n
   error('Invalid set of constraints and/or cost vector')
end

if sum(sum(~isfinite([L B]))) 
   error('The constraints must not contain Inf or NaN elements!')
end

if nargin < 4, intlist = []; end
if nargin < 5, ub = []; end
if nargin < 6, lb = []; end
if nargin < 7, ctype = []; end

intlist = intlist(:); ub = ub(:); lb = lb(:); ctype = ctype(:);

if isempty(f), f = zeros(n,1); end
if isempty(intlist), intlist = ones(n,1); end
if isempty(ub), ub = inf*ones(n,1); end
if isempty(lb), lb = zeros(n,1); end
if isempty(ctype), ctype = ones(m,1); end

if length(intlist) == 1, intlist = intlist(1)*ones(n,1); end
if length(ub) == 1, ub = ub(1)*ones(n,1); end
if length(lb) == 1, lb = lb(1)*ones(n,1); end
if length(ctype) == 1, ctype = ctype(1)*ones(m,1); end

if sum(sum(isnan([ub; lb]))) 
   error('The upper and lower bounds cannot contain NaN elements')
end
intlist = intlist ~= 0; % thus all elements are either 0 or 1
ctype = (ctype > 0) - (ctype < 0); % thus all elements are -1, 0, or 1.

res = zeros(n,0); ctype0 = ctype;

if sum(ub < lb)
   mhow = 'infeasible';
   return
end

% Build ival, which is a feasible solution to vlb <= x <= vub.

uz = ub >= 0;   un = ~uz;
lz = lb >= 0;   ln = ~lz;

ii = 1 + (uz&lz) - (un&ln);
iiv  = [ub; zeros(n,1); lb];

ival = iiv((1:n) + n*ii');
if sum(isinf(ival))
   error('IP_SOLVE does not deal with the case when an upper and a lower bound are both equal to Inf or -Inf');
end

% Remove null rows

ind = find(sum(L~=0,2)); nind = ones(m,1); nind(ind) = 0; nind = find(nind);
for i = nind'
   if (ctype(i) & B(i)*ctype(i) > 0) | (~ctype(i) & B(i))
      mhow = 'infeasible';
      return
   end
end
L = L(ind,:); B = B(ind); m = length(ind); ctype = ctype(ind);

% Remove null columns

ind = find(sum(L~=0,1)); nind = ones(n,1); nind(ind) = 0; nind = find(nind);
for i = nind'
   if f(i) > 0, ival(i) = lb(i); end
   if f(i) < 0, ival(i) = ub(i); end
end % the case when ival(i) is infinite is treated at the end of the program
L = L(:,ind); lb = lb(ind); ub = ub(ind); n = length(ind);
if ~m | ~n
   res = ival; kind = 0;
else
   vlb = lb;
   vub = ub;
   zind = zeros(n,1);
   xind = find(lb < 0 & ub > 0);
   yind = find(lb < 0 & ub <= 0);
   for i = yind'
      L(:,i) = -L(:,i); % substitute x(i) with -x(i) to have x(i) >= 0
      f(i) = -f(i);
      zz = vlb(i); vlb(i) = -vub(i); vub(i) = -zz;
      zind(i) = -1;
   end
   nx = n+1; 
   for i = xind'
      L = [L -L(:,i)]; % substitute x(i) with x(i)-x(nx), where x(i),x(nx)>=0
      f = [f; -f(i)];
      vlb = [vlb; 0];
      vub = [vub; -vlb(i)];
      vlb(i) = 0;
      intlist = [intlist; intlist(i)];
      zind(i) = nx;
      nx = nx+1;
   end
   n = nx;
   iind = find(isinf(vub));   vub(iind) = -1; % -1 means Inf in ipslv

   [r, kind] = ipslv(f, L, B, intlist, vub, vlb, ctype); % the mex code

   if kind == 3 % find a feasible solution if the problem is unbounded
      r = ipslv(zeros(n,1), L, B, intlist, vub, vlb, ctype);
   end
   
   if kind == 0 | kind == 3
      n = length(zind);
      for i = 1:n
         if zind(i) < 0, r(i) = -r(i);
         elseif zind(i) > 0, r(i) = r(i) - r(zind(i)); end
      end
      res = ival;
      res(ind) = r(1:n);
   end
end

if kind == 0, mhow = 'ok';
elseif kind == 2, mhow = 'infeasible';
elseif kind == 3, mhow = 'unbounded';
else mhow = 'not solved'; end

if sum(isinf(res)) & ~kind, mhow = 'unbounded'; end
if kind & kind ~= 3, return; end

% CHECK ------

er = L0*res - B0; m = length(er); ctype = ctype0;
if kind == 0 | kind == 3
   me = 1e-10;
   for i = 1:m
      if (er(i) + me < 0 & ctype(i) > 0) | (er(i) - me > 0 & ctype(i) < 0) | (abs(er(i)) > me & ctype(i) == 0)
         warning('IP_SOLVE: INTERNAL ERROR!')
      end
   end
end
