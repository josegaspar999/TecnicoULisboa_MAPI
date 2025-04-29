function [res] = grp(a,b)

% [res] = grp(string, pattern)
%
% 'string' and 'pattern' are character strings; 
% res is 1 if 'string' contains an instance of 'pattern'.

% Written by Marian V. Iordache, miordach@nd.edu

res = 0;

m = length(a);
k = length(b);

if m < k
    return;
end

for i = 1:m-k+1
    if sum(a(i:i+k-1) ~= b) == 0
        res = 1;
        return
    end
end
