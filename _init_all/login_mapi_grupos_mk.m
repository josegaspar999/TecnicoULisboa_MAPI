function login_mapi_grupos_mk

for i='A':'B'
    for j=1:8
        fprintf('%%\n%% Group %s%1d\n',i,j);
        for k=1:3, fprintf('%% 12345 Name Surname\n'); end;
    end
end
