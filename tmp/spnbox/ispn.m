function [v] = ispn(pnobj)

% ISPN - Checks whether an object is a PN object
%
% [v] = ispn(pnobj)
%
% returns 1 if the object is PN, else 0.
%
% See GETPN.

flag = 0;
if strcmp(class(pnobj),'struct')
    z = fieldnames(pnobj);
    y = fieldnames(getpn);
    if length(y) == length(z)
        x = 1;
        for i = 1:length(y)
            if ~strcmp(y{i},z{i}), x = 0; break; end
        end
        flag = x;
    end
end

if flag
   [m1, n1] = size(pnobj.Dm);
   [m2, n2] = size(pnobj.Dp);
   flag = (m1 == m2) & (n1 == n2) & (isempty(pnobj.m0) | (m1 == length(pnobj.m0)));
end

if flag, flag = strcmp(class(pnobj.Tuc), class(pnobj.Tuo)); end
   
if flag 
   if strcmp(class(pnobj.Tuc),'cell')
      flag = (length(pnobj.Tuc) == length(pnobj.Tuo));
   end
end

v = flag;


