function [Dm, Dp, ap, at] = ar2pn(ar)

% AR2PN - transform cell array to Petri net
%
% [Dm, Dp, ap, at] = ar2pn(ar)
%
% The format of ar should be: 
% * ar{i,1} is an array of transitions (e.g. {1, 't2', 'tc', 4})
% * ar{i,2} is the name of the place (e.g. 'pc')
% * ar{i,3} is an array of transitions (similar to ar{i,1})
% * for generalized Petri nets, write for instance {{1, 2}, 't2', {'tc', 3}, 4}
%   if transition 1 has the arc of weight 2 and tc of weight 3.
% ar{i,1} stands for the preset of ar{i,2} and ar{i,3} for its postset.
%
% ap and at are arrays: ap{i} is the name of the place corresponding
% to the row i of Dm and Dp. Similarly, at{j} is the name of the transi-
% tion of the column j.
%
% Example:
%
% AR = {{2,6}, 'p1', {1,5}; {1,4}, 'p2', {2,3,5}; {3,{7,4}}, 'p3', {4,5}; 
%       {5}, 'p4', {6,7}};
% [Dm, Dp, ap, at] = ar2pn(AR);

% Written by Marian V. Iordache, miordach@nd.edu

% M. Iordache, Sep 6, 2000.

[m, n] = size(ar);

ap = [];
at = [];
for i = 1:m
   [p, ap] =  mform(ar{i,2}, ap);
   cc = ar{i,1};
   u = length(cc);
   for j = 1:u
      if grp(class(cc), 'cell')
         if grp(class(cc{j}), 'cell')
            cx = cc{j}{1};
            w = cc{j}{2};
         else
            cx = cc{j};
            w = 1;
         end
      else
         cx = cc(j);
         w = 1;
      end
      [t, at] = mform(cx, at);
      if p & t
         Dp(p, t) = w;
      end
   end
   
   cc = ar{i,3};
   u = length(cc);
   for j = 1:u
      if grp(class(cc), 'cell')
         if grp(class(cc{j}), 'cell')
            cx = cc{j}{1};
            w = cc{j}{2};
         else
            cx = cc{j};
            w = 1;
         end
      else
         cx = cc(j);
         w = 1;
      end
      [t, at] = mform(cx, at);
      if p & t
         Dm(p, t) = w;
      end
   end
end

m = length(ap);
n = length(at);

[m1, n1] = size(Dp);
if m1 < m, Dp = [Dp; zeros(m-m1, n1)]; end
if n1 < n, Dp = [Dp, zeros(m, n-n1)];  end

[m1, n1] = size(Dm);
if m1 < m, Dm = [Dm; zeros(m-m1, n1)]; end
if n1 < n, Dm = [Dm, zeros(m, n-n1)];  end



function [p, apf] = mform(cc, ap) 
% insert cc in ap, or just give its index if it already exists

if grp(class(cc), 'double')
   cc = sprintf('%g', cc);
end
fl = isempty(ap);
if ~fl
   p = find(strcmp(cc, ap));
   if isempty(p)
      fl = 1;
   end
end
if isempty(cc)
   p = 0;
elseif fl
   s = 1 + length(ap);
   ap{s} = cc;
   p = s;
end
apf = ap;
