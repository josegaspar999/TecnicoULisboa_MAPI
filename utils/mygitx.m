function mygitx( cmd )
%
% Help each group have GIT repositories and collaborate at home
%
% Typical usages:
% mygitx('clone')
% mygitx('pull')
% mygitx('commit')

% 1.4.2020 JG

if nargin<1
    cmd= 'pull';
end

ret= mygit_info;
for i=1:length(ret)
    mygitx_main( cmd, ret{i} );
end


function mygitx_main( cmd, ret )

% disp(ret.url)

switch cmd
    case 'test'
        % create a batch file to test the GIT is working
        % (at the same time the user stores safely username & pass)
        mygit_test_mk( ret );

    case {'ini', 'clone'}
        % after testing, cloning should go ok
        mkdir( ret.dname )
        str= ['!git clone ' ret.url ' ' ret.dname];
        eval(str)
        
    case {'pull', 'update', 'u'}
        % update local folders
        try
            cd( ret.dname )
            eval('!git pull')
            cd ..
        catch
        end
        
    case {'push', 'commit', 'co', 'c'}
        % save to the remote server
        try
            cd( ret.dname )
            eval('!git commit')
            eval('!git push')
            cd ..
        catch
        end

    otherwise
        error('inv cmd')
end


function mygit_test_mk( ret )
% git ls-remote https://xxx...
% make batch file "mygit_test_xxx.bat"

% ret = 
%     dname: 'work00'
%       url: 'https://github.com/josegaspar999/UnityPro_experiments.git'

[~,b,~]= fileparts(ret.dname);
ofname= ['mygit_test_' b '.bat'];
if exist(ofname, 'file')
    ButtonName = questdlg(sprintf('File "%s" exists, overwrite?', ofname), ...
        'overwrite', 'Yes', 'No', 'No');
    if strcmp( ButtonName, 'No' )
        fprintf(1, '** File "%s" not created.\n', ofname);
    end
end

% str= ['!echo git ls-remote ' ret.url  ' > ' ofname]; eval(str)

fid= fopen( ofname, 'wt' );
fprintf(fid, 'git ls-remote %s\n', ret.url);
fprintf(fid, 'pause\n');
fclose(fid);

return
