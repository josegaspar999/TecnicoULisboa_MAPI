function data_download_urlwrite2( url, ofname )
% Download from an URL using curl.exe
% Handle Dropbox responses changing urls

% Jul2022, Oct2022 (Dropbox ans changed), J. Gaspar

% future:
% handle GDrive and/or OneDrive
% handle passwords as in omni (use data_download_urlwrite.m ?)

data_curl_zip( url, ofname );

return; % end of main function


function data_curl_zip( url, ofname, nTries )
% main function, recursive with nTries
if nargin<3
    nTries= 5;
end
nTries= nTries-1;
if nTries==0
    error('reached nTries==0');
end

% already have the zip file, do not donwload it again
if check_zip_file( url, ofname )
    warning('zip file "%s" exists and is a zip file', ofname );
    return
end

% file still to download, or re-download if it was not a zip file
[p,f,e]= fileparts( ofname );
str= ['curl --output "' f e '" --ssl-no-revoke --url ' url];
cd0= cd; cd(p)
try
    %[status, cmdout]= system(str);
    [~, ~]= system(str);
catch
end
cd(cd0);
% status, cmdout

% check the file to see if it is a zip
[zipFileFlag, url2]= check_zip_file( url, ofname );
if ~zipFileFlag
    % recursive calling to try again changing to a new (given) url...
    fprintf(1, 'New URL: %s\n', url2);
    data_curl_zip( url2, ofname, nTries );
end
return


function [zipFileFlag, url2]= check_zip_file( url, ofname )
% first two letters of ofname are PK

zipFileFlag= 0;
if ~exist(ofname, 'file')
    url2= url;
    return
end

% check it is a zip file, return true if so
fid= fopen(ofname, 'rb');
x= char( fread(fid, 2, 'uint8')' );
fclose(fid);
if strcmp( x, 'PK' )
    zipFileFlag= 1;
    url2= '';
    return
end

% failed the check of zip file, try to get url2
if ~isempty( strfind( url, 'dropbox' ) )
    url2= get_url2_dropbox( url, ofname );
else
    % future: more cases as e.g. GDrive or OneDrive
    error('do not know how to parse "%s"', ofname)
end

return


function str= text_between( x, s1, s2 )
str= '';
i1= strfind( x, s1 );
if ~isempty(i1)
    i2= strfind(x(i1(1):end), s2);
end
if ~isempty(i1) && ~isempty(i2)
    str= x( i1(1)+length(s1):i1(1)+i2(1)-2 );
end
return


function url2= get_url2_dropbox( url, ofname )
fid= fopen(ofname, 'rb');
x= char( fread(fid, inf, 'uint8')' );
fclose(fid);

% check x contains "has been moved to "
str= text_between( x, 'has been moved to ', ';' );
if ~isempty(str)
    s1= 'https://www.dropbox.com';
    if strncmp( url, s1, length(s1) )
        url2= [s1 str];
        return
    else
        error('not a dropbox url "%s"', url);
    end
end

% check x contains "fount at "
str= text_between( x, 'The resource was found at ', ';' );
if ~isempty(str)
    url2= str;

    temp= 'https://';
    if strncmp(url2, temp, length(temp))
        % is a full url, can return
        return
    end
    
    % did not bring a full url, try a standard completion...
    temp= 'https://www.dropbox.com';
    if ~strncmp(url2, temp, length(temp))
        url2= [temp url2 '?dl=1'];
    end
    
    return
end

% bad news, there are more levels to parse...
warning('failed to get dropbox file address')
return
