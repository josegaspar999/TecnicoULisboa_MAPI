% LINTST: Tests the transformations of LINENF.

% Written by Marian V. Iordache, miordach@nd.edu


%if ~nargin, xsave = 0; end

if ~exist('xsave'), xsave = 0; end

echo on

% The examples below are taken from "Supervisory Control of DES Using PN" 
% by J.O. Moody and P.J. Antsaklis, Kluwer, 1998.

% Example 1/Example 1 at page 60  

D = [-1 0 1; 1 -1 0; 0 1 -1]; m0 = [3; 0; 0]; Tuc = [2]; Tuo = [];

L = [0 0 1]; b = 1; [Dm, Dp] = d2dd(D);

waitkey(xsave)

[Dmf,Dpf,ms0,how,dhow,Lf,Cf,bf] = linenf(Dm, Dp, L, b, m0, [], [], Tuc, Tuo)

waitkey(xsave)

% Example 2/Example 2 at page 61

D = [-1 0 1; 1 -1 0; 1 -1 0; 0 1 -1]; m0 = [3; 0; 0; 0];
Tuc = [2]; Tuo = [];

L = [0 0 0 1]; b = 1;[Dm, Dp] = d2dd(D);

waitkey(xsave)

[Dmf,Dpf,ms0,how,dhow,Lf,Cf,bf] = linenf(Dm, Dp, L, b, m0, [], [], Tuc, Tuo)

waitkey(xsave)

% Example 3/Example 3 at page 62

D = [-1 -1 0 1; 1 0 -1 0; 0 1 -1 0; 0 0 1 -1;]; m0 = [3; 0; 0; 0];
Tuc = 3; Tuo = [];

L = [0 0 0 1]; b = 1;[Dm, Dp] = d2dd(D);

waitkey(xsave)

[Dmf,Dpf,ms0,how,dhow,Lf,Cf,bf] = linenf(Dm, Dp, L, b, m0, [], [], Tuc, Tuo)

waitkey(xsave)

% Example 4/The example at the pages 48-50

D = [-1 0 0 1; 0 -1 0 2; 2 1 -2 0; 0 0 1 -2]; m0 = [1 2 0 2]';
Tuc = 3; Tuo = [];

L = [0 0 0 1]; b = 2;[Dm, Dp] = d2dd(D);

waitkey(xsave)

[Dmf,Dpf,ms0,how,dhow,Lf,Cf,bf] = linenf(Dm, Dp, L, b, m0, [], [], Tuc, Tuo)

waitkey(xsave)

% Example 5/A deadlock prevention example

D = [-1 1 0; -1 0 1; 2 -1 -1]; m0 = [1; 1; 0]; Tuc = []; Tuo = 1;

L = [-1 0 -1; 0 -1 -1]; b = [-1; -1];[Dm, Dp] = d2dd(D);

waitkey(xsave)

[Dmf,Dpf,ms0,how,dhow,Lf,Cf,bf] = linenf(Dm, Dp, L, b, m0, [], [], Tuc, Tuo)

waitkey(xsave)

% Example 6/The example at page 95 for firing vector constraints

D = [-1 0 1; 1 -1 0; 0 1 -1]; m0 = [3 0 0]'; Tuc = 3; Tuo = [];

L = [0 1 0]; F = [0 0 1]; b = 1; [Dm, Dp] = d2dd(D);

waitkey(xsave)

[Dmf,Dpf,ms0,how,dhow,Lf,Cf,bf] = linenf(Dm, Dp, L, b, m0, F, [], Tuc, Tuo)

waitkey(xsave)

% Example 7+/A fairness constraint test

% first no uncontrollable and unobservable transitions

D = [-1 -1 1 1; 1 0 -1 0; 0 1 0 -1]; m0 = [2 0 0]'; Tuc = []; Tuo = [];

L = []; F = []; C = [1 -1 0 0]; b = 2; [Dm, Dp] = d2dd(D);

waitkey(xsave)

[Dmf,Dpf,ms0,how,dhow,Lf,Cf,bf] = linenf(Dm, Dp, L, b, m0, F, C, Tuc, Tuo)

waitkey(xsave)

% add unobservable transitions

Tuo = [1 2];

waitkey(xsave)

[Dmf,Dpf,ms0,how,dhow,Lf,Cf,bf] = linenf(Dm, Dp, L, b, m0, F, C, Tuc, Tuo)

