function ret= text_search( op, arg1 )
%
% Get by argument a list of strings and search on those lines. Saves list
% of strings in a global var. Requires multiple calls to return found or
% not found result. Instead of getting the list of strings as argument, can
% also load a text file.
%
% Input:
% op  : str : command string
% arg1: str or list : depends on op, can be str or list
%
% Output:
% ret : int or str or other : depends on command

% Nov2018 J. Gaspar

if nargin<1
    text_search_demo
    return
end

global TT 
global TI

ret= [];
switch op

    case 'ini'
        TI= struct('lin',1, 'col',1, 'colAfterStr',1);
    case 'ini_txt_lines'
        TT= arg1; % list of strings
        text_search( 'ini' );
    case 'ini_fname'
        if exist('text_read.m', 'file')
            text_search( 'ini_txt_lines', text_read(arg1) );
        else
            text_search( 'ini_txt_lines', text_read_local(arg1) );
        end


    case 'get_all_lines'
        ret= TT;
    case 'get_line'
        ret= TT{TI.lin};

    case 'next_line'
        ret= 1;
        TI.lin= TI.lin+1;
        if TI.lin>length(TT)
            TI.lin= length(TT);
            ret= 0;
        end
        TI.col= 1;         % where str was found
        TI.colAfterStr= 1; % start next search
        
    case 'find_str'
        % navigate in the current line to find a string
        % if not found, then tries 'next_line'
        % if end of lines, then return not found
        
        ret= 0; % foundFlag
        while 1
            % try the current line
            str= text_search('get_line');
            ind= strfind( str(TI.colAfterStr:end), arg1 );
            if ~isempty(ind)
                TI.col= TI.colAfterStr-1 +ind(1);
                TI.colAfterStr= TI.col +length(arg1);
                ret=1;
                break; % found line with string
            end
            % try another line
            if ~text_search('next_line')
                % no more lines
                break
            end
        end
        
    case 'str_in_curr_line'
        ret= 0;
        ind= strfind( TT{TI.lin}, arg1 );
        if ~isempty(ind)
            ret= 1;
        end
        
    case 'inline_till_str'
        % find till string or end of line
        str= TT{TI.lin};
        str= str( TI.colAfterStr : end );
        ind= strfind( str, arg1 );
        if ~isempty(ind)
            ret= str( 1 : ind(1)-1 );
        else
            ret= str( 1 : end );
        end
        
    case 'inline_s1s2'
        % find string inline between strings s1 and s2
        % text_search( 'inline_s1s2', {s1, s2} )
        % arg1 must be {s1, s2}
        if ~text_search( 'find_str', arg1{1} )
            ret= '';
            return
        end
        ret= text_search( 'inline_till_str', arg1{2} );
        
    case 'find_all_strings'
        % text_search( 'find_all_strings', {s1, s2, s3, ...} )
        ret= {};
        for j=1:length(arg1)
            str= arg1{j};
            ret{j,1}= str;
            ret{j,2}= [];
            for i= 1:length(TT)
                ind= strfind(TT{i}, str);
                if ~isempty(ind)
                    % save line and ini columns
                    ret{j,2}= [ret{j,2}; i+0*ind(:) ind(:)];
                end
            end
        end

    case 'get_lines_columns'
        % given the output of 'find_all_strings' as arg1
        % arg1 is 2Nx2 list where {*,1} is string, {*,2} are [Mlins,MCols]
        % line breaks are represented by chr 10
        ret= {};
        for i=1:2:size(arg1,1)
            % size(arg1,1) must be even
            lc1= arg1{i,2};
            lc2= arg1{i+1,2};
            s2len= length(arg1{i+1,1});
            for j=1:size(lc1,1)
                % size(lc1,1) must equal size(lc2,1)
                str= get_text( TT, lc1(j,:), lc2(j,:)+[0 s2len-1] );
                ret{end+1}= str;
            end
        end

    case 'clear'
        clear global TT
        clear global TI
    otherwise
        error('inv op')
end

return; % end of function


function str= get_text( TT, lc1, lc2 )
% TT : list strings
% lc1: 1x2 : line and column where to start
% lc2: 1x2 : line and column where to end
% return single string having line breaks

if lc1(1)==lc2(1)
    % info is in a single line
    str= TT{lc1(1)};
    str= str(lc1(2):lc2(2));
else
    % info is in multiple lines
    for i= lc1(1):lc2(1)
        tLine= TT{i};
        if i==lc1(1)
            % first line
            str= tLine(lc1(2):end);
        elseif i==lc2(1)
            % last line
            str= [str 10 tLine(1:lc2(2))];
        else
            % other (middle) lines
            str= [str 10 tLine];
        end
    end
end

return


function y= text_read_local( filename )
% Load a text file into a list of strings.
% The list does not contain end of line characters (CR, LF, CRLF, LFCR).
fid = fopen(filename);
if fid<1
    error(['Opening file: ' filename])
end
y = {};
tline = fgetl(fid);
while ischar(tline)
    y{end+1}= tline;
    tline = fgetl(fid);
end
fclose(fid);


function text_search_demo
text_search( 'ini_fname', 'text_search.m' );
text_search( 'find_str', 'switch' );
str= text_search( 'inline_till_str', 'eoln' ); disp(str);
text_search( 'find_str', 'error(' );
str= text_search( 'inline_till_str', ')' ); disp(str);
text_search( 'clear' );
return
