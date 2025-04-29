function cd2file( fname )
%
% Goto folder named fname or containing the file fname

% April2019, J. Gaspar

if nargin<1
    error('** please indicate the input argument "fname" ')
end
if ~exist(fname,'dir') && ~exist(fname,'file')
    if try_ext( fname )
        return
    else
        error( ['** dirname/filename "' fname '" does not exist'] )
    end
end

show_curr_dir= @(str) disp(['** curr dir: ' pwd]);

% goto folder if fname is a dirname
if exist(fname,'dir')
    x= what(fname);
    cd( x(1).path );
    show_curr_dir(pwd)
    return
end

% goto folder containing file if fname is a filename
if exist(fname,'file')
    p= which(fname);
    %cd( strrep(p, fname, '') )
    cd( fileparts(p) )
    show_curr_dir(pwd)
    return
end


function okFlag= try_ext( fname )
okFlag= 0;

[p,f,e]= fileparts( fname );
if ~isempty(e)
    % extension was given, nothing can be done
    return
end

% try to add .m
fname2= [p,f,'.m'];
if exist( fname2, 'file' )
    okFlag= 1;
    cd2file( fname2 )
end
