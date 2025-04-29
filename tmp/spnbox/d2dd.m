function [Dm, Dp] = d2dd(D)

% [D^-, D^+] = d2dd(D)
%
% Decomposes D of a Petri net without self-loops in D^- and D^+.

Dm = -D.*(D < 0);
Dp =  D.*(D > 0);