waitkey(xsave)

% notice that for m0 = [4 0 0]', linenf detects correctly that it is 
% impossible to synthesize a supervisor. 

m0 = [4 0 0]';

waitkey(xsave)

[Dmf,Dpf,ms0,how,dhow,Lf,Cf,bf] = linenf(Dm, Dp, L, b, m0, F, C, Tuc, Tuo)

waitkey(xsave)

m0 = [2 0 0]';

C = [C; -1 1 0 0]; b = [b; 2];

waitkey(xsave)

[Dmf,Dpf,ms0,how,dhow,Lf,Cf,bf] = linenf(Dm, Dp, L, b, m0, F, C, Tuc, Tuo)

waitkey(xsave)

% ATMSW -- the ATM switch example (pp. 136-139) used as a test program

D = [
 1  0  0 -1  0  0 -1  0  0  0  0;
 0  1  0  0 -1  0  0 -1  0  0  0;
 0  0  1  0  0 -1  0  0 -1  0  0;
 0  0  0  1  1  1  0  0  0 -1  0;
 0  0  0  0  0  0  1  1  1  0 -1;];

L = [ 0 0 0 1 0;
      0 0 0 0 1;
      0 0 0 0 0;
      0 0 0 0 0;];

F = [ 0 0 0 0 0 0 0 0 0 0 0;
      0 0 0 0 0 0 0 0 0 0 0;
      0 0 0 1 1 1 0 0 0 0 0;
      0 0 0 0 0 0 1 1 1 0 0;];

b = [5 5 2 2]'; C = []; m0 = [];

Tuc = [1:3, 10:11]; [Dm, Dp] = d2dd(D);

waitkey(xsave)

[Dmf,Dpf,ms0,how,dhow,Lf,Cf,bf] = linenf(Dm, Dp, L, b, m0, F, C, Tuc)

waitkey(xsave)

% CATMOUSE -- test program for enforcing linear matrix inequalities

% See section 8.1 (pp. 113-119) in the PN book

D = [
-1  0  1 -1  0  1  0  0  0  0  0  0  0  0;
 1 -1  0  0  0  0 -1  1  0  0  0  0  0  0;
 0  1 -1  0  0  0  0  0  0  0  0  0  0  0;
 0  0  0  1 -1  0  1 -1  0  0  0  0  0  0;
 0  0  0  0  1 -1  0  0  0  0  0  0  0  0;

 0  0  0  0  0  0  0  0 -1  0  1 -1  0  1;
 0  0  0  0  0  0  0  0  0  1 -1  0  0  0;
 0  0  0  0  0  0  0  0  1 -1  0  0  0  0;
 0  0  0  0  0  0  0  0  0  0  0  0  1 -1;
 0  0  0  0  0  0  0  0  0  0  0  1 -1  0;];

L = [1 0 0 0 0 1 0 0 0 0;
     0 1 0 0 0 0 1 0 0 0;
     0 0 1 0 0 0 0 1 0 0;
     0 0 0 1 0 0 0 0 1 0;
     0 0 0 0 1 0 0 0 0 1;];

b = [1 1 1 1 1]';

m0 = [0 0 1 0 0 0 0 0 0 1]';

F = []; C = [];

[Dm, Dp] = d2dd(D);
waitkey(xsave)

[Dfm, Dfp, ms0, how, dhow, Lf, Cf, bf] = linenf(Dm, Dp, L, b, m0, F, C)

waitkey(xsave)

Tuc = [7,8]; Tuo = [];

waitkey(xsave)

[Dfm, Dfp, ms0, how, dhow, Lf, Cf, bf] = linenf(Dm, Dp, L, b, m0, F, C, Tuc)

waitkey(xsave)

% PRRACTST -- the Piston Rod Robotic Assembly Cell example (pp. 129-136) used
% as a test program

D = [
-1  0  0  0  0  0  0  1;
 1 -1  0  0  0  0  0  0;
 0  1 -1  0  0  0  0  0;
 0  0  0  1 -1  0  0  0;
 0  0  0  0  1 -1  0  0;
 0  0  0  0  0  1 -1  0;
 0  0  0  0  0  0  1 -1;];

m0 = [1 0 0 0 0 0 0]';

[Dm, Dp] = d2dd(D);

