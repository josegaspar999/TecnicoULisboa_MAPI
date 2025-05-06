function pn_editor
%
% Call the Petri nets editor

% April2021, June2023 (find path), JG

% save current working dir
cd0= cd;

% goto the folder containing Pipe.class
%  f= 'pn_editor.m'; p= which(f); p= strrep(p, f, '');
p= [fileparts( which(mfilename) ) filesep];
p1= [p '../zip'];
p2= [p '../zip/PIPEv4.3.0/Pipe'];

% check required software (Java + PIPE2) is installed
options= struct('zipFolder', p1, 'pathToPipe2', p2);
check_software_exists( options );

% goto PIPE2 directory
% call the PN editor hiding the command line window associated to Java
% go back to the original working dir
cd(p2);
classPath= ['-cp .;./lib/jpowergraph-0.2-common.jar;./lib/jpowergraph-0.2-swing.jar;' ...
    './lib/powerswing-0.3.jar;./lib/drmaa.jar;./lib/hadoop-0.13.1-dev-core.jar;' ...
    './lib/jcommon-1.0.10.jar;./lib/jfreechart-1.0.6.jar;' ...
    './lib/jfreechart-1.0.6-swt.jar;./lib/tools.jar'];
cmdStr= ['!start /MIN java ' classPath ' Pipe'];
eval(cmdStr)
cd(cd0);

return; % end of main function


function check_software_exists( options )
% stopOnError= fieldvalue(options, 'stopOnError', 0);
% dbLevel= fieldvalue(options, 'dbLevel', 0);

% is Java installed?
if fieldvalue(options, 'testJava', 1)
    [~, cmdout]= system('java');
    if isempty(strfind(cmdout, 'Usage: java'))
        warning( ['Java not installed? ', ...
            'If not installed, please install ', ...
            'and restart Matlab.'] );
    end
end

% is PIPE2 installed?
pathToPipe2= fieldvalue(options, 'pathToPipe2', '');
if ~isempty(pathToPipe2)
    pathToPipe2= fname_correct( pathToPipe2 );
    if ~exist(pathToPipe2, 'dir')
        warning('Pipe2 seems to be not installed');
        s1= ['cd("' fname_correct(options.zipFolder) '")'];
        s1= [s1 '; data_download_info("add_pipe2"); data_download'];
        s1= strrep(s1,'"','''');
        fprintf(1, '-- Suggestion, try the following:\n\n');
        disp(s1)
        fprintf(1, '\n');
    end
end

return; % end of function


function value = fieldvalue(mystruct, fieldname, default)
if isfield(mystruct, fieldname)
    value = getfield(mystruct, fieldname);
else
    value = default;
end


function fname= fname_correct( fname )
fname= strrep(fname, '/', '\');
fname= strrep(fname, '\', filesep);
