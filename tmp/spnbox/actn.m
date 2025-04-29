function [Dma, Dpa, Dmra, Dpra, TA, unique] = actn(Dm, Dp, X, Dcm, Dcp, upd)

% ACTN - The active subnet of a Petri net
%
% [Dma, Dpa, Dmra, Dpra] = actn(Dm, Dp)
%
% [Dma, Dpa, Dmra, Dpra] = actn(Dm, Dp, X)
%
% This function computes the maximal subnet of the Petri net 
% structure which can be made live and does not contain  
% transitions in X. In contrast, the function PART only removes  
% source places and the transitions thus detected as impossible
% to be made live. This is the difference between the active 
% subnet produced by ACTN and that of PART. 
%
% For convenience, the outcome is produced as matrices of the 
% same size as (Dm, Dp): (Dma, Dpa) and also at reduced size: 
% (Dmra, Dpra), where 'm' stands for '-' and 'p' for '+'.
%
% [Dma, Dpa, Dmra, Dpra] = actn(Dm, Dp, X, Dma, Dpa, upd)
%
% In this format ACTN only makes an update, if upd is not zero.
% The update is done as follows: the transitions of the active
% subnet are found based on the current Dma and Dpa. Then the 
% places of the active subnet are found. 
%
% See also NLTRAN. 

% Written by Marian V. Iordache, miordach@nd.edu

if nargin < 6, upd = 0; end
if nargin < 3, X = []; end

[m, n] = size(Dm);

if upd == 0
   nlt = nltrans(Dm, Dp, X);
else
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
   nlt = ~tl0;
end

ltn = find(~nlt);
lpn = find(sum(Dp(:,ltn),2));

Dma = zeros(m,n); Dpa = Dma;
Dmra = Dm(lpn, ltn);
Dpra = Dp(lpn, ltn);
Dma(lpn, ltn) = Dmra;
Dpa(lpn, ltn) = Dpra;
TA = ltn;

if nargout > 5 % set unique to zero if active subnets with smaller support exist
    unique = isunique(Dp-Dm, nlt, X); 
end


% =========================================================

function unique = isunique(D, nlt, X)

[m, n] = size(D);
z = ones(1,n); 
if ~isempty(X), z(X) = 0; end
unique = 1; 
vlb = zeros(n,1);
vub = Inf*ones(n,1);
opt = optimset('Display','off','LargeScale','off');      
% opt = optimset('Display','off');% to be used for the future version of linprog
for i = find(~nlt(:)')
    z1 = z;
    z1(i) = 0;
    ind = find(z1);
    Dx = [D(:,ind); ones(1,length(ind))]; B = [zeros(m, 1); 1]; 
    f = ones(1,length(ind));% we solve a feasibility problem, so the value of f is not important
    [x1, f, flag] = linprog(f, -Dx, -B, [], [], vlb(ind), vub(ind), [], opt);
    if flag >= 0 % flag > 0 if feasible
        if ~flag
            warning('LINPROG failure ...');
        end
        unique = 0;
        break;
    end
end

