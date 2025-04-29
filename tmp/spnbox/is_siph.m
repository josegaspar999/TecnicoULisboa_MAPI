function [flag, flx] = is_siph(Dm, Dp, S)

% IS_SIPH - checks whether a set of places is a siphon
%
% [flag, flx] = is_siph(Dm, Dp, S)
%
% S - a set of places represented as a column of zeros and ones
%     S is allowed to be a matrix, in which case each of the columns
%     is verified
%
% Dm, Dp - the incidence matrices
%
% flag = (S == siphon)
% flx  = sum(flag == 0) (i.e. flx is nonzero if a column of S is not a siphon)

[m, n] = size(S);
flag = zeros(1,n);

for i = 1:n
   si = find(S(:,i));
   ins = sum(Dp(si,:),1);
   outs = sum(Dm(si,:),1);
   flag(i) = ~sum(ins&(~outs));
end

flx = sum(flag == 0);
