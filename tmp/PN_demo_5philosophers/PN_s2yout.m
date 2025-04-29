function yout= PN_s2yout(MP)
% General output of the Petri net
% see Petri Net in *.rdp
%
% MP: 1x15 : marked places (integer values >= 0)
%
% yout: 1x5 : flags showing philosophers eating

yout= MP(2:2:10);
yout= yout(:)';
