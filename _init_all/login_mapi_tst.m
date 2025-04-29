function login_mapi_tst( tstId )
if nargin<1
    tstId= 'tst_logins';
    % tstId= 'tst_another_folder';
end
switch tstId
    case 'tst_logins', tst_logins
    case 'tst_another_folder', tst_another_folder
    otherwise, error('inv tstId')
end


function tst_logins
% simulate groups A1..A7, B1..B7, and verify login works
lst= {'A', '1':'4'; 'B', '1':'5'};
for i= 1:size(lst,1)
    for j= lst{i,2}
        cd0= cd;
        grp= [lst{i,1} j];
        fprintf(1, '\n --- Group name = %s\n', grp );
        login_mapi( grp )
        cd(cd0)
    end
end


function tst_another_folder
% simulate groups A1..A7 and copy into their GDrive folders the SVN files

login_mapi('-set_working_folder2', 'H:\My Drive\Classroom\MAPI\groups\A9');
login_mapi('-show_opt');
login_mapi tmp

for i='1':'7' %'8'
    login_mapi('-set_working_folder2', ['H:\My Drive\Classroom\MAPI\groups\A' i]);
    login_mapi tmp
end
