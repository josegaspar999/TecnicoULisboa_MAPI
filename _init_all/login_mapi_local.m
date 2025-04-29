function login_mapi_local( op )
%
% A login to run locally by each group

% 2017, 2019, JG

global login_mapi_grp
if isempty(login_mapi_grp)
    %warning('login not done; please run >> login_mapi')
    %return
    login_mapi
end

if nargin<1
    op= 'ini'; %'add_path';
end

switch op
    case 'ini'
        login_mapi_local('add_subdirs')
        login_mapi_local('goto_subdir_given_date')
        !start .
        
    case {'add_path', 'add_subdirs'}
        verif_all_files_exist
        %path( path, [pwd '/PN_editor_MATLAB_sim_and_Manual/tpn5'] )
        %path( path, [pwd '/pn_to_plc/pn_to_plc_compiler'] )
        %path( path, [pwd '/spnbox'] )

    case {'install', 'uncompress', 'unzip'}
        % unzip all
        uncompress_all( '.', struct('no_rename',1) )
        
    case 'goto_subdir_given_date'
        goto_subdir_given_date()

    otherwise
        error('inv op')
end

return; % end of main function


function verif_all_files_exist

[~, filesList]= login_mapi_flist;

if ~files_exist_check( {filesList{:,1}} )
    msgbox('Missing one or more files. Please warn the professor.')
end

if ~files_uncompressed( filesList )
    login_mapi_local('install')
end


function retFlag= files_exist_check( filesList )
% verif files exist in the current folder
retFlag= 1;
for i= 1:length(filesList)
    fname= char(filesList{i});
    if ~exist(['.\' fname], 'file')
        retFlag= 0;
        break;
    end
end


function retFlag= files_uncompressed( filesList )
% verif files are uncompressed in the current folder
retFlag= 1;
for i= 1:size(filesList,1)
    fname= char(filesList{i,1});
    dname= char(filesList{i,2});
    if isempty( strfind(upper(fname),'.ZIP') )
        continue;
    end
    if ~exist(['.\' dname], 'dir')
        retFlag= 0;
        break;
    end
end


function goto_subdir_given_date()
% if now > datenum( 2022, 05, 31, 00, 00, 00 )
%     cd('lab2a')
% else

% if now > datenum( 2022, 06, 13, 00, 00, 00 )
%     cd('lab2b/intro')
% elseif now > datenum( 2022, 05, 25, 00, 00, 00 )
%     cd('lab1a')
% elseif now > datenum( 2022, 05, 21, 00, 00, 00 )
%     cd('lab02')
% elseif now > datenum( 2022, 05, 19, 00, 00, 00 )
%     cd('lab01')
% elseif now > datenum( 2022, 05, 11, 00, 00, 00 )
%     cd('lab00')
% end

if now > datenum( 2023, 8, 1, 00, 00, 00 )
    % an end date to avoid going further than current period
    return
elseif now > datenum( 2023, 06, 25, 00, 00, 00 )
    cd('train2_PN_to_PLC')
elseif now > datenum( 2023, 06, 20, 00, 00, 00 )
    cd('train1_PN_sim')
elseif now > datenum( 2023, 05, 29, 00, 00, 00 )
    cd('lab2')
elseif now > datenum( 2023, 05, 15, 00, 00, 00 )
    cd('lab1')
elseif now > datenum( 2023, 05, 04, 00, 00, 00 )
    cd('lab00')
end
