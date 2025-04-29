function [La, ba, R1, R2, how, dhow] = mro_adm(L, b, D, Tuc, Tuo, m0, vrb)

% MRO_ADM - transformation to admissible constraints based on matrix row
%           operations
%
% [La, ba, R1, R2, how, dhow] = mro_adm(L, b, D, Tuc, Tuo, m0, vrb)
%
% The function transforms a marking constraint L*m <= b to an admissible 
% marking constraint (R1 + R2*L)*m <= R2*(b+1). If the transformation is
% possible for the given initial marking, 'ok' is returned in a variable
% how; else 'impossible' is returned; similarly, dhow{i} is 'ok' if the
% transformation of the constraint i of Lm <= b was possible.
%
% D   - the incidence matrix
% Tuc - the uncontrollable transitions (e.g. for Tuc = [2, 5], the second and 
%       the fifth columns of D correspond to uncontrollable transitions
% Tuo - the unobservable transitions
% m0  - the initial marking
% vrb - use vrb = 0 to suppress messages. Default is vrb = 1.
% 
% Use m0 = [] or only the first five arguments if the initial marking is
% not of interest.

% Written by Marian V. Iordache, miordach@nd.edu

how = 'ok'; dhow = {}; flg = 0;
if nargin < 7, vrb = 1; end
if nargin < 6, m0 = []; end
if nargin < 5, Tuo = []; end
if vrb, fprintf('\n'); end
flg = isempty(m0); 

Duc = D(:,Tuc); Duo = D(:,Tuo);
[m, n] = size(D); [p, f] = size(L); if isempty(b) & ~p, b = zeros(0,1); end

R1 = zeros(p,m); R2 = eye(p);
for i = 1:p, dhow{i} = 'ok'; end
if ~p, dspy('Empty set of constraints!','','',p,p,vrb); end
if ~f, dspy('Empty set of places!','','',1,1,vrb); La = L; ba = b; return; end

ind = [];
for i = 1:p
   l = L(i,:); 
   nflg = flg;
   if ~flg
      if (l*m0 <= b(i)), nflg = 1; end
   end

   aa = 0; bb = 0;
   if isempty(Duc), aa = 1;
   elseif (l*Duc <= 0), aa = 1; end

   if isempty(Duo), bb = 1;
   elseif (l*Duo == 0), bb = 1; end
   
   if ~nflg & ~flg
      dhow{i} = 'infeasible';
      dspy('The transformation is infeasible due to the initial marking', '', '.', i, p, vrb);
   elseif aa & bb
      dhow{i} = 'ok';
      dspy('No transformation is necessary', '', '.', i, p, vrb);
   else
      ind = [ind, i];
   end
end

nc = length(ind); nuc = length(Tuc); nuo = length(Tuo); vhow = {};
if nc

   % MAIN ALGORITHM

   Lz = L(ind,:); 
   if isempty(m0), mm = [zeros(m,1); -ones(nc,1);];
   else mm = [m0; Lz*m0-b(ind)-ones(nc,1)];  end
   M = [[Duc, Duo; Lz*Duc, Lz*Duo] mm eye(m+nc)];
   [M, dfail] = educ(M, m, nc, nuc, nuo);
   if ~dfail  % Do not continue the computations in case of failure
      [M, dfail] = zduo(M, m, nc, nuc, nuo, nuc+1);
   end
   vhow = sub_testM(M, m, nc, nuc, nuo); 
   for i = 1:nc
      d = abs(gcdv(M(m+i, nuc+nuo+2:nuc+nuo+m+nc+1)));
      if ~d, warning('INTERNAL ERROR!'); break; end
      M(m+i, :) = M(m+i, :)/d;
   end
   r1 = M(m+1:m+nc, nuc+nuo+2:nuc+nuo+m+1);
   r2 = M(m+1:m+nc, nuc+nuo+m+2:nuc+nuo+m+nc+1);

end 

dhow(ind) = vhow;
for i = 1:nc
   R1(ind(i),:) = r1(i,:);
   R2(ind(i),ind(i)) = r2(i,i);
end

xx = 0; yy = 0;
for i = 1:p
   if strcmp(dhow{i},'not solved'), yy = 1; end
   if strcmp(dhow{i},'infeasible'), xx = 1; end
end

if yy, how = 'not solved'; end
if xx, how = 'impossible'; end

La = R1 + R2*L; ba = b;
if ~isempty(b), ba = R2*(b+ones(p,1)) -ones(p,1); end
if vrb, fprintf('\n'); end


% =======================================================================

% ELIMINATION OF POSITIVE ELEMENTS FROM Duc

function [N, dfail] = educ(M, n, nc, nuc, nuo)

dfail = 0;
for i = 1:min(nuc, n)
   ind = find(M(i:n, i) < 0);
   if ~isempty(ind)
      j = ind(1);
      v = M(i,:); M(i,:) = M(j,:); M(j,:) = v;
      M = czero(M, i, i, n, nc);
   elseif ~isempty(find(M(n+1:n+nc,i)>0)) |~isempty(find(M(n+1:n+nc,nuc+nuo+1)>=0))

      dfail = 1; break
   end
end
if ~dfail % takes care of the case n < nuc
   dfail = ~isempty(find(M(n+1:n+nc,1:nuc)>0));
end
N = M;


% =======================================================================

% ZEROING OF ALL ELEMENTS IN DUO

function [N, dfail] = zduo(M, n, nc, nuc, nuo, ii)

dfail = 0;
for i = ii:min(nuc+nuo,n)
   ind = find(M(i:n,i) < 0);
   k = ~isempty(ind);
   if k
      j = ind(1);
      v = M(i,:); M(i,:) = M(j,:); M(j,:) = v;
   end
   ind = find(M(i:n,i) > 0);
   if ~isempty(ind)
      j = ind(1);
      v = M(i+k,:); M(i+k,:) = M(j,:); M(j,:) = v;
      M = czero(M, i+k, i, n, nc);
   end
   if k
      M = czero(M, i, i, n, nc);
   end
   if ~isempty(find(M(n+1:n+nc,i))) | ~isempty(find(M(n+1:n+nc,nuc+nuo+1)>= 0))
      dfail = 1; break
   end
end
if ~dfail % takes care of the case n < nuc+nuo
   dfail = ~isempty(find(M(n+1:n+nc,nuc+1:nuc+nuo)));
end
N = M;


% =======================================================================

% COLUMN ZEROING

function [N] = czero(M, p, j, n, nc)

for i = n+1:n+nc
   if sign(M(i,j))*sign(M(p,j)) < 0
      d = gcd(abs(M(i,j)), abs(M(p,j)));
      M(i,:) = M(i,:)*abs(M(p,j))/d + M(p,:)*abs(M(i,j))/d;
   end
end

for i = (p+1):n
   if sign(M(i,j))*sign(M(p,j)) < 0
      while M(i,j) 
         if abs(M(p,j)) > abs(M(i,j))
            d = floor(-M(p,j)/M(i,j)) - ~rem(M(p,j), M(i,j));
            M(p,:) = M(p,:) + d*M(i,:);
         else
            M(i,:) = M(i,:) + floor(-M(i,j)/M(p,j))*M(p,:);
         end
      end
   end
end
N = M;


% =======================================================================

function dspy(bg, prm, ed, i, p, vrb)

if vrb
   if p <= 1
      fprintf('ILP_ADM: %s%s%s\n', bg, prm, ed);
   else
      fprintf('ILP_ADM, constraint %d: %s%s%s\n', i, bg, prm, ed);
   end
end


% =======================================================================

function [dhow] = sub_testM(M, n, nc, nuc, nuo)

for i = 1:nc
   aa = ~isempty(find(M(n+i,1:nuc) > 0)); % tests La*Duc
   bb = ~isempty(find(M(n+i,nuc+1:nuc+nuo))); % tests La*Duo
   cc = M(n+i,nuc+nuo+1) >= 0; % tests the marking
   if aa | bb | cc, dhow{i} = 'not solved';
   else dhow{i} = 'ok';  end
end

