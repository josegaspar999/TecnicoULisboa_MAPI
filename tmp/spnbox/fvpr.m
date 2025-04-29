function [str] = fvpr(x, sw)

% FVPR - Transforms a vector in a string
%
% [str] = fvpr(x)
%
% Use the format below to print finite sets
%
% [str] = fvpr(x,2)

% Written by Marian V. Iordache, miordach@nd.edu


if nargin == 1
    sw = 1;
end

[m,p] = size(x);
n = length(x);

if     sw == 1, op = '['; cl = ']'; 
elseif sw == 2, op = '{'; cl = '}'; end

if n > 1 | sw == 2
    u = [op];
else 
    u = [];
end

for i = 1:n
    z = sprintf('%g', x(i));
    u = [u, z];
    if i < n
        u = [u, ', '];
    end
end

if n > 1 | sw == 2
    u = [u, cl];
end

if m > 1
    str = [u, ''''];
else
    str = u;
end
