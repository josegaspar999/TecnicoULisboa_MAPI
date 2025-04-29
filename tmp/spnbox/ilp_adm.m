function [La, ba, R1, R2, how, dhow] = ilp_adm(L, b, D, Tuc, Tuo, m0, vrb)

% ILP_ADM - transformation to admissible constraints based on linear integer 
%           programming
%
% [La, ba, R1, R2, how, dhow] = ilp_adm(L, b, D, Tuc, Tuo, m0, vrb)
%
% The function transforms a marking constraint L*m <= b to an admissible 
% marking constraint (R1 + R2*L)*m <= R2*(b+1). If the transformation is
% possible for the given initial marking, 'ok' is returned in a variable
% how; else 'impossible' is returned; similarly, dhow{i} is 'ok' if the
% transformation of the constraint i of Lm <= b was possible.
%
% D   - the incidence matrix
% Tuc - the uncontrollable transitions (e.g. for Tuc = [2, 5], the second and 
%       the fifth columns of D correspond to uncontrollable transitions
% Tuo - the unobservable transitions
% m0  - the initial marking
% vrb - use vrb = 0 to suppress messages. Default is vrb = 1.
% 
% Use m0 = [] or only the first five arguments if the initial marking is
% not of interest. 

% Written by Marian V. Iordache, miordach@nd.edu

how = 'ok'; dhow = {}; flg = 0;
if nargin < 7, vrb = 1; end
if nargin < 6, m0 = []; end
if nargin < 5, Tuo = []; end
if vrb, fprintf('\n'); end
flg = isempty(m0); 

Duc = D(:,Tuc); Duo = D(:,Tuo);
[m, n] = size(D); [p, f] = size(L); if isempty(b) & ~p, b = zeros(0,1); end

R1 = zeros(p,m); R2 = eye(p);
for i = 1:p, dhow{i} = 'ok'; end
if ~p, dspy('Empty set of constraints!','','',p,p,vrb); end
if ~f, dspy('Empty set of places!','','',1,1,vrb); La = L; ba = b; return; end

for i = 1:p
   l = L(i,:); 
   nflg = flg;
   if ~flg
      if (l*m0 <= b(i)), nflg = 1; end
   end
   
   aa = 0; bb = 0;
   if isempty(Duc), aa = 1;
   elseif (l*Duc <= 0), aa = 1; end
   
   if isempty(Duo), bb = 1;
   elseif (l*Duo == 0), bb = 1; end
      
   if ~nflg & ~flg
      dhow{i} = 'infeasible';
      dspy('The transformation is infeasible due to the initial marking', '', '.', i, p, vrb);
   elseif aa & bb
      dhow{i} = 'ok';
      dspy('No transformation is necessary', '', '.', i, p, vrb);
   else
      M = [Duc Duo -Duo; l*Duc l*Duo -l*Duo]; 
      [u, v] = size(M); N = zeros(v,1);
      vlb = zeros(u,1); vlb(u) = 1; % this ensures r2 >= 1

      if isempty(m0)
         f = ones(m+1, 1); 
         %[r, hw] = solve_ip(f, -M', N, [], [], vlb); 
         [r, hw] = ip_solve(-M', N, f, [], [], vlb); 
         dhow{i} = hw;
         if r'*[eye(u-1); l] == 0 & ~isempty(b)
            % this treats the case when La == 0 and La*m<= ba is infeasible
            if b(i) <= -1
               N = [N; 1]; % the constraint sum(r1+r2*l) <= -1 is added
               M = [M, [ones(u-1,1); sum(l)]];
               %[r, hw] = solve_ip(f, -M', N, [], [], vlb);
               [r, hw] = ip_solve(-M', N, f, [], [], vlb); 
               if isempty(r), dhow{i} = 'not solved'; % r empty when the program is infeasible
               else dhow{i} = hw; end
            end
         end
      else
         f = [m0; (l*m0-b(i)-1)]; % other costs could also be used
         %[r, hw] = solve_ip(f, [-M'; -f'], [N; 1], [], [], vlb); 
         [r, hw] = ip_solve([-M'; -f'], [N; 1], f, [], [], vlb); 
         dhow{i} = hw; % the integer program includes the requirement
      end % that the initial marking is feasible

      if ~isempty(r)
         R1(i,:) = r(1:m)';
         R2(i,i) = r(m+1);
      end
      
      if ~strcmp('ok',hw), dspy('The problem is ', hw, '.', i, p, vrb); end
   end 
end

xx = 0; yy = 0;
for i = 1:p
   if strcmp(dhow{i},'infeasible'), xx = 1; end
   if strcmp(dhow{i},'not solved'), yy = 1; end
end

% The program won't return 'not solved' unless solve_ip does not 
% treat satisfactorily the case when the problem is unbounded.

if yy, how = 'not solved'; end
if xx, how = 'impossible'; end

La = R1 + R2*L; ba = b;
if ~isempty(b), ba = R2*(b+ones(p,1)) -ones(p,1); end
if vrb, fprintf('\n'); end



function dspy(bg, prm, ed, i, p, vrb)

if vrb
   if p <= 1
      fprintf('ILP_ADM: %s%s%s\n', bg, prm, ed);
   else
      fprintf('ILP_ADM, constraint %d: %s%s%s\n', i, bg, prm, ed);
   end
end
