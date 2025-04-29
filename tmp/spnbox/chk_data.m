function res = chk_data(DM, DP, mask, B, L0, B0)

% CHK_DATA - Checks if data is valid.
%
% res = chk_data(D^-, D^+, mask)
%
% res = 0 when DM, DP are empty
%
% Another form is 
%
% res = chk_data(D^-, D^+, L, B, L0, B0)

% Written by Marian V. Iordache, miordach@nd.edu

if nargin == 0
    return;
elseif nargin == 1
    Z = DM;
elseif nargin >= 1
    z = sum(size(DP) ~= size(DM));
    if z >0
        error('The input/output incidence matrices do not have equal size!');
    end
    Z = [DM, DP];
end

x = sum(sum(Z - floor(Z)));
y = sum(sum(Z < 0));
[m, nc] = size(DP);

if (x > 0) | (y > 0)
    error('The input/output incidence matrices should be nonnegative integer matrices!');
end

res = ~isempty(DM);

if nargin == 3
    [i, j] = size(mask);
    k = min(i,j);
    l = max(i,j);
    if k > 1 | l ~= nc
        error('size of mask does not agree with number of transitions');
    end
    return
elseif nargin <= 3
    return
elseif nargin == 4 
    L = mask;
    L0 = zeros(0, nc);
    B0 = zeros(0,0);
elseif nargin == 6
    L = mask;
end

if isempty(L)
    L = zeros(0, m);
end
if isempty(B)
    B = zeros(0, 1);
end
if isempty(L0)
    L0 = zeros(0, m);
end
if isempty(B0)
    B0 = zeros(0, 1);
end

[ml, nl] = size(L);
[mb, nb] = size(B);
[ml0, nl0] = size(L0);
[mb0, nb0] = size(B0);

str = 'The number of rows of the incidence matrices and the number of columns ';
st2 = 'of L ';
st3 = 'of L0 ';
st4 = 'should be the same';

if nb ~= 1 
    error('The given matrix b is invalid');
elseif nb0 ~= 1
    error('The given matrix b0 is invalid');
elseif mb ~= ml
    error('L and b should have the same number of rows');
elseif mb0 ~= ml0
    error('L0 and b0 should have the same number of rows');
elseif nl ~= m
    error([str, st2, st4]);
elseif nl0 ~= m
    error([str, st3, st4]);
end
