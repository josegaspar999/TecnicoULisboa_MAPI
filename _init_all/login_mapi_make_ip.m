function ipStr= login_mapi_make_ip( op, a1 )
%
% Create one IP by checking its ping is failing

% May2022, J. Gaspar

if nargin<1
    op= 'make';
end

% global login_mapi_grp
global login_mapi_ipStr

switch op
    case 'make'
        ipStr= make_ip( login_mapi_ipStr ); % can be empty input
        login_mapi_ipStr= ipStr;

    case 'change_by_hand'
        ipStr= change_by_hand();
        login_mapi_ipStr= ipStr;
    case 'change_by_hand2'
        ipStr= change_by_hand(a1);
        login_mapi_ipStr= ipStr;

    case 'get_last_ip_choice'
        ipStr= get_last_ip_choice(login_mapi_ipStr);

    case 'show_ip'
        show_ip( login_mapi_ipStr )
    case 'show_ip1'
        show_ip( login_mapi_ipStr, 1 )
    case 'show_ip2'
        show_ip( a1, 1 )

    otherwise
        error('inv op')
end
return; % end of main function


function ipStr= get_ip_from_global()
global login_mapi_ipStr
ipStr= login_mapi_ipStr;


function ipStr= make_ip( ipStr )
% check current login_mapi_grp matches valid group 
% see in login_mapi valid groups

% ipStr= ''; % for failure returns

% My debug:
% global login_mapi_grp; login_mapi_grp= 'A1';

global login_mapi_grp
if ~login_mapi('-verify_group_name', login_mapi_grp )
    msgbox({'Did not detect your login.', 'Please run "login_mapi"'})
    return
end

% is your PLC turned OFF? it must be... or at least it has the ip not configured
s= questdlg({'Please confirm your PLC is turned OFF', ...
    '(it must be OFF or have Ethernet IP unconfigured or unplugged)'}, 'PLC OFF?', ...
    'Yes', 'No', 'Yes');
if strcmp(s, 'No')
    msgbox({'Your PLC must be OFF the Ethernet.', 'Turn its power OFF or put its Ethernet config empty.'})
    return
end

% debug of ping_ip() :
% ping_ip( '127.0.0.l' ) % if running the PLC simulator
% ping_ip( '192.168.1.101' ) % a local, specific, case

% loop to try to find the IP
h = waitbar(0,'Please wait...');
g= login_mapi_grp(end); % usually a digit 1..7
g= char( rem(g-'0', 10)+'0' );
for i= '0':'4'
    waitbar((i-'0'+1)/5,h)
    % pattern: 192.168.27.2AB where A in 0..4, B= group number
    ipStr= ['192.168.27.2' i g];
    if ~ping_ip( ipStr ) %system(['ping ' ipStr])
        % work done, found a failing ping, ipStr IS free to use
        close(h)
        msgbox(['PLC IP created: ' ipStr])
        return
    end
end

% loop failure
close(h)
msgbox('Could NOT find a free IP.')

return


function flag= ping_ip( ipStr )
% info from:
% https://stackoverflow.com/questions/9329749/batch-errorlevel-ping-response
flag= 0;
[~, str]= system(['ping ' ipStr]);
% [i1, i2]= regexp(str, '[0-9] *ms');
% for i=1:length(i1), str(i1(i):i2(i)), end
[i1, ~]= regexp(str, '[0-9] *ms');
if ~isempty(i1)
    flag= 1;
end
return


function ipStr= change_by_hand(ipStr)
if nargin<1
    ipStr= get_last_ip_choice(get_ip_from_global());
end
% debug: ipStr= '192.168.27.208';
prompt = ['Current IP= ' ipStr ' New IP:'];
dlgtitle = 'Change IP';
dims = [1 35];
definput = {'192.168.27.20'};
ipStr= inputdlg(prompt,dlgtitle,dims,definput);
ipStr= ipStr{1};
return


function show_ip( ipStr, shFlag )
if nargin<1
    ipStr= get_last_ip_choice(get_ip_from_global());
end
if nargin<2
    shFlag= 0;
end
msgbox(['PLC Modbus IP: ' ipStr])
if shFlag==1
    fprintf('\nCurrent PLC Modbus IP: %s\n\n', ipStr);
end


function ipStr= get_last_ip_choice(login_mapi_ipStr)
if nargin<1
    login_mapi_ipStr= get_ip_from_global();
end
ipStr= login_mapi_ipStr;

% if empty, ask whether to define one
if isempty(ipStr)
    msgbox({'Did not detect your login.', 'Please run "login_mapi"'})
    return
end

% check whether or not ipStr is working
