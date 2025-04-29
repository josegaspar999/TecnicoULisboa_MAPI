function file_put_in_path(fname)
%
% Check if file 'fname' is in the path. If not, check local info or ask the
% user to provide the path to 'fname'.

% Nov2013, JG

if nargin<1, fname='rdp.m'; end
if exist(fname, 'file')
    % already in path, do nothing!
    return
end
try
    file_put_in_path_main(fname)
catch
    disp('Warning: Something went wrong. Trying to continue.');
end
return; % end of main function


function file_put_in_path_main(fname)

% file not in path, try to see if the path is saved in an aux file

fname2= which('file_put_in_path.m');
fname2= [fname2(1:end-2) '_info.m'];
if exist(fname2, 'file')
    try
        p= file_put_in_path_info;
        path(path, p);
    catch
        disp('Warning: failed to run file_put_in_path_info.m');
    end
end

% problem solved?

if exist(fname, 'file')
    return
end

% problem not solved, ask user to tell where is the file

s= questdlg(['File "' fname '" not found. Can you give its path?'], ...
    'File not found', 'Yes','No','Yes');
if strcmp(s, 'No'), return; end

[fname3, pname] = uigetfile(fname);
if isnumeric(fname3) && fname3==0
    disp('Warning: user did not tell the path to the file');
    return
end

% user did tell the path to 'fname', use that info and try to save it

path(path, pname);

fid= fopen(fname2, 'wt');
if fid<1
    disp('Warning: failed to open a file to save the path');
    return
end
fprintf(fid, 'function p= file_put_in_path_info\n');
fprintf(fid, ['p= ''' strrep(pname,'\','\\') ''';\n']);
fclose(fid);

disp('// Created file: file_put_in_path_info.m //')
