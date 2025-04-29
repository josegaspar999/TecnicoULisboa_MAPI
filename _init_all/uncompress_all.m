function uncompress_all( dname, options )
% 2017, 2021 (overwrite flag), JG

if nargin<1
    dname= '.';
end
if nargin<1
    options= [];
end

% for a folder dname find all files (and decompress zip / rar files)

y= xtree(dname, struct('ret_list','', 'get_files',''));
for i=1:length(y)
    uncompress_file( y{i}, options );
end

return


function [dname, fname]= split_dname_fname(f)
ind= strfind(f, '/');
if isempty(ind)
    dname= f; fname= '';
else
    dname= f(1:ind(end)); fname= f(ind(end)+1:end);
end


function uncompress_file( f, options )

% if too short file, cannot be .zip nor .rar, then do nothing
if length(f)<4
    return
end

% if wrong file extension, then do nothing
[dname, fname]= split_dname_fname(f);
[~, fnameNoExt, ext]= fileparts(fname);
if ~ismember(upper(ext), {'.ZIP','.RAR','.7Z'})
    return
end

% do not overwrite ZIP folder previously (partially) uncompressed
if ~isfield(options, 'overwrite') || options.overwrite==0
    if exist([dname fnameNoExt], 'dir')
        % fast rule out, dirname equal zip filename
        fprintf(1, '** do nothing: %s\n', f);
        return
    elseif strcmpi(ext, '.ZIP')
        % not so fast rule out, see all files
        filelist = zip_contents(f);
        for i= 1:length(filelist)
            if exist([dname filelist{i}], 'file')
                fprintf(1, '** do nothing, found: %s\n', [dname filelist{i}]);
                return
            end
        end
    end
end

% if fname ends .zip or .rar then uncompress it
if strcmpi(f(end-3:end), '.ZIP')
    fprintf(1, '-- work: %s\n', f);
    unzip(f, dname)
    isArchive= 1;
elseif strcmpi(f(end-3:end), '.RAR')
    fprintf(1, '-- work: %s\n', f);
    str= ['!unrar x "' f '" "' dname '"'];
    eval(str)
    isArchive= 1;
elseif strcmpi(f(end-2:end), '.7Z')
    fprintf(1, '-- work: %s\n', f);
    str= ['!"C:\Program Files\7-Zip\7z" x "' f '" "-o' dname fname(1:end-3) '"'];
    %str= ['!unrar x "' f '" "' dname '"'];
    eval(str)
    isArchive= 1;
else
    % do nothing
    isArchive= 0;
end

% rename compressed file x.old, for no future decompression
if isArchive && ~isfield(options, 'no_rename') && ~options.no_rename
    str= strrep(['!ren "' f '" "' fname '.old"'], '/', '\');
    eval(str)
end

return


function filelist = zip_contents( zipFilename )
% Function from:
% https://www.mathworks.com/matlabcentral/answers/10945-read-files-in-zip-file-without-unzipping
% function filelist = listzipcontents(zipFilename)
% Create a Java file of the ZIP filename.
zipJavaFile  = java.io.File(zipFilename);
% Create a Java ZipFile and validate it.
zipFile = org.apache.tools.zip.ZipFile(zipJavaFile);
% Extract the entries from the ZipFile.
entries = zipFile.getEntries;
% Initialize the file list.
filelist={};
% Loop through the entries and add to the file list.
while entries.hasMoreElements
    filelist = cat(1,filelist,char(entries.nextElement));
end
zipFile.close
