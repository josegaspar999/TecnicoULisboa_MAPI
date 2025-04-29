function qk= PN_tfire(act, t)
% Possible-to-fire transitions given PN outputs (act) and the time t
% see Petri Net (*.RDP)
%
% act: 1xN : actuation signals
% t  : 1x1 : time
% qk : 1xM : possible firing vector (to be filtered later with enabled
%            transitions)

qk= pdinner_IO(act, t);

% qk= round(rand(1,5)); qk= [qk  not(qk)];

% global lastQk
% if isempty(lastQk)
%     lastQk= [0 0 0 1 0];
% end
% qk= [lastQk(end-1:end) lastQk(1:end-2)]; lastQk= qk; qk= [qk 1-qk];
