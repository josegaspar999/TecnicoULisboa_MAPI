function ret= gdrive_mapi( op, a1, a2 )
%
% Google Drive utils. Most information is accessible using login_mapi.m

% Usages:
% gdrive_mapi('gui')
% gdrive_mapi('online_zip')
% gdrive_mapi('online_area')

% May2022, Mar2023 (GUI help), J. Gaspar

if nargin<1
    op= 'gui';
    %op= 'zip_mk';
    %op= 'zip_config';
    %op= 'online_area';
end

switch op
    case 'gui'
        gdrive_mapi_gui()
    case 'zip_config'
        zip_config();
    case 'zip_mk'
        zip_mk(); %'lab zip mk'

    case 'online_zip' %'open location of lab zip'
        !start https://drive.google.com/drive/folders/1bPsxxGYq11eAo1zA3Supncj4B3o3LM4v?usp=sharing
    case 'online_area' %'open area to use'
        show_private_gdrive()

    case 'ask_gname'
        ask_gname_gui();
    case 'ask_pass'
        ask_pass_gui();
    case 'show_grp_pass'
        show_grp_pass();
        
end

return; % end main function


% ---------------------------------------------------------------------

% % -- DO ONCE, adapting to the local PC:
% login_mapi('-set_zip_folder', 'H:\My Drive\Classroom\MAPI\shared\zip')
% login_mapi('-set_7zip_exe',  '"C:\Program Files\7-Zip\7z.exe"')

% % -- Check it worked
% login_mapi('-zip_folder')
% login_mapi('-7zip_exe')
% login_mapi('-show_diskmem')

function zip_config

% Check zips folder and zip/unzip program exist
%   by testing the existence of two files fname1 and fname2;
%   In case of success, do not ask again the information.
%
refFilename= '_mapi_shared_zip_folder.txt';
fname2= [login_mapi('-zip_folder') filesep refFilename];
fname1= strrep(login_mapi('-7zip_exe'),'"', '');
if exist(fname1, 'file') && exist(fname2, 'file')
    msgbox({'This PC is configured to make ZIP files.', ...'
        'Does NOT need configuration work.'})
    return
end

% Indicate the location of 7z.exe
if 1
    if isempty(dir('C:\Program Files\7-Zip\7z.exe'))
        msgbox({'ERROR: 7z.exe not in the default location', ...
            '(tell this info to the professor)'});
        return
    end
    login_mapi('-set_7zip_exe',  '"C:\Program Files\7-Zip\7z.exe"')
end

