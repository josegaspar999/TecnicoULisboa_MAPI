function [Dfm, Dfp] = supervis(Dm, Dp, L)

% [Df^-, Df^+] = supervis(D^-, D^+, L)
%
% This function creates the structure that enforces L*M >= b, where M is 
% the marking. The constant b is not specified, since the same structure 
% may enforce any inequality  L*M >= b, for any b, given an L; b results
% from the initial marking: Mo for the original places, where L*Mo >= b,
% and L*Mo - b for the control places.
%
% The function returns the structure that corresponds to the supervised
% Petri net.
%
% This is the approach in the papers by Moody and Yamalidou.

% Written by Marian V. Iordache, miordach@nd.edu

chk_data(Dm,Dp);
[m,n] = size(Dm);
[k,m2] = size(L);

if m < m2
  error('Dimensions of incidence matrices and constraints do not agree')
elseif m > m2
  L = [L, zeros(k,m-m2)];
end

LD = L*[Dp-Dm];

LDp = max(0,  LD);
LDm = max(0, -LD);

Dfp = [Dp; LDp];
Dfm = [Dm; LDm];

