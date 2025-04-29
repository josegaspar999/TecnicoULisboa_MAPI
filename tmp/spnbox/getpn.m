function [o] = getpn(Dm,Dp,Tuc,Tuo,m0)

% GETPN - Creates a PN object
%
% It can be used in any of the formats below
%
% [o] = getpn;
%
% [o] = getpn(D);
%
% [o] = getpn(Dm,Dp);
%
%    ...
%
% [o] = getpn(Dm,Dp,Tuc,Tuo,m0)

% Written by Marian V. Iordache, miordach@nd.edu

if nargin == 1, [Dm, Dp] = d2dd(Dm); end
if nargin < 1, Dm = []; Dp = []; end
if nargin < 3, Tuc = []; end
if nargin < 4, Tuo = []; end
if nargin < 5, m0 = []; end

o = struct('m0',m0,'Dm',Dm,'Dp',Dp,'Tuc',[],'Tuo',[]);

o.Tuc = Tuc;
o.Tuo = Tuo;

