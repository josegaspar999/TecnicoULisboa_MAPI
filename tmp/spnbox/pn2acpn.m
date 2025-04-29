function [Df, Dmf, Dpf, MXF, L0F, LF, iplf] = pn2acpn(Dm, Dp, M, MX, L0, L, ipl, dpl)

% PN2ACPN - Transforms a Petri net to an asymmetric choice Petri net
%
% [Df, Dmf, Dpf] = pn2acpn(D)
%
% [Df, Dmf, Dpf] = pn2acpn(Dm, Dp)
%
% [Df, Dmf, Dpf] = pn2acpn(Dm, Dp, mask)
%
% [Df, Dmf, Dpf, MF, L0F, LF, iplf] = pn2acpn(Dm, Dp, mask, M, L0, L, ipl, dpl)
%
% mask is an optional argument: mask(i) = 1 if the place i is 
% in the set M of the technical report. (M in the tech. report has 
% a different meaning than M in the TLE program.)
% 
% The last four parameters are optional. See TLE code for meaning. 
% Their updated values are given as output.
%
% If called before the first iteration, take LF = MF, as the computation 
% of LF does not consider this case!
%
% See MSPLIT.


% Written by Marian V. Iordache, miordach@nd.edu

% M. Iordache -- Sep. 4, 2000

% revised on Oct. 24, 2001

[m, n] = size(Dm); m0 = m; n0 = n;

if nargin < 4
    MX = [];
    dpl = [];
    ipl = 1:m0;
    L0 = [];
    L = [];
end

if nargin == 1
   [Dm, Dp] = d2dd(Dm);
end

if nargin < 3
   M = ones(1,m);
elseif isempty(M)
   M = ones(1,m);
end

if isempty(L0)    L0 = zeros(0,length(ipl)); end
if isempty(L)     L  = zeros(0,length(ipl)); end
if isempty(MX)    MX  = zeros(0,length(ipl)); end

Dmf = Dm; Dpf = Dp; 
[mL0, x] = size(L0); [mL, x] = size(L);

cardbt = sum(Dm ~= 0); 
cardbtx = cardbt; % this is the x vector of the algorithm
indf = find(cardbt > 1); 

while ~isempty(indf)
   i = indf(1);        % the transition t
   cardbtx(i) = 0;
   z = cardbt(i);      % |\bullet t|
   xx = find(Dmf(:,i)); %  \bullet t
   U = zeros(2,0);
   for j = 1:z-1
      pj = xx(j);
      prj = Dmf(pj,:) ~= 0; % p_j\bullet 
      for k = j+1:z
         pk =  xx(k); 
         prk = Dmf(pk,:) ~= 0; % p_k\bullet 
         ts = sum((~prj) & (prj | prk)) & sum((~prk) & (prj | prk));
         if ts
            U = [U, [pj; pk]];
         end
      end
   end
   [u, v] = size(U);
   Q = zeros(1,m);
   for j = 1:v
      pu = [];
      if M(U(1,j))
         pu = U(1,j);
      end
      if M(U(2,j))
         pu = [pu, U(2,j)];
      end
      if ~isempty(pu)
         if length(pu) == 2
            if ~(Q(pu(1)) | Q(pu(2)))
               if j < v
                  pv = pu;
                  if U(1,j+1) == U(1,j)
                     pv = U(1,j);
                  elseif find([U(1,j+1:v), U(2,j+1:v)] == U(2,j))
                     pv = U(2,j);
                  end
                  pu = pv;
               end
               if length(pu) == 2
                  z1 = length(find(Dmf(pu(1), :)));
                  z2 = length(find(Dmf(pu(2), :)));
                  if z1 >= z2
                     pu = pu(1);
                  else
                     pu = pu(2);
                  end
               end
               Q(pu) = 1; 
               cardbtx = cardbtx | (cardbt & Dm(pu,1:n0));
            end
        else % that is if length(pu) == 1
            Q(pu) = 1;
            cardbtx = cardbtx | (cardbt & Dm(pu,1:n0));
        end
      end
   end
   for j = find(Q)
      Dmf(j,i) = 0;
      [u, v] = size(Dmf);
      Dmf = [Dmf, zeros(u,1); zeros(1, v+1)];
      Dpf = [Dpf, zeros(u,1); zeros(1, v+1)];
      
      % The new place and transition is added
      
      Dmf(j,v+1) = 1;
      Dpf(u+1,v+1) = 1;
      Dmf(u+1, i) = Dm(j,i);
      p = find(ipl == j);
      if p
         MX = [MX, MX(:, p)];
         L0 = [L0, L0(:, p)];
      else % the case j in dpl
         MX = [MX, -(dpl == j)']; 
         L0 = [L0, zeros(mL0,1)]; % no op. necessary for L0 in this case: 
         % if before first iteration, no effect on L0, as only ipl appear in L0
         % if during the iterations, no effect on L0, as ineq. of L0 remain enforced.
      end
   end
   cardbtx(i) = 0;
   indf = find(cardbtx);
end

Df = Dpf - Dmf;
[m, n] = size(Df);
iplf = [ipl, m0+1:m];
LF = [L, zeros(mL, m-m0)];
MXF = MX; L0F = L0;
