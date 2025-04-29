function [DF, DFM, DFP, MF, L0F, LF, iplf] = msplit(DM, DP, mask, M, L0, L, ipl, dpl)

% MSPLIT - split transitions to make a Petri net PT-ordinary.
%
% [DF, DFM, DFP] = msplit(DM, DP)
%
% [DF, DFM, DFP] = msplit(DM, DP, mask)
%
% [DF, DFM, DFP, MF, L0F, LF, iplf] = msplit(DM, DP, mask, M, L0, L, ipl, dpl)
%
% * DM, DP are the input and output incidence matrices (D- and D+). 
%
% * mask: mask(i) ~= 0 only if transition i is desired to be split.
%
% * Returns the updated incidence matrices.
%
% * The last four parameters are optional. See SDP code for meaning. 
%   Their updated values are given as output.
%
% As for DF = DFP - DFM, transitions in the replacement sequence of 
% split transitions are in the last columns. The original columns
% are not reordered. If the incidence matrices are m by n, the 
% first m rows and n columns of DF, DFM and DFN correspond to the
% places and transitions of the net (DM, DP). The remaining rows
% and columns correspond to the places and transitions resulted
% through transition split.
%
% Used in DP.

% Written by Marian V. Iordache, miordach@nd.edu

[m0,n0] = size(DM);

if nargin < 3, mask = []; end
if isempty(mask), mask = sum(DM>1, 1); end

chk_data(DM, DP, mask);

if nargin < 4
    M = [];
    dpl = [];
    ipl = 1:m0;
    L0 = [];
    L = [];
end

if isempty(L0)   L0 = zeros(0,length(ipl)); end
if isempty(L)    L  = zeros(0,length(ipl)); end
if isempty(M)    M  = zeros(0,length(ipl)); end

Dm = DM; Dp = DP;
mi0 = length(ipl);

ind = find(mask);  % the set of transitions that will be split
for i = ind
    l = max(DM(:,i)) - 1;
    [m, n] = size(Dm);
    [p, f] = size(M);
    [q, r] = size(L0);
    ipl = [ipl, m+1:m+l];
    Dm = [[Dm; zeros(l, n)], zeros(m+l,l)]; 
    Dp = [[Dp; zeros(l, n)], zeros(m+l,l)];
    M  = [M,  zeros(p, l)];
    L0 = [L0, zeros(q, l)];
    Om = Dm;
    for j = 1:l            % connections to the extra places
        Dp(m+j,n+j) = 1;     % arc from t_{j,i} to p_{j,i}
        if j == 1
            Dm(:,i) = Om(:,i) > 0; % set to 1 old input arcs with weight > 1
            Dm(m+1,i) = 1;
        else
            Dm(m+j,n+j-1) = 1;   % arc from extra place p_{j,i} to t_{j-1,i}
        end
        Dm(:,n+j) = Om(:,i) > j;
        
        M(:,f+j) = M*((Om(ipl,i) > j).*(Om(ipl,i) - j)) - (Om(dpl,i) > j).*(Om(dpl,i) - j);
        L0(:,r+j) = L0*((Om(ipl,i) > j).*(Om(ipl,i) - j));
        %Z = ((Om(ipl,i) > j).*(Om(ipl,i) - j))
        %L0(:,r+j) = L0*Z
    end
end
 
DFM = Dm;
DFP = Dp;
DF = DFP-DFM;
L0F = L0;
[u, v] = size(L);
LF = [L, zeros(u,length(ipl)-mi0)];
iplf = ipl;
MF = M;
