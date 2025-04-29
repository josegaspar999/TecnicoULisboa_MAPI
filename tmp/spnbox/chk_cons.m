function [res] = chk_cons(L,B,l,b,vrb)

% CHK_CONS - Checks constraint consistency
%
% res = chk_cons(L,B)
%
% res = chk_cons(L,B,l,b)
%
% Checks consistency of the set of constraints Lx >= B and lx< b, 
% where x should be a nonnegative integer vector. 
% 'l' is expected to be a 1-D vector.
%
% If the system is consistent, the function returns a feasible 
% solution. So 'res' is a nonnegative integer vector x such
% that Lx >= B and lx < b. If res is empty, then the constraint 
% lx >= b is redundant for Lx >= B. When L, l equal []: res = 0.

% Written by Marian V. Iordache, miordach@nd.edu

LR = L; BR = B; lR = l; bR = b;

if nargin < 4, l = []; b = []; end
if nargin < 5, vrb = '.'; end

[m,n] = size(L);
n2 = length(l);

if isempty(l) & isempty(b) == 0
    error('Bad (l,b) constraint: l empty, b nonempty');
elseif m ~= length(B)
    error('Dimensions of L and B do not agree');
elseif isempty(l)
    l = zeros(0,n);
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

L = [L; -l]; B = [B; -b+1]; L0 = L; B0 = B;
[m, n] = size(L); 
ind = 1:n;% the position in the original L of the current variables
tl = [];
vlb = zeros(1, n); vub = 1/eps*ones(1,n); vubmax = vub;
while 1
    [mc, nc] = size(L);

    % find rows i such that L(i,:) <= 0

    v = sum(L> 0, 2);
    nind = find(~v);

    % the case in which such a row i has B(nind)>0 means no solution

    if sum(B(nind)>0)  
        res = [];
        return;
    end

    % remove variables j such that L(i,j) < 0 on the rows i satisfying in 
    % addition to L(i,:) <= 0 also B(i) = 0 (they must be zero).

    xind = find(~B(nind));
    nind = nind(xind);
    if ~isempty(nind)
        temp = sum(L(nind,:) < 0, 1);
        zind = find(temp);
        cind = find(~temp);
        vub(ind(zind)) = 0;
        ind = ind(cind);
        L = L(:, cind); 
        if isempty(L) & sum(B>0), res = []; return; end
        % here we detect the case when L gets 0 columns and B > 0: this is
        % infeasible since the eliminated variables (which correspond to
        % the columns) must be 0, hence Lp*x = 0 < B (Lp: L before removing
        % the columns above)
    end

    % Remove the null rows or the rows such that B(i) = 0 and L(i,:) >= 0

    if isempty(L), break; end     % disables this stage if isempty(L)
    v = sum(L~=0, 2); 
    nind = find(~v); 
    cind = find(v); 
    if sum(B(nind) > 0), res = []; return; end
    L = L(cind,:); B = B(cind);
    v = find(~B);
    cind = v(find(~sum(L(v,:) < 0, 2)));
    ui = ones(1,length(B)); ui(cind) = 0;
    cind = find(ui);
    L = L(cind,:); B = B(cind); 
    if isempty(L), break; end     % disables next stage if isempty(L)

    % Negative or zero column j: variable j will be taken vlb(j) (= 0).

    cind = find(sum(L > 0, 1)); % the columns j s.t. exists i: L(i,j) > 0
    zind = find(~sum(L > 0, 1)); 
    if ~isempty(zind), 
       B = B - L(:,zind)*vlb(ind(zind))'; % update B too, as vlb may be nonzero ...
    end
    L  = L(:,cind); % columns j s.t. forall i: L(i,j) <= 0 are removed
    ind = ind(cind);
    if isempty(L) & sum(B>0), res = []; return; end
    % here we detect the case when L gets 0 columns and B > 0: this is
    % infeasible since the eliminated variables (which correspond to
    % the columns) must be 0, hence Lp*x = 0 < B (Lp: L before removing
    % the columns above)
    if isempty(L), break; end     % disables next stage if isempty(L)

    % Nonnegative columns

    in2 = find(~sum(L < 0, 1)); % the columns j s.t. forall i: L(i,j) >= 0
    if ~isempty(in2)
        aa = vub(ind(in2)) < vubmax(ind(in2));
        zind = in2(find(aa)); % upper bounded variables
        xind = in2(find(~aa));% upper unbounded variables
        tl = [tl, ind(xind)]; 
        % tl is updated with the new removable unbounded variables
        % the variables in zind will be set to vub
        vlb(ind(zind)) = vub(ind(zind)); 
        for i = zind
            B = B - L(:,i)*vub(ind(i));
        end
        cind = find(sum(L < 0, 1));
        rw  = find(~sum(L(:,xind) > 0, 2));
        % remove the rows i s.t j is in xind and L(i,j)>0 
        % the reason is that the variable j can be chosen large enough to 
        % satisfy any lower bound constraint.
        ind = ind(cind);
        L  = L(rw,cind); B = B(rw); 
    end

    % Looking for inequalities of the form a*x >= b, with a, b, x scalars.
    
    if isempty(L) & sum(B>0), res = []; return; end
    % here we detect the case when L gets 0 columns and B > 0: this is
    % infeasible since the eliminated variables (which correspond to
    % the columns) must be 0, hence Lp*x = 0 < B (Lp: L before removing
    % the columns above)
    if isempty(L), break; end % disables next stage if isempty(L)
    
    [mi, ni] = size(L);
    ids = [];
    for i = 1:mi
        id = find(L(i,:));
        if length(id) == 1
            a = L(i, id);
            ix = ind(id);
            if a > 0, vlb(ix) = max(vlb(ix), B(i)/a);
            else, vub(ix) = min(vub(ix), B(i)/a); end
        else
            ids = [ids, i];
        end
    end
    L = L(ids, :); B = B(ids); 

    if sum(vlb > vub), res = []; return; end
    [m1, n1] = size(L);
    if (m1 == mc & n1 == nc) | isempty(L), break; end 
    % exit loop if the iteration made no improvement or if L is empty
