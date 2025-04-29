function [ar] = pn2ar(Dm,Dp,ap,at,verb)

% PN2AR - Incidence matrix Petri net description to cell array
%
% The function does the reverse operation of AR2PN
%
% [ar] = pn2ar(D)
%
% [ar] = pn2ar(Dm,Dp)
%
% [ar] = pn2ar(Dm,Dp,ap,at)
%
% [ar] = pn2ar(Dm,Dp,ap,at,verb)
%
% [ar] = pn2ar(Dm,Dp,ap,at,fid)
%
% ap{j} is the name of the place of the row j of D; default is `pj'
% at{i} is the name of the transition of the column i of D; default is `ti'
% verb: if -1, the array is not displayed on the screen. Default is 1.
% fid: file id for where to write the output. Default is 1 (stdout). 
%
% If ap and/or at are unavailable, use {} for ap and/or at

% Written by Marian V. Iordache, miordach@nd.edu

if nargin < 2
   Dp = Dm.*(Dm > 0);
   Dm = -Dm.*(Dm < 0);
end

if nargin < 3
   ap = [];
end

if nargin < 4
   at = [];
end

if nargin < 5
   verb = 1;
end
fid = verb;

[m, n] = size(Dm);

if isempty(ap)
   for i = 1:m
      ap{i} = sprintf('p%d',i);
   end
end

if isempty(at)
   for j = 1:n
      at{j} = sprintf('%d',j);
      atn{j} = sprintf('t%d',j);
   end
else
   atn = at;
end

for i = 1:m
   ti = find(Dp(i,:));
   to = find(Dm(i,:));
   if verb
      str = '{';
   end
   
   p = length(ti);
   ari = {}; aro = {};
   for j = 1:p
      w = Dp(i,ti(j));
      if w > 1
         ari{j} = {at{ti(j)}, w};
         str = [str, sprintf('%s(%d) ', atn{ti(j)}, w)];
      else
         ari{j} = at{ti(j)};
         str = [str, sprintf('%s ', atn{ti(j)})];
      end
   end
   str = [str, sprintf('} --> %s --> {',ap{i})];
   p = length(to);
   for j = 1:p
      w = Dm(i,to(j));
      if w > 1
         ari{j} = {at{to(j)}, w};
         str = [str, sprintf('%s(%d) ', atn{to(j)}, w)];
      else
         str = [str, sprintf('%s ', atn{to(j)})];
         ari{j} = at{to(j)};
      end
   end
   
   str = [str, sprintf('}\n')];
   if verb > 0
      fprintf(fid,'\n%s',str);
   end
   
   ar{i,1} = ari;
   ar{i,2} = ap{i};
   ar{i,3} = aro;
end
