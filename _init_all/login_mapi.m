function ret_= login_mapi( defGrpName, pathIniOnly )
%
% Function to create and/or goto the working folder
%

% Usages:
% login_mapi
% login_mapi tmp

% login_mapi( '', 1 )

% 13.3.2013, 6.4.2016 (Matlab2015a), 20.10.2017 (Ctrl17), 1.10.2018 (Ctrl18), JG
% 02.3.2020 (handle conflict c:\windows\system32\input.dll), JG
% 10.3.2021 (pathIniOnly), JG
% 21.5.2022 (new ways to define work folder), JG
% 30.4.2025 (SVN -> GIT), JG
% 

% provide defaults for the input arguments
if nargin<1
    defGrpName= '';
end
if nargin<2
    pathIniOnly= 0;
end
if ~isempty(defGrpName) && defGrpName(1)=='-'
    % specific commands: exec and return right after
    ret_= login_commands( defGrpName(2:end), pathIniOnly );
    return
end

% ini common path
pbase= path_ini;
if pathIniOnly==1
    return
end

% check whether common data needs to be downloaded
cd0= pwd;
login_z_update
if strcmpi(cd0, 'c:\windows\system32')
    % new windows update 2020/March got a conflicting "input.dll"
    cd0= 'c:\';
end
if exist('data_download.m','file')
    cd([pbase '../zip']);
    data_download([], struct('unattended',1) )
end
cd(cd0);

% ask group name
s= ask_group_name( defGrpName );

% save group name in a global variable (save in 2 places)
global login_mapi_grp
login_mapi_grp= s;
login_opt( 'set', 'gname', s );

% show group name
sh_group(s)

% goto the working folder, pdest
% (pdest is shown here for debug; pdest \neq pbase)
pdest= goto_group_working_dir(s);
%!start .

% clear old files and
% distribute copies of necessary files
login_z_copy_files( pbase, 'login_mapi_flist' );

% make local path
if exist('login_mapi_local.m', 'file')
    eval('login_mapi_local');
end

return; % end of main function


% --------------------------- aux fn:
function ret= login_commands( op, a1 )
% usage outside: ret= login_mapi('-verify_group_name', 'a1')
% usage inside : ret= login_commands('verify_group_name', 'a1')

ret= '';
dname= 'c:\users2\mapi25\'; %24\'; %23\'; % working folder

switch op
    case 'show_opt'
        % usage: login_mapi('-show_opt')
        login_opt('show')
    case 'show_diskmem'
        % usage: login_mapi('-show_diskmem')
        diskmem('show')
        
    case 'group_name'
        % usage: login_mapi('-group_name')
        if ~login_opt( 'isopt', 'gname' )
            ret= '';
            warning('Group name undefined. Please run login_mapi')
        else
            ret= login_opt( 'get', 'gname' );
        end
        
    case 'set_group_name'
        login_opt('set', 'gname', a1);
        
    case 'verify_group_name'
        % check the group name conforms to expected standard
        % ( uses function verify_group_name() )
        ret= 0;
        if  ~isempty(a1) && ~strcmpi(a1, 'tmp') ...
                && ~isempty( verify_group_name(a1) )
            ret= 1;
        end
        
    case 'group_pass'
        if ~login_opt( 'isopt', 'gpass' )
            ret= '';
            warning('Group pass undefined.')
        else
            ret= login_opt( 'get', 'gpass' );
        end
    case 'set_group_pass'
        login_opt('set', 'gpass', a1);
        
    case 'working_folder'
        % usage: login_mapi('-working_folder')
        [pname, okFlag]= diskmem('get', 'work_full_path');
        if okFlag
            % use info saved in disk
            ret= pname;
        elseif login_opt('isopt', 'work_full_path') ...
                && ~isempty(login_opt('get', 'work_full_path'))
            % use a specific working folder saved in RAM
            ret= login_opt('get', 'work_full_path');
        else
            % use default, full path, folder
            % without group: login_mapi('-working_folder')
            % to add the group: login_mapi('-working_folder', 'A1')
            ret= [dname a1];
        end
        
    case 'set_working_folder'
        % set a specific working folder for a group (future use a GUI?)
        diskmem('set', 'work_full_path', a1);

    case 'set_working_folder2'
        % set a specific working folder for a group
        % (running/temporary usage, nothing written to file)
        login_opt('set', 'work_full_path', a1);
    
    case 'reset_working_folder'
        % reset a specific working folder for a group
        login_opt('set', 'work_full_path', '');
        

    case 'set_zip_folder'
        diskmem('set', 'zip_full_path', a1);
    case 'zip_folder'
        % usage: login_mapi('-zip_folder')
        [pname, okFlag]= diskmem('get', 'zip_full_path');
        if okFlag
            % use info saved in disk
            ret= pname;
        else
            warning('zip folder is NOT set')
            ret= '';
        end
        
    case 'set_7zip_exe'
        diskmem('set', 's7zip', a1);
    case '7zip_exe'
        % usage: login_mapi('-7zip_exe')
        [pname, okFlag]= diskmem('get', 's7zip');
        if okFlag
            % use info saved in disk
            ret= pname;
        else
            warning('zip folder is NOT set')
            ret= '';
        end

