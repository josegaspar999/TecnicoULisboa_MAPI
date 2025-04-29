% LEDEM - Demonstration program for dp - liveness/T-liveness enforcement
% see DPDEM for deadlock prevention using dp

% Written by Marian V. Iordache, miordach@nd.edu

echo on

% Details on the implemented procedure can be found in:
%
% [Iordache 2000L] - M. Iordache, J. Moody, P. Antsaklis, 
%                     "Automated Synthesis of Liveness Enforcing Supervisors
%                     Using Petri Nets," technical report, available at
%                     http://www.nd.edu/~isis/tech.html 

% This is Example 5.2 of [Iordache 2000L]

Dp = [0 1 0 1 0; 0 0 1 0 1; 1 0 0 0 0];
Dm = [1 0 0 0 1; 1 0 0 1 0; 0 2 2 0 0];
pn = getpn(Dm, Dp);

% Press any key to continue 

pause

[L, b, L0, b0, how] = dp(pn, [], [], [], [], [], 15)

% Press any key to continue

pause

% Now we consider a Petri net in which deadlock can not be prevented

Dp = [0 1 0; 0 0 1; 1 0 0];
Dm = [1 0 0; 1 0 0; 0 1 1];

pn = getpn(Dm, Dp);

%Press any key to continue

pause

[L, b, L0, b0, how] = dp(pn, [], [], [], [], [], 15)

% Press any key to continue

pause

% The Petri net considered here has no smaller siphons and is repetitive

Dm = [0 1 0; 1 0 0; 0 0 1];
Dp = [1 0 0; 0 0 1; 0 1 0];

pn = getpn(Dm, Dp);

% Press any key to continue

pause

[L, b, L0, b0, how] = dp(pn, [], [], [], [], [], 15)
 

% Press any key to continue 
 
pause 
 
% Next it is considered a similar Petri net, but not strongly connected
% i.e. the union of two distinct repetitive Petri nets.

Dm = [Dm, zeros(3); zeros(3), Dm];
Dp = [Dp, zeros(3); zeros(3), Dp];

pn = getpn(Dm, Dp);

% Press any key to continue 
 
pause 
 
[L, b, L0, b0, how] = dp(pn, [], [], [], [], [], 15)
  
 
% Press any key to continue  
  
pause  
 
% Here we consider Example 5.1 of [Iordache, 2000] (see DPDEM)

Dm = [1 0 1 0 1; 0 0 0 1 0; 0 1 0 0 1; 1 0 1 0 0];
Dp = [0 0 0 1 0; 0 0 2 0 1; 3 0 0 0 0; 0 1 0 0 0];

pn = getpn(Dm, Dp);

% Press any key to continue

pause

[L, b, L0, b0, how] = dp(pn, [], [], [], [], [], 15)

% At this time we use nonzero initial constraints:

Li = [1 1 1 1]; Bi = [3];

% This means that we desire to enforce on the Petri net (Dm, Dp) Lx>=B,
% where x is the marking vector. The program is supposed to give the 
% rest of constraints that make (Dm, Dp, L, B) deadlock free.

% Press any key to continue 
 
pause 
 
[L, b, L0, b0, how] = dp(pn, [], Li, Bi, [], [], 15)

% Press any key to continue  
  
pause    

% This is Example 5.3 of [Iordache 2000L]; transition t1 is unobservable

D = [-1 -1 2; 1 0 -1; 0 1 -1]';
[Dm, Dp] = d2dd(D);

pn = getpn(Dm, Dp, [], 1);

% Press any key to continue  
  
pause

[L, b, L0, b0, how] = dp(pn, [], [], [], [], [], 15)

% This is an initial constraint example appearing as 
% Example 5.4 in [Iordache 2000L].

D = [-1  1  0  0  0  0;
     -1  0  1  0  0  0;
      2 -1 -1 -1  0  0;
      0  0  0  1  1 -1;
      0  0  0  0 -1  1;];

Li = -[1 1 1 1 1]; bi = -1;
pn = getpn(D);

pause

[L, b, L0, b0, how] = dp(pn, [], [], [], Li, bi, 15)


echo off

