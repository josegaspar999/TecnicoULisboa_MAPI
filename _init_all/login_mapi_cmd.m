function login_mapi_cmd( op )

switch op
    case 'root', cd2file('login_mapi.m'); !start .
    case 'login_show_folder_and_exit', show_folder_and_exit( 1, 1 );
    case {'home', 'login_show_folder'}, show_folder_and_exit( 1, 0 );
    case 'cleanup', windows_cleanup
    otherwise
        error('inv op "%s"', op);
end


function windows_cleanup
% show folder with 'scan_and_reboot.bat'
% so that one can "run as administrator"
cd2file( 'scan_and_reboot.bat' )
!start .


function show_folder_and_exit( showFolderFlag, exitFlag )

% require group login (create folders):
global login_mapi_grp
% login_mapi
while 1
    if isempty(login_mapi_grp)
        login_mapi
    else
        break
    end
end

% show the working folder foreach group
if showFolderFlag
    !start .
end

% exit Matlab
if exitFlag
    exit
end