end
return


% --------------------------- aux fn:
function ret= login_opt( op, a1, a2 )
global LOPT
switch op
    case 'isopt'
        ret= isfield(LOPT, a1);
    case 'get'
        ret= LOPT.(a1);
        if nargin>2
            warning('too many arguments')
        end
    case 'set'
        LOPT.(a1)= a2;
    case 'show'
        % login_opt('show')
        fprintf(1, 'v-- login options:\n');
        disp(LOPT)
        fprintf(1, '^-- options end.\n\n');
    otherwise
        error('inv op %s', op)
end


% --------------------------- aux fn:
function [ret, okFlag]= diskmem(op, a1, a2)

% manage data in a .mat file
% apply as mapi_diskmem ? or do a class?

% fname= get_mat_full_filename()

switch op
    case 'show'
        fname= get_mat_full_filename();
        load(fname, 'DM')
        DM
        
    case 'exist'
        ret= hdd_exist_var( a1 ); % a1= vname
    case 'get'
        [ret, okFlag]= hdd_read_var( a1 ); % a1= vname
    case 'set'
        hdd_write_var( a1, a2); % a1,a2= vname,vvalue

    otherwise
        error('inv op "%s"', op)
end


function fname= get_mat_full_filename()
% rootfunction= 'diskmem.m'; % change this if placed in another function
rootfunction= 'login_mapi.m'; % change this if placed in another function

% [pname,fname,~]= fileparts( which( rootfunction ) );
% fname= [pname filesep fname '.mat'];

% replace fname
[pname,~,~]= fileparts( which( rootfunction ) );
fname= [pname filesep 'login_mapi_data.mat'];
return


function hdd_write_var( vname, vvalue )
% make file if none exist
fname= get_mat_full_filename();
if ~exist( fname, 'file')
    DM= struct( vname, vvalue );
else
    load(fname, 'DM');
    DM.(vname)= vvalue;
end
save( fname, 'DM' );
return


function [ret, okFlag]= hdd_read_var( vname )
fname= get_mat_full_filename();

% check .mat exists
ret= '';
okFlag= 0;
if ~exist( fname, 'file')
    return
end

% return value if possible
load( fname, 'DM' );
if isfield(DM, vname)
    ret= DM.(vname);
    okFlag= 1;
end


function okFlag= hdd_exist_var( vname )
fname= get_mat_full_filename();
if ~exist( fname, 'file')
    okFlag= 0;
else
    load( fname, 'DM');
    okFlag= isfield(DM, vname);
end
return


% --------------------------- aux fn:
% function zip_working_folder()
% % 1st time: ask password and ask to confirm it, or make myself the pass?
% % (warn that password cannot be forgotten)
% % get zip folder using login_z_info()
% % check group name, check password
% % incremental zip using 7zip
% return
% ^^^^ this function moved into gdrive_mapi.m


% --------------------------- aux fn:
%
function [defGrpName, ask_HW_or_SW]= parse_arg( arg1 )
defGrpName= '';
ask_HW_or_SW= 0;

