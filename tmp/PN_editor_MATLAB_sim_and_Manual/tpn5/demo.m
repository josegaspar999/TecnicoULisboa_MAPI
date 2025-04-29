function demo(tstId)

if nargin<1
    tstId= 1;
end
switch tstId
    case {1, -1}
        %fname= 'demo_net.rdp';
        fname= 'demo_net.xml';
    case 2
        %fname= '../pmedit/didac/ex_03.rdp';
        fname= '../pmedit/didac/ex_01.rdp';
    case 3
        fname= '../pmedit/examples/net.rdp';
    case 0
        compare_rdp_xml; return
end


% 1. load the Petri Net
[Pre, Post, M0]= rdp( fname )

% 2. convert representation
[A, ~]= reach_graph( Pre, Post, M0 )

% 3. draw the graph of reachable markings (reachability tree)
disp('each col = [state parentState number_subs_of_state trans Xi Xf Yi Yf col]')
disp_gr(A)


if tstId==-1
    % some more testing for a Stochastic Timed Petri Net
    %
    TimeT=[0 0 3 4]';
    TypeT=[0 0 1 1]';
    ticks=100;
    [Seq, M] = playstpn(Pre, Post, M0, TimeT, TypeT, ticks);
    Seq'
end


function compare_rdp_xml
fname= 'demo_net.rdp'; [Pre1, Post1, M01]= rdp( fname ); PN1= [Pre1, Post1, M01]
fname= 'demo_net.xml'; [Pre2, Post2, M02]= rdp( fname ); PN2= [Pre2, Post2, M02]
compare( 'Pre' ), compare( 'Post' ), compare( 'M0' )


function compare( str )
n1= [str '1']; v1= evalin('caller', n1);
n2= [str '2']; v2= evalin('caller', n2);
if max(abs(size(v1)-size(v2)))>eps
    fprintf(1,'** %s ~= %s sizes err\n', n1, n2 );
    return
end
if max(abs(size(v1)-size(v2)))>eps
    fprintf(1,'** %s ~= %s values differ\n', n1, n2 );
    return
end
fprintf(1,'%s == %s\n', n1, n2 );
