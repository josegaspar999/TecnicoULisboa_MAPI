function y= xtree(inipath, options)
%
% Augmented dir command
%    gets all files under sub-dirs (complete tree + files);
%    completes all filenames
%    removes '.' and '..' filenames
%
% function y= xtree(ini, options)
% usage examples:
%   xtree
%   xtree('..')
%   y= xtree('*.*', struct('ret_list','')); % only one folder because *.*
%   y= xtree('.', struct('ret_list',''));   % recursive dir input
%   y= xtree('.', struct('ret_list','', 'get_dirs',''))
%   y= xtree('.', struct('ret_list','', 'get_files',''))
%   y= xtree('c:\tmp', struct('sort','d'))  % sort output by date
%
% options:
% 'sh'         display detailed data for each file [no display if nargout>0]
% 'shmin'      display just file or directory names
% 'nodir'      do not display directories [false]
% 'sort'       sort filenames 'd'=date 's'=size 'n'=name [no sort]
% 'ret_list'   returns list { [pname fname]; ...} (NOT array of structs)
% 'ret_list2'  returns list {pname, fname; ...} instead of struct array
% 'get_dirs'   get just names of directories
% 'get_files'  get just names of files (with path)
% 'select_ext' return only the desired extension; case insensitive;
% 'ignoreMACOSX' ignore filenames containing the string "__MACOSX"
%

% 17-11-05, 19.12.06 (options), 19.7.07 (cmts++), 21.6.10 (select ext), JGaspar
% 14.1.13 (ret_list2), J. Gaspar


if nargin<2,
    options= [];
end
if nargin<1,
    inipath= '.';
end


% *** Compute the tree of directories and/or files
%
if isfield(options, 'get_dirs_onelevel')
    % get just directories at the top level
    y= xtree2(0,inipath);
elseif isfield(options, 'get_dirs')
    % get just directories
    y= xtree2(1,inipath);
elseif isfield(options, 'get_files')
    % get just files (no dirs; full path in name)
    y= xtree2(2,inipath);
else
    % get directories and files
    y= xtree2(3, inipath);
end

% *** Select files
%
if isfield(options, 'select_ext')
    y= select_ext(y, options.select_ext);
end
if isfield(options, 'ignoreMACOSX')
    y= remove_MACOSX(y);
end
    
% *** Sort the list if required
%
if isfield(options, 'sort')
    y= sort_xtree(y, options.sort);
end


% *** Return or Display results
%
if isfield(options, 'ret_list')
    %y= mk_list(y, options);
    y= {y(:).name}';

elseif isfield(options, 'ret_list2')
    y= split_dname_fname(y);
    
elseif nargout<1 || isfield(options,'sh'),
    %disp('-- ret to show filenames...'); pause
    for i=1:length(y),
        c= '.';
        if y(i).isdir,
            c= 'd';
            if isfield(options, 'nodir'), continue; end
        end
        if isfield(options, 'shmin')
            fprintf(1,'%s\n', y(i).name);
        else
            fprintf(1,'%c %s %04d[Kb] %s\n', c, y(i).date, round(y(i).bytes/1024), y(i).name);
        end
    end
end

return % end of main function


% -----------------------------------------------------------------------
function y= select_ext(x, ext)

if isempty(ext)
    y= x;
    return
end

if ext(1)~='.'
    ext= ['.' ext];
end

y= x([]);
for i=1:length(x)
    fname= x(i).name;
    ind= find(fname=='.');
    if isempty(ind)
        continue;
    end
    ind= ind(end);
    if strcmpi(fname(ind:end), ext)
        y(end+1,1)= x(i);
    end
end
return


function y= remove_MACOSX(x)
y= x([]);
for i=1:length(x)
    fname= x(i).name;
    if isempty( strfind( fname, '__MACOSX' ) )
        y(end+1,1)= x(i);
    end
end
return


function y2= mk_list(y, options)
% create a list with all filenames (no dirs)
y2= {};
for i=1:length(y)
    if ~y(i).isdir, y2{end+1}= y(i).name; end
end
return


function y2= sort_xtree(y, ordFlag)
switch ordFlag
    case 'd' % date
        d= datenum({y.date});
        [tmp,ind]= sort(d);
        y2= y(ind);
    case 's' % size
        [tmp,ind]= sort([y.bytes]);
        y2= y(ind);
    case 'n' % name
        [tmp,ind]= sort({y.name});
        y2= y(ind);
    otherwise
        y2= y;
end


function y= xtree2(mode, str, x)
%
% Startup: make y empty (initialize it) or accumulate with x
%   while behaving as a recursive function
%

% allow list of paths to start the search
%
if iscell(str)
    if nargin<3
        y= dir(''); % get empty struct
    else
        y= x;
    end
    for i= 1:length(str)
        y= xtree2(mode, str{i}, y);
    end
    return
end

% get all files
%
d= dir(str);
if nargin<3, y= d([]); else y= x; end

% crop bpath string at / just before * or ?
%
bpath= strrep(str, '\','/');
ind= [strfind(bpath, '*') strfind(bpath, '?')];
if ~isempty(ind)
    ind2= strfind(bpath, '/');
    % we want max(ind2) < min(ind)
    ind2= ind2(find(ind2 < min(ind)));
    ind2= max(ind2);
    bpath= bpath(1:ind2-1);
end

% for each sub-dir, get the files under it
%
for i=1:length(d),

    % get one file struct
    file= d(i);

    % remove '.', '..'
    if strcmp(file.name,'.') || strcmp(file.name,'..'),
        continue
    end
    
    % complete the filename
    file.name= strrep([bpath '/' file.name], '\', '/');

    % save all files & dirs
    if mode==3 || (mode==2 && ~d(i).isdir) || (mode<=1 && d(i).isdir)
        y(end+1,1)= file;
    end
    
    % browse sub-dirs for more files (recurse only for mode>0)
    if mode>=1 && d(i).isdir,
        y= xtree2(mode, file.name, y);
    end
end


function y= split_dname_fname(x)
y= {};
for i=1:length(x)
    f= x(i).name;
    ind= strfind(f, '/');
    if isempty(ind)
        y{end+1,1}= f; y{end,2}= '';
    else
        y{end+1,1}= f(1:ind(end)); y{end,2}= f(ind(end)+1:end);
    end
end
