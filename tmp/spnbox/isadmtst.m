% ISADMTST - Test program for ISADM

% Written by Marian V. Iordache, miordach@nd.edu

if ~exist('xsave'), xsave = 0; end
echo on

% THRTANK -- The three tank problem

D1 = [
 1 -1  0  0;
-1  1 -1  1;
 0  0  1 -1;];

D = [zeros(9,3) [D1; zeros(6,4)] [zeros(3,4); D1; zeros(3,4)] [zeros(6,4); D1]
];

Tuc = [4:15]; Tuo = []; [Dm, Dp] = d2dd(D);

% Admissible constraints

L = zeros(3,9); b = 2*ones(3,1);
L(1,9) = 1; L(1,6) = 1; L(1,3) = -2;
L(2,3) = 1; L(2,9) = 1; L(2,6) = -2;
L(3,3) = 1; L(3,6) = 1; L(3,9) = -2;

m0 = zeros(9,1); m0([2 5 8]) = 1;

pn = getpn;
pn.Dm = Dm; pn.Dp = Dp; pn.Tuc = Tuc; pn.Tuo = Tuo; pn.m0 = m0;

waitkey(xsave)

[v] = isadm(pn, L, b)

waitkey(xsave)

% Add the firing vector constraints

F = [2*eye(3), zeros(3,12)]; 

% The constraints remain admissible

[v] = isadm(pn, L, F, b)

waitkey(xsave)

% Add an inadmissible constraint

L = [L; -L(3,:)]; b = [b; -2];

% (inadmissible as not satisfied by initial marking)

[v] = isadm(pn, L, b)

waitkey(xsave)

% Next we do the same operation with the coverability graph precomputed

graph = pncgraph(pn);
F = [F; zeros(1,15)];

waitkey(xsave)

[v] = isadm(pn, L, b, graph)

[v] = isadm(pn, L, F, b, graph)

waitkey(xsave)

% Next it is verified that the constraints fail the structural admissibility test

pn.m0 = [];
[v] = isadm(pn, L, [])

waitkey(xsave)

% Let's consider a new inadmissible constraint

L = zeros(1,9); b = -3; L([2 5 8]) = -1;

[v] = isadm(pn, L, []) % this is a structural analysis

pn.m0 = m0;
[v] = isadm(pn, L, b) % this is based on the coverability graph

echo off