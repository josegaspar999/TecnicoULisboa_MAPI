function get_files( filesId, options )
%
% Given one identifier, "filesId", download and unzip a zip file
% Check that current dir is under a desired ref

% May 2023, J. Gaspar

if nargin<2
    options= [];
end

% root folder to verify we are in a sub-branch
dname= fullfile('c:','users2');

% which zip file to get
switch filesId
    case 'empty'
        % usage: get_files empty
        % usage: get_files('empty', struct('verifCurrDir',0) )
        url= 'http://users.isr.ist.utl.pt/~jag/course_utils/UnityPro/empty.zip';
        ofname= './empty.zip';

    case 'logger'
        % usage: get_files logger
        % usage: get_files('logger', struct('verifCurrDir',0) )
        url= 'http://users.isr.ist.utl.pt/~jag/course_utils/plc_log/data_log_up13.zip';
        ofname= './data_log_up13.zip';

    case 'timers'
        % usage: get_files timers
        % usage: get_files('timers', struct('verifCurrDir',0) )
        url= 'http://users.isr.ist.utl.pt/~jag/course_utils/UnityPro/timers_LD_ST.zip';
        ofname= './timers_LD_ST.zip';
        
    case {3, 'mix_io_and_show_strings'}
        % usage: get_files mix_io_and_show_strings
        % usage: get_files(3, struct('verifCurrDir',0) )
        url= 'http://users.isr.ist.utl.pt/~jag/course_utils/plc_log/mix_io_show_strings.zip';
        ofname= './mix_io_show_strings.zip';
        
    case 'blink_on_off_and_pause'
        % usage: get_files blink_on_off_and_pause
        % usage: get_files('blink_on_off_and_pause', struct('verifCurrDir',0) )
        url= 'http://users.isr.ist.utl.pt/~jag/course_utils/UnityPro/blink_on_off_and_pause.zip';
        ofname= './blink_on_off_and_pause.zip';

    otherwise
        error('inv filesId "%s"', filesId)
end

% finally get and uncompress the zip file
verif_cd_and_get_files( dname, url, ofname, options );

return % end of main function


function verif_cd_and_get_files( dname, url, ofname, options )
% force usage of working directory
verifCurrDir= 1;
if isfield(options, 'verifCurrDir')
    verifCurrDir= options.verifCurrDir;
end

% verify current folder
if verifCurrDir && ~strncmpi( dname, cd, length(dname) )
    error( 'Current directory is not under "%s". Please run "login_mapi"', dname )
end

% make sure the download is desired
qstr= sprintf('Download and unzip "%s"?', ofname);
button= questdlg(qstr, 'download', 'Yes','No','No');
if strcmp(button,'No')
    warning('Canceled download of "%s"', ofname)
    return
end

% download and unzip
data_download_urlwrite2( url, ofname );
unzip(ofname);
