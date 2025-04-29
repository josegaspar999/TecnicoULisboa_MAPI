function [d] = gcdv(v)

% GCDV  greatest common divisor of a vector/matrix. Uses GCD.

% Written by Marian V. Iordache, miordach@nd.edu

if length(v) <= 1
    d = abs(v);
    if length(v) == 0
        warning(' ');
    end
else
    [a, b] = size(v);
    
    w = reshape(v, 1, a*b);
    z = w(1);

    for i = 2:length(w)
        if z == 1
            break;
        end
        z = gcd(z,w(i));
    end 

    d = z;
end
