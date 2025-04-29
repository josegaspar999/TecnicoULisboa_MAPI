function [res] = chk_con2(L,B,l,b)

% res = chk_con2(L,B,l,b)
%
% Checks consistency of the set of constraints Lx >= B and lx< b, 
% where x should be a nonnegative integer vector. 
% 'l' is expected to be a 1-D vector.
%
% If the system is consistent, the function returns a feasible 
% solution. So 'res' is a nonnegative integer vector x such
% that Lx >= B and lx < b. If res is empty, then the constraint 
% lx >= b is redundant for Lx >= B.
%
% CHK_CON2 is the old version of CHK_CONS. It is expected to be
% slower than CHK_CONS. However, CHK_CON2 is simpler, and so it
% may be more reliable. 

% Written by Marian V. Iordache, miordach@nd.edu

[m,n] = size(L);
n2 = length(l);

if isempty(l) & isempty(b) == 0
    error('Bad (l,b) constraint: l empty, b nonempty');
elseif m ~= length(B)
    error('Dimensions of L and B do not agree');
elseif isempty(l)
    l = [];
    n2 = n;
else
    l = reshape(l, 1, n2);
end

if isempty(L) & isempty(B) == 0 
    error('Bad (L,B) constraint: L empty, B nonempty'); 
elseif 1 ~= length(b) & isempty(l) == 0
    error('Dimensions of l and b do not agree or l is not a vector');
elseif isempty(L) 
    n = n2; 
    if isempty(l) & n ~= 0
       res = zeros(n,1);
       return;
    else
       res = 0;
       return;
    end
end 
 
if n2 ~= n
    error('L and l do not have the same number of columns');
end

ind = find(sum([L;l]~=0,1));   
if length(ind) ~= n
    L = L(:,ind); 
    if isempty(L), res = zeros(n,1); return; end
    if isempty(l) 
        l = [];
    else
        l = l(ind); 
    end
    z = chk_con2(L,B,l,b);
    if isempty(z)
        res = zeros(n,0);
        return
    end
    res = zeros(n,1);
    res(ind) = z;
    return
end

% Choosing swpol, with regard to branch policy is solve_ip.

ln = l;   
ln(find(~l)) = realmin;
[mn, ind] = sort(abs(b./ln));

fprintf('.');
swpol = ind;
%swpol = [ind, find(~l)]
idx = 1;


if isempty(L)
    Lx = -l;
    Bx = -b+1;
elseif isempty(l)
    Lx = L;
    Bx = B;
else
    Lx = [L; -l];
    Bx = [B; -b+1];
end
res = ip_solve(Lx, Bx, [], [], [], 0);
%if isempty(l) == 0
   %res = solve_ip([],Lx, Bx, swpol, idx,0,1/eps); 
%else
   %res = solve_ip([],Lx, Bx,[],[],0,1/eps);
%end

