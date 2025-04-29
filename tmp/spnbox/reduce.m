function [Lf, Bf, indf, how] = reduce(L,B,vrb)

% [Lf, Bf, ind, how] = reduce(L,B)
%
% This function removes redundant constraints of Lx>=B, where x 
% is a nonnegative integer vector. 'ind' stores the indices of 
% the rows that were kept. The variable how is set to 1 if 
% redundant constraints have been found.
%
% See also CHK_CONS, IP_SOLVE.

% Written by Marian V. Iordache, miordach@nd.edu

[m,f] = size(L); 

B = B(:);

if nargin < 3
    vrb = 0;
end

if length(B) ~= m
    error('L and B must have the same number of rows');
end

k = 0;   
n = m; 
how = 0;
ind = [];
for j = 1:n 
    if vrb, fprintf('\b\b\b%3d',j); end
    i = j-k; 
    m = n-k; 
    l = L(i,:); 
    b = B(i); 
    Lt = L; Bt = B; 
    L = [L(1:i-1,:); L(i+1:m,:)]; 
    B = [B(1:i-1); B(i+1:m)]; 
    %res = chk_con2(L,B,l,b);      
    res = chk_cons(L,B,l,b,'');      
      
    if isempty(res) == 0    
        L = Lt; B = Bt;
        ind = [ind; j];
    else   
        k = k+1; 
        how = 1;
    end   
end
 
Lf = L; Bf = B; indf = ind;
