function [Pre, Post, M0]= pn_read( fname, options )
%
% Read a Petri net from a PIPE2 XML file
%
% Usage:
% [Pre, Post, M0]= pn_read( fname )
% [Pre, Post, M0]= pn_read( fname, options )
%
% Input:
% fname : string : name of a file saved by PIPE2 as XML
% options: struct: (facultative)
%
% Output:
% Pre : NxM : D- of a Petri net incidence matrix D, Pre=-min(D,0)
% Post: NxM : D+ of a Petri net incidence matrix D, Post=max(D,0),
%             D=Post-Pre, N places, M transitions
% M0  : Nx1 : initial marking

% April 2019, J. Gaspar

if nargin<1
    %error('Please specify an input filename as a first argument');
    tst(3); return
end
if nargin<2
    options= [];
end
if isnumeric(fname) && fname==-1
    Pre= token_strings;
    return
end

[Pre, Post, M0]= pn_read_main( fname, options );

return; % end of main function


function [Pre, Post, M0]= pn_read_main( fname, options )

% load file
text_search( 'ini_fname', fname );

% keep only interesting lines; 1 line = 1 place, 1 transition or 1 arc
listStrings= token_strings;
strTokPlace= listStrings{1};
strTokTrans= listStrings{3};
strTokArc  = listStrings{5};
ret= text_search( 'find_all_strings', listStrings );
ret= text_search( 'get_lines_columns', ret );
text_search( 'ini_txt_lines', ret );

% get place ids
listPlaces= {};
text_search('ini');
while text_search( 'find_str', strTokPlace )
    ret= text_search( 'inline_s1s2', {'id="','"'} );
    if isfield(options, 'debug') && options.debug
        fprintf(1, '%s\n', text_search( 'get_line' ) );
        fprintf(1, '%s\n', ret );
    end
    listPlaces{end+1,1}= ret;
end

% get transition ids
listTransitions= {};
text_search('ini');
while text_search( 'find_str', strTokTrans )
    ret= text_search( 'inline_s1s2', {'id="','"'} );
    if isfield(options, 'debug') && options.debug
        fprintf(1, '%s\n', text_search( 'get_line' ) );
        fprintf(1, '%s\n', ret );
    end
    listTransitions{end+1,1}= ret;
end

% get arc ids
listArcs= {};
text_search('ini');
while text_search( 'find_str', strTokArc )
    ret= text_search( 'inline_s1s2', {'id="','"'} );
    if isfield(options, 'debug') && options.debug
        fprintf(1, '%s\n', text_search( 'get_line' ) );
        fprintf(1, '%s\n', ret );
    end
    listArcs{end+1,1}= ret;
end

% foreach place, get initial marking (conv marking to number)
for i=1:size(listPlaces,1)
    text_search('ini');
    text_search( 'find_str', ['id="' listPlaces{i,1} '"'] );
    text_search( 'find_str', '<initialMarking>' );
    ret1= text_search( 'inline_s1s2', {'<value>','</value>'} );
    listPlaces{i,2}= ret1;
    listPlaces{i,3}= get_num( ret1, 1 );
end

% foreach arc, get source and target ids, and get weight
for i=1:size(listArcs,1)
    text_search('ini');
    text_search( 'find_str', ['id="' listArcs{i,1} '"'] );
    % get arc source
    ret1= text_search( 'inline_s1s2', {'source="','"'} );
    listArcs{i,2}= ret1;
    % get arc target
    ret2= text_search( 'inline_s1s2', {'target="','"'} );
    listArcs{i,3}= ret2;
    % get arc weight
    ret3= text_search( 'inline_s1s2', {'<value>','</value>'} );
    listArcs{i,4}= ret3; ret4= get_num( ret3, 1 );
    listArcs{i,5}= ret4;
    % match arc source and dest ids to place or transition ids
    % if source is a place, then D(i,j)= -arcWeight
    % if source is a transition, then D(i,j)= +arcWeight
    ijw= arc2incidence( listPlaces, listTransitions, ret1, ret2, ret4 );
    listArcs{i,5}= ijw;
end

% create Pre, Post, M0
M0= [listPlaces{:,3}]';
Pre= zeros( size(listPlaces,1), size(listTransitions,1) );
Post= Pre;
ijw= reshape([listArcs{:,5}]', 3,[])';
for i= 1:size(ijw,1)
    w= ijw(i,3);
    if w>0
        Post(ijw(i,1), ijw(i,2))= w;
    else
        Pre(ijw(i,1), ijw(i,2))= -w;
    end
end

% show all info
if isfield(options, 'debug') && options.debug
    listPlaces
    listTransitions'
    listArcs
    M0'
    Post
    Pre
    D= Post-Pre
end

return


function listStrings= token_strings
% strings to use as markers to find information
listStrings= {
    '<place ',      '</place>', ...
    '<transition ', '</transition>', ...
    '<arc ',        '</arc>'
    };


function n= get_num(str, cnt)
ind= find('0'<=str & str<='9');
if isempty(ind)
    warning(['No number found in: ' str]);
    n= 0;
    return
end
n= sscanf(str(ind(1):end), '%d');
if nargin>=2
    n= n(1:cnt);
end


function ijw= arc2incidence( listPlaces, listTransitions, ...
    srcId, dstId, arcWeight )
% ijw= [indPlace, indTrans, weight]

i1= isInList( listPlaces, srcId );
i2= isInList( listPlaces, dstId );
j1= isInList( listTransitions, srcId );
j2= isInList( listTransitions, dstId );

if i1 && j2
    % place to transition
    ijw= [i1 j2 -arcWeight];
elseif i2 && j1
    % transition to place
    ijw= [i2 j1  arcWeight];
else
    fprintf('** unexpected i1=%d i2=%d j1=%d j2=%d\n', i1,i2,j1,j2);
    error('arc not p->t and not t->p')
end


function ret= isInList( mylist, str )
ret= 0;
for i=1:size(mylist,1)
    if strcmp(str, mylist{i,1})
        ret= i;
        break
    end
end
