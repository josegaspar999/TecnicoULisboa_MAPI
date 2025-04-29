function pdinner_tst(tstId)
if nargin<1
    tstId= 2; %1;
end
warning('off','MATLAB:dispatcher:InexactCaseMatch');
file_put_in_path('rdp.m');

switch tstId
    case 0, % load the .RDP file

        [Pre, Post, M0] = rdp('PDINNER.RDP')

    case 1, % show input data
        figure(201), clf; pdinner_IO; grid on;

    case 2, % test the Petri net

        % run the simulation
        % 1. load PN gives matrices Pre, Post and vector M0
        % 2. sim results in a structure: ret.t, ret.qin, ret.M, ret.yout
        [Pre, Post, M0] = rdp('PDINNER.RDP');
        ret= PN_sim(Pre, Post, M0, [0 10 .1]);
        % ret= PN_sim(Pre, Post, M0, [0 10 .01]); % more resolution plots

        % plot the results
        figure(201), clf;
        subplot(3,3,1:6); imshow('pdinner.png'); title('Five philosophers dinner')
        subplot(3,2,5); plot_z(ret.t, ret.M, '-');    xlabel('time'); ylabel('place number'); grid on;
        title('State of the PN along time')
        subplot(3,2,6); plot_z(ret.t, ret.qin(:,1:5), 'co-'); grid on; % show input data
        subplot(3,2,6); plot_z(ret.t, ret.yout, 'b.-'); xlabel('time'); ylabel('want / got dinner'); grid on;
        title('Asked (cyan) vs got (blue) dinner')
        
        % eval satisfied requests
        N= size(ret.yout,2);
        satisf_perc= (1-sum(ret.qin(:,1:N)-ret.yout)/length(ret.yout))*100

    otherwise
        error('invalid tstId')
end

return
