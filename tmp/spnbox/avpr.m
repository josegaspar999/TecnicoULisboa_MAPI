function [str] = avpr(x, chr,opt)

% AVPR - Transforms a vector in a string to be used for displaying
% equations/inequalities.
%
% [str] = avpr(x)
%
% Use the format below to specify the variable name in var (default name 
% is 'm'). 
%
% [str] = avpr(x,var)
%
% Use the format below to generate a tex description with indices
%
% [str] = avpr(x,var,1)

% Written by Marian V. Iordache, miordach@nd.edu

if nargin < 2, chr = 'm'; end
 
if nargin < 3, opt = 0; end

b1 = ''; e1 = '';
if opt
   b1 = '_{'; e1 = '}';
end

ind = find(x);
n = length(ind);
if n < 1
    str = '';
    return
elseif n == 1
    if x(ind) == 1
        str = sprintf('%s%s%d%s',chr,b1,ind,e1); 
    elseif x(ind) == -1
        str = sprintf('-%s%s%d%s',chr,b1,ind,e1); 
    else
        str = sprintf('%g%s%s%d%s',x(ind), chr,b1,ind,e1); 
    end
    return
end

if x(ind(1)) == 1 
    z = sprintf('%s%s%d%s', chr, b1, ind(1), e1);
elseif x(ind(1)) > 0
    z = sprintf('%g%s%s%d%s', x(ind(1)), chr, b1, ind(1), e1);
elseif x(ind(1)) == -1
    z = sprintf('-%s%s%d%s', chr, b1, ind(1), e1);
else
    z = sprintf('%g%s%s%d%s', x(ind(1)), chr, b1, ind(1), e1);
end
str = z;

for i = 2:n
    if x(ind(i)) == 1 
        z = sprintf('+%s%s%d%s', chr, b1, ind(i), e1);
    elseif x(ind(i)) > 0
        z = sprintf('+%g%s%s%d%s', x(ind(i)), chr, b1, ind(i), e1);
    elseif x(ind(i)) == -1
        z = sprintf('-%s%s%d%s', chr, b1, ind(i), e1);
    else
        z = sprintf('%g%s%s%d%s', x(ind(i)), chr, b1, ind(i), e1);
    end
    str = [str, z];
end