L = [0 1 1 0 0 0 0;
     0 0 0 1 1 1 1;
     1 1 1 0 1 1 1;
     0 0 1 0 0 0 0;
     0 0 0 1 1 0 0;
     0 0 0 0 0 1 0;
     0 0 0 0 0 0 1;];

b = ones(7,1); F = []; C = [];
Tuc = [6 7 8];

waitkey(xsave)

[Dmf,Dpf,ms0,how,dhow,Lf,Cf,bf] = linenf(Dm, Dp, L, b, m0, F, C, Tuc)

waitkey(xsave)

Tuo = [5 6 7];

waitkey(xsave)

[Dmf,Dpf,ms0,how,dhow,Lf,Cf,bf] = linenf(Dm, Dp, L, b, m0, F, C, Tuc, Tuo)

waitkey(xsave)

% THRTANK -- The three tank problem (pp. 139-148)

D1 = [
 1 -1  0  0;
-1  1 -1  1;
 0  0  1 -1;];

D = [zeros(9,3) [D1; zeros(6,4)] [zeros(3,4); D1; zeros(3,4)] [zeros(6,4); D1]
];

Tuc = [4:15]; [Dm, Dp] = d2dd(D);

L = zeros(7,9); C = []; m0 = [];

F = zeros(7,15);

L(2,1) = 1; L(3,4) = 1; L(4,7) = 1;
L(5:7,[3,6,9]) = [-2 1 1; 1 -2 1; 1 1 -2];
F(1,1:3) = 1; F(2,1) = 1; F(3,2) = 1; F(4,3) = 1;
F(5,1) = 2; F(6,2) = 2; F(7,3) = 2;

b = [1 1 1 1 2 2 2]';

waitkey(xsave)

[Dfm, Dfp, ms0, how, dhow, Lf, Cf, bf] = linenf(Dm, Dp, L, b, m0, F, C, Tuc)

waitkey(xsave)

% UNRELTST - the unreliable machine example (pp. 122-129), as a test program

D = [
 1 -1  0  0  0 -1  0  0  0  0;
 0  1 -1  0  0  0  0  0  0  0;
 0  0  1 -1  0  0  0  0  0  0;
 0  0  0  1 -1  0  0  0  0  0;
 0  0 -1  0  1  0  0  0  0  0;

 0  0  0  0  0  1 -1  0  0  0;
 0  0  0  0  0  1  0  0  0 -1;
 0  0  0  0  0  0  1 -1  0  0;
 0  0  0  0  0  0  0  1 -1  0;
 0  0  0  0  0  0 -1  0  1  0;];

% 0  0  1  0 -1  0  1  0 -1  0;
%-1  0  1  0  0  0  1  0  0  0;
%-1  1  0  0  0  0  0  0  0  1;];

[Dm, Dp] = d2dd(D); Tuc = [2,6]; F = []; C = [];


L = [0 0 0 0 1 0 0 0 0 1;
     0 1 0 0 0 1 0 0 0 0;
     1 0 0 0 0 0 1 0 0 0;];
%L = [L, zeros(3)];
b = [1 1 1]'; m0 = [];

waitkey(xsave)

[Dmf,Dpf,ms0,how,dhow,Lf,Cf,bf] = linenf(Dm, Dp, L, b, m0, F, C, Tuc)

waitkey(xsave)

% HSDINT - Hybrid System Double Integrator example (pp. 148-152) used as a 
% test program

D = [
 1  1 -1 -1  0  0  0  0  0  0;
 0  0  0  0  0  0 -1 -1  1  1;
-1  0  0  0  0  0  1  0  0  0;
 0  0  0  1  0  0  0  0  0 -1;
 0 -1  1  0  0  0  0  1 -1  0;];

[Dm, Dp] = d2dd(D); Dm(3,5) = 1; Dp(3,5) = 1; Dm(4,6) = 1; Dp(4,6) = 1;

L = [0 0 0 0 0; 1 1 0 0 1]; L = -L; C = [];
F = [zeros(1,4), 1, 1, zeros(1,4); zeros(1,10)]; m0 = [];
b = [0; -1];

waitkey(xsave)

[Dmf,Dpf,ms0,how,dhow,Lf,Cf,bf] = linenf(Dm, Dp, L, b, m0, F)

waitkey(xsave)


echo off


