function login_mapi_cmd

% require group login (create folders):
global login_mapi_grp
login_mapi

while 1
    if isempty(login_mapi_grp)
        login_mapi
    else
        break
    end
end

%% show the working folder foreach group
%!start .

% exit Matlab
exit