if isempty(arg1)
    return;
end

if ischar( arg1 )
    defGrpName= arg1;
end


% --------------------------- aux fn:
%
function login_grp = ask_group_name( pathIniOnly )
if isnumeric(pathIniOnly) && (pathIniOnly==-1)
    %   add path but do not change current folder
    path_ini;
    login_grp= '';
    return;
end

% pergunta e verifica nome de grupo
%
s= [];
if ischar(pathIniOnly)
    s= pathIniOnly;
end

while isempty(s)
    s= input('-- Your group? [return shows a list] ', 's');
    if isempty(s),
        helpwin('login_mapi_grupos')
    else
        s= verify_group_name(s);
    end
    fprintf(1,'\n')
end

login_grp= s;


% --------------------------- aux fn:
%
function p= path_ini %(ask_HW_or_SW)
%
%  Junta ao path actual subdirectorias necessarias
%

% set a base path into var p
% p= which('login_mapi'); p= strrep(lower(p), 'login_mapi.m', '');
[ST,~]= dbstack;
[p,~,~]= fileparts( which(ST(1).file) );
if ~ismember( p(end), '/\' )
    p= [p filesep];
end

% enforce mapi_login.m is in the path
% - folder containing mapi_login.m is added to path if it wasn't there yet
% - one can go into the folder of mapi_login.m and run it without install
cd0= cd; cd(filesep);
if isempty( which(ST(1).file) )
    path(path, p);
end
cd(cd0);

% if nargin<1, ask_HW_or_SW=0; end
% s= 'H'; if ask_HW_or_SW, s= input('-- dt2811 Simulated or real HW driver [sH]? ','s'); end
% if strncmp(s,'H',1), p2= 'dt2811\HW'; else p2= 'dt2811\SW'; end
% path(path, [p p2]);

% >> IMPORTANT: match this fn with "login_mapi_flist.m" <<

% general utils
if 1
    path(path, [p '..\utils']);
end

% lab1 utils:
if 1
    path(path, [p '..\tmp\terminal']);
end

% lab2 utils:
if 1
    % simply F9 these lines for a local path setting
    path(path, [p '..\tmp\PN_editor_MATLAB_sim_and_Manual\tpn5']);
    path(path, [p '..\tmp\pn_to_plc\pn_to_plc_compiler']);
    % path(path, [p '..\tmp\pn_to_plc\tst1_blink_turn_on_off']);
    path(path, [p '..\tmp\pn_to_plc\tst3_blink_turn_on_off']);
    path(path, [p '..\tmp\spnbox']);
    path(path, [p '..\tmp\PN_sim2']);
    path(path, [p '..\tmp\mem_dump_show']);
end

% for general use in the lab:
path(path, [p '..\zip']);


% --------------------------- aux fn:
%
function pdest= goto_group_working_dir( group )
%
% muda para a directoria indicada pelo nome do grupo
%
% group: str

% b= 'c:\'; d= 'users2';
% if ~exist([b d], 'dir'), mkdir(b,d); end
% b= [b d '\']; d= 'mapi21';
% if ~exist([b d], 'dir'), mkdir(b,d); end
% b= [b d '\']; d= group;
% if ~exist([b d], 'dir'), mkdir(b,d); end
% pdest= [b d];

% dname= 'c:\users2\mapi21\'; pdest= [dname group];
pdest= login_commands( 'working_folder', group );
if ~exist(pdest, 'dir')
    mkdir( pdest );
end

cd(pdest);
fprintf(1, '-- Current working directory: %s\n', pwd);

return


% --------------------------- aux fn:
%
function s2= verify_group_name(s0)
%
% verify that s has the struct yz with
%  y in a..d
%  z in 1..8
% string 'tmp' is also valid
%
% s0: str : group name assumed to be in the DB
% s2: str : s2=s0 if s0 is in DB, otherwise s2=[]

s= upper(s0);
if strncmpi(s,'TMP',3), s2='tmp'; return; end;

s2= [];

if length(s)~=2,
    disp(['** Invalid group name: ' s])
    disp(['   Example "A7"'])
end
if s(1)<'A' || 'C' < s(1),
    disp(['** Invalid group name: ' s])
    disp( '   1st character must be "a" .. "c".')
    return;
end
if s(2)<'1' || '8'<s(2),
    disp(['** Invalid group name: ' s])
    disp( '   2nd character must be 1..8')
    return;
end

s2= s;


% --------------------------- aux fn:
%
function sh_group(str)
%
% find and display group "str"
%
fid=fopen('login_mapi_grupos.m','rt');
if fid<1
    error('file open failed')
end
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    if ~isempty(findstr(upper(tline),upper(str))),
        s0= [' --- ' tline(2:end)];
        fprintf(1,'\n%s\n', get_group(fid, s0));
        fclose(fid);
        fprintf(1,' ---  if incorrect group, then please repeat login (>> login_mapi)\n\n');
        return; % successful return
    end
end
fprintf(1, '\n  *** Group "%s" does not exist in the list of groups. Repeat login >> login_mapi\n\n', str);
fclose(fid);


function str= get_group(fid, s0)
%
str=s0;
while 1
%for i=1:3,
    tline = fgetl(fid);
    %if ~ischar(tline), break, end
    if EOF_or_empty_line(tline), break, end
    str= sprintf('%s\n\t\t%s', str, tline(2:end));
end


function emptyFlag= EOF_or_empty_line( tline )
emptyFlag= 0;
if ~ischar(tline)
    emptyFlag= 1;
    return
end
tline= strrep( tline, ' ', '');
tline= strrep( tline, '%', '');
ind= find( tline==10 | tline==13 );
tline(ind)= [];
if isempty(tline)
    emptyFlag= 1;
end
return


% --------------------------- aux fn:

function login_z_delete_files( pbase, pdest, cmdGetFilelist )
if exist( cmdGetFilelist )

    % goto base path to get the filelist
    cd0= cd;
    cd( pbase );
    [~, flist2]= eval( cmdGetFilelist );

    % go back home and get files
    cd( cd0 );
    for i=1:length(flist2)
        my_delete( pdest, flist2{i} );
    end
end

return


function my_delete( pdest, info )
if ~isfield(info, 'xtree')
    warning('only implemented xtree case')
    return
end
y= xtree([pdest info.xtree], struct('ret_list','', 'get_files',''));
for i=1:size(y,1)
    % filename matched?
    f0= strrep(y{i},'\','/'); ind= find(f0=='/');
    f1= f0;
    if ~isempty(ind)
        f1= f0(ind(end)+1:end);
    end
    if strcmp(f1, info.fname) && crc32(fileread(f0))==info.CRC
        f0= strrep(f0, '/',filesep);
        str= ['!del "' f0 '"'];
        eval(str)
    end
end
return


function login_z_copy_files( pbase, cmdGetFilelist )
%
% Create a copy of the files to use
%   Copy files to the current folder
%   assuming the files are in the path

if ~exist( cmdGetFilelist )
    % invalid input? just return
    return
end

% goto base path to get the filelist
cd0= cd;
cd( pbase );
flist= eval( cmdGetFilelist );

% go back home and get files
cd( cd0 );
mycopy_files( flist );

return


function mycopy_files( filesList )
% copy files in the path to the current folder
for i= 1:length(filesList)
    fname= char(filesList{i});
    fname1= which_not_here(fname);
    if isempty(fname1)
        warning(['Source file "' fname '" not found'])
        continue
    end
    fname2= ['.\' fname];
    if ~exist(fname2, 'file') || fname1_is_newer( fname1, fname2 )
        % copy only if not available in the current folder
        str= ['!copy "' fname1 '"'];
        disp(str);
        eval( str );
    end
end


function ret= which_not_here( fname )
% find file excluding current working directory
ret= []; % not found
p= pwd;
f= which(fname,'-all');
for i= 1:length(f)
    if ~strcmp( fname, strrep(f{i},[p filesep],'') )
        ret= f{i};
        return
    end
end


function ret= fname1_is_newer( fname1, fname2 )
d1= dir(fname1);
d2= dir(fname2);
ret= (d1.datenum > d2.datenum);