% Indicate the location of the folder that holds the zip files
%   (can be in the Windows drive g:\ or h:\)
if 1
    dList= 'g':'h';
    h = waitbar(0,'Please wait...');
    for i= 1:length(dList)
        waitbar(i/length(dList), h)
        [flag, dname2]= find_mapi_zip_folder( [dList(i) ':\'], refFilename );
        if flag
            break;
        end
    end
    close(h);
    
    % final success or failure message
    if ~flag
        msgbox({'ERROR: did not find folder to hold zip files', ...
            '(tell this info to the professor)'});
    else
        login_mapi('-set_zip_folder', dname2 );
        msgbox('Success, found folder to save ZIP files')
    end
end

return


function [flag, dname2]= find_mapi_zip_folder( dname, refFilename )
flag= 0; dname2= '';
y= xtree(dname, struct('ret_list2','', 'get_files',''));
if isempty(y)
    % failed
    return
end
for i= 1:size(y,1)
    if strcmp(y{i,2}, refFilename)
        flag= 1;
        dname2= y{i,1};
        dname2= strrep(dname2, '//','/');
        if dname2(end)=='/'
            dname2= dname2(1:end-1);
        end
        dname2= strrep(dname2, '/',filesep);
    end
end

return


% ---------------------------------------------------------------------
function zip_mk()
% make a zip file for the current group

% an encrypted zip file allows:
% - testing group password
% - making new encrypted zips
% - access a private online (gdrive) folder

% if not available, ask the password
% check the password is correct for the group
% make the incremental ZIP

% login_mapi('-set_group_name', 'A1');
% login_mapi('-set_group_name', 'A3');
% login_mapi('-set_group_pass', 'xpto'); % force error/warning
% login_mapi('-set_group_pass', ''); % force error/warning

% -- program to run
x7zip= login_mapi('-7zip_exe');

% -- source data
[okFlag, gname, gpass, gfolder]= get_group_info();
if ~okFlag
    return
end

% -- destination data
zfolder= login_mapi('-zip_folder');
zfolder= [zfolder filesep gname filesep];
[y,m,d,h,mi,s]= datevec(now);
%str= sprintf('%02d%02d%02d_%02d%02d%02d', rem(y,100), m, d, h, mi, round(s));
%str= sprintf('MAPI_%s_lab_%02d%02d%02d', gname, rem(y,100), m, d);
str= sprintf('MAPI_%s_lab_%02d%02d%02d_%02d%02d', gname, rem(y,100),m,d, h,mi);
zname= [zfolder str '.zip'];
% duplicate a previous zip? if ~exist(zname) but exist(prev zname) ... copy

% -- finally make the zip:
% call 7zip as suggested in
% https://superuser.com/questions/544336/incremental-backup-with-7zip
%   7zr u -up0q3r2x2y2z1w2 {archive}.7z {path}
str= ['!' x7zip ' u -p' gpass ' -up0q3r2x2y2z1w2 "' zname '" "' gfolder '"'];
eval(str)

return


function [okFlag, gname, gpass, gfolder, tname]= get_group_info()
okFlag= 0;
gpass=''; gfolder='';

gname  = login_mapi('-group_name');
if ~login_mapi('-verify_group_name', gname)
    warning('Problem with group name (did you run login_mapi ?).')
    return
end
gfolder= login_mapi('-working_folder', gname);
gpass  = login_mapi('-group_pass');
dname= fileparts( which('login_mapi.m') );
dname= [dname '\..\tmp\etc\'];
tname= [dname gname '.zip'];
x7zip= login_mapi('-7zip_exe');

% test password as suggested in
% https://superuser.com/questions/1645778/check-password-of-large-7zip-file-quickly
% exitcode = 7z t archive.zip -p password
gpass= password_test( x7zip, tname, gpass );
if isempty(gpass)
    warning('Password issue. Warn the professor.')
    return
end

okFlag= 1;
return


function gpass= password_test( x7zip, tname, gpass )
if isempty(gpass)
    gpass= ask_pass_gui();
    if isempty(gpass)
        return
    end
end

str= [x7zip ' t "' tname '" -y -p' gpass];
[status, res]= system(str);
if status~=0
    % zero status would mean success
    % nonzero, means password issue
    warning('Failed password test (password not set?).')
    gpass= '';
    return
end


function gname= ask_gname_gui()
gname = login_mapi('-group_name');
prompt = ['Current group name "' gname '". New group name:'];
dlgtitle = 'Group name';
dims = [1 35];
definput = {''};
gname= inputdlg(prompt,dlgtitle,dims,definput);
if isempty(gname)
    % user canceled
    return
end
gname= gname{1};
login_mapi('-set_group_name', gname);
return


function gpass= ask_pass_gui()
gname = login_mapi('-group_name');
prompt = ['Group "' gname '", password assigned by the professor:'];
dlgtitle = 'pass';
dims = [1 35];
definput = {''};
gpass= inputdlg(prompt,dlgtitle,dims,definput);
if isempty(gpass)
    % user canceled
    return
end
gpass= gpass{1};
login_mapi('-set_group_pass', gpass);
return


function show_grp_pass()
gname= login_mapi('-group_name');
gpass= login_mapi('-group_pass');
msg= {['Group name= ' gname], ['Group pass= ' gpass]};
msgbox(msg)
disp(msg)


% ---------------------------------------------------------------------
function show_private_gdrive()
% do trials with group A8 (A9 and tmp will fail verifications)
% usage: url= group_data('gdrive_url');

% temporary zip folder
%   \lab_svn\tmp\zz_tmp_to_delete
% make data file (group_data.m) to folder, check success
% 7zip extract to folder
% get url
% make data file to folder, check success

%[okFlag, gname, gpass, gfolder, tname]= get_group_info();
[okFlag, ~, gpass, ~, tname]= get_group_info();
if ~okFlag
    return
end

% folder is clean to work on:
tmp_folder_tst()

% do the work, i.e. get url and open it:
url= get_url_from_zip( tname, gpass );
system(['start ' url]);

% make folder clean for future reuse:
tmp_folder_tst()

return


function dname2= tmp_folder()
dname2= fileparts( which('login_mapi.m') );
dname2= [dname2 '\..\tmp\zz_tmp_to_delete\'];


function tmp_folder_tst()
dname2= tmp_folder();
fname= 'group_data.m';
txt= num2str(randi(10000));

cd0= cd;
cd(dname2);

% check tmp folder is clean
if exist([dname2 fname], 'file')
    warning('failed tmp folder cleanup')
end

% make a file
fid= fopen(fname, 'wt');
fprintf(fid, '%s\n', txt);
fclose(fid);
fid= fopen(fname, 'rt');
txt2= fgetl(fid);
fclose(fid);
if ~strcmp(txt, txt2)
    error('failed tmp folder write/read')
end

% cleanup / delete the file
delete(fname);
if exist([dname2 fname], 'file')
    error('failed tmp folder cleanup')
end

cd(cd0);


function url= get_url_from_zip( tname, gpass )
% unzip, run local file
dname2= tmp_folder();
x7zip= login_mapi('-7zip_exe');
str= [x7zip ' e "' tname '" -p' gpass ' -o"' dname2 '"'];
%[status,result]= system(str);
[status,~]= system(str);
if status~=0
    error('failed get url')
end
cd0= cd;
cd(dname2);
url= group_data('gdrive_url');
delete('group_data.m')
cd(cd0);
return


% ---------------------------------------------------------------------
function gdrive_mapi_gui( cmdId )
if nargin<1
    cmdId= '';
end

% 'lab zip mk'
% 'open location of lab zip'
% 'open area to use'

% 'lab zip mk'
% 'open gdrive location of lab zip'
% 'open gdrive area to use'

% List of available menu options
cmd= {
    'Make ZIP into GDrive ZIP area',   'gdrive_mapi("zip_mk");'; ...
    'Show GDrive ZIP area',     'gdrive_mapi("online_zip");'; ...
    'Show GDrive area to work', 'gdrive_mapi("online_area");'; ...
    ... %'Area to work online', 'gdrive_mapi("online_area");'; ...
    '---', ''; ...
    'Show group name and password', 'gdrive_mapi("show_grp_pass");'; ...
    'Input password (the one given by the professor)', 'gdrive_mapi("ask_pass");'; ...
    'Input group name', 'gdrive_mapi("ask_gname");'; ...
    '---', ''; ...
    'Config this PC (do just once per PC)', 'gdrive_mapi("zip_config");'; ...
    'Help on these commands', 'doc gdrive_mapi_help';
    };
for i=1:size(cmd,1)
    cmd{i,2}= strrep( cmd{i,2}, '"', '''' );
end

% TO DO
%    'Config this PC by hand (do just once per PC)', 'gdrive_mapi("zip_config");'; ...

% Define what is to be done
if isempty(cmdId)
    % ask user what is to be done
    [indList, okFlag] = listdlg('PromptString',...
        {'Select action to do' ,'(press Cancel to avoid action):'},...
        'SelectionMode', 'multiple',... %'single', ... %'multiple',...
        'ListSize', [300 100], ... %370], ...
        'ListString', cmd(:,1) );
else
    % cmdId should match an entry in cmd(:,1), e.g. cmd{5,1}
    okFlag= 0;
    for i=1:size(cmd,1)
        if strcmp(cmd{i,1}, cmdId)
            indList= i; okFlag= 1;
            break
        end
    end
end
if ~okFlag
    return
end
    
% Do the work
for i= indList
    if ~strcmp(cmd{i,1}, '---');
        eval( cmd{i,2} );
    end
end

