function login_z_install( methodId )
%
% Put into the matlab path the folder containing login_z_install.m
%
% Runing this once allows other scripts/functions in the same folder to
% run whenever called in future Matlab sessions.

% TODO: create login_z_data.m returning a structure with relevant data

% 2015.03.12, March2017 (file renamed), Oct2019 (startup.m), J.Gaspar
% 2025.05 (disable install), J. Gaspar

% define setpath method
if nargin<1
    methodId= [];
end

% define what should be in the path:
fname= 'login_z_install.m';
%p= which(fname); p= strrep(p, fname, ''); p= p(1:end-1);
p= fileparts(which(fname));

% install to work in the next session:
ret= mysavepath( p, methodId );
switch ret
    case 0, fprintf(1, '-- Nothing to do.\n');
    case 1, fprintf(1, '-- Modified "matlabrc.m".\n');
    case 2, fprintf(1, '-- Path saved.\n');
    case 3, fprintf(1, '-- Modified "startup.m".\n');
    otherwise, error('invalid result')
end

return; % end of main function


% ------------------------------------
function ret= mycnf(op, a1, a2)
global MIDP;
if isempty(MIDP)
    MIDP= struct('install_flag', 1, 'just_add_path', 0);
end

switch op
    case 'set', MIDP.(a1)= a2;

    case 'get'
        if ~isfield(MIDP, a1)
            ret= [];
        else
            ret= MIDP.(a1);
        end
        
    otherwise
        error('inv op "%s"', op);
end


function ret= mysavepath( p, methodId )
ret= 0;

if isempty(methodId)
    methodId= 2;
end

if methodId < 0
    % special cases, work on them
    switch methodId
        case -1, mycnf('set', 'install_flag', 0);
            fprintf(1, '** install flag set to 0 (NO install)\n');
        case -2, mycnf('set', 'install_flag', 1);
            fprintf(1, '** install flag set to 1 (TRUE)\n');
    end
    return
end
if ~mycnf('get', 'install_flag')
    % if no install flag, then do nothing
    return
end

switch methodId
    case 0
        %
        % [OLD ver] put p into matlabrc, if not there yet :
        %
        str= ['path(path,''' p ''');'];
        fname= which('matlabrc.m');
        if ~str_in_file(fname, str)
            file_append_str(fname, str);
            ret= 1;
        end
        
    case 1
        %
        % [new ver] ask Matlab to handle the Microsoft Windows VirtualStore
        %
        if isempty(strfind(path,p))
            path(path, p);
            savepath
            ret= 2;
        end
        
    case 2
        %
        % [newer ver] put p into startup.m, if not there yet :
        %
        str= ['path(path,''' p ''');'];
        fname= strrep(userpath, ';', ''); % old Matlab returns ";" at end 
        fname= [fname filesep 'startup.m'];
        if ~str_in_file(fname, str)
            file_append_str(fname, str);
            ret= 3;
        end
        
end


% ------------------------------------
function flag= str_in_file(fname, str)
% To use in the future: check startup.m has the right path
flag= 0;
fid=fopen(fname);
if fid<1
    return
end
while 1
    tline = fgetl(fid);
    if ~ischar(tline),   break,   end
    if strcmp(tline, str)
        flag=1; break;
    end
end
fclose(fid);


% ------------------------------------
function file_append_str(fname, str)
% fname : string : output filename
fid= fopen(fname, 'at');
if fid<1
    msg= {'Failed opening of:'; fname};
    msgbox(msg);
    return
end
fprintf(fid, '%s\n', str);
fclose(fid);
