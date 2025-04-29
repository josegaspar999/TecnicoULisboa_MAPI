function [v] = ts_adm(mark, pnobj, pplaces, cplaces)

% TS_ADM - Subroutine of ISADM.

% returns 1's for INADMISSIBLE constraints and -1's for possibly inadmissible
% constraints. The other entries are 0. 

% cplaces: control places, pplaces: plant places

% Written by Marian V. Iordache, miordach@nd.edu

v = zeros(length(cplaces),1); z = v;
Dp = pnobj.Dp; Dm = pnobj.Dm; Tuc = pnobj.Tuc; Tuo = pnobj.Tuo;
D = Dp - Dm; nuc = length(Tuc); nuo = length(Tuo);

for i = 1:nuc
    if mark(pplaces) >= Dm(pplaces,Tuc(i)) % if the transition is enabled in the plant
        nmark = mark + D(:,Tuc(i));
        v = v | (nmark(cplaces) < 0); % check whether it is inhibitted by supervisor
        z = z | (nmark(cplaces) == Inf); % checks whether this test cannot decide 
        % whether the supervisor inhibits the transition
    end
end
for i = 1:nuo
    if mark >= Dm(:,Tuo(i)) % if the transition is enabled
        nmark = mark + D(:,Tuo(i)); % check whether it's firing is detected
        v = v | (nmark(cplaces) ~= mark(cplaces) );
    end
end
    
ind = find(~v); % select constraints not proved inadmissible
v(ind) = -z(ind); % and set to -1 the entries of those not shown to be admissible