end

z = [];
if ~isempty(L)
    z = sv_fs(L,B,vlb(ind),vub(ind),vrb); % the subroutine is defined below
end

[m1, n1] = size(L);
if n1 ~= n | m1 ~= m
    if isempty(z) & ~isempty(L) % the case when the remaining constraints
        res = [];               % are infeasible.
        return
    end
    res = vlb';
    if ~isempty(z), res(ind) = z; end
    nrw  = find(sum(L0(:,tl) > 0, 2));
    for i = tl(length(tl):-1:1) 
    % tl is taken in reverse order: if column L(:,i) became (in while loop) >= 0
    % after removing L(j,:), then the variable i must be considered before
    % the variable k which caused L(j,:) to be removed. Note that k appears
    % before of i in tl, so we need reverse order.  
        U = B0(nrw)- L0(nrw,:)*res; V = L0(nrw, i);
        idv = find(V); U = U(idv); V = V(idv);
        res(i) = max(res(i), vlb(i)+max(ceil(U./V)));% vlb always >= 0!
    end
else
    res = z;
    if isempty(res), return; end
end

if sum(L0*res < B0)
    warning('CHK_CONS: recovering from internal error');
    L = LR; B = BR; l = lR; b = bR;
    save chk_cbug L B l b vrb res
    res = chk_con2(L0, B0, [], []);
end



% =========================================================================

function [res] = sv_fs(L, B, vlb, vub, vrb)

[m, n] = size(L);

% Choosing swpol, with regard to branch policy in solve_ip.

l = L(m,:); b = B(m);
ln = l;  
ln(find(~l)) = realmin;
[mn, ind] = sort(abs(b./ln));

swpol = ind;
%swpol = [ind, find(~l)]
idx = 1;

fprintf(vrb);
vub = floor(vub); vlb = ceil(vlb);
%res = solve_ip([],L, B, swpol, idx,vlb,vub); 
res = ip_solve(L, B, [], [], vub, vlb);
