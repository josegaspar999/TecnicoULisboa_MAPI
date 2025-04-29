function mem_dump_show( op, a1, a2 )
%
% Show a memory data dump created by UnityPro

% Jun2022, J. Gaspar

if nargin<1
    op= 'askFilename';
end
if nargin<2, a1= []; end
if nargin<3, a2= []; end

switch op
    case 'askFilename'
        fname= get_fname();
        mem_dump_show( 'showFilename', fname );
        
    case 'selectData'
        fname= get_fname();
        options= add_options( a2, struct('selectData', 1) );
        mem_dump_show( 'showFilename', fname, options );
        
    case 'showFilename'
        fname= a1;
        options= add_options( a2, struct('cropAsIndex', 1) );
        mem_dump_show_main( fname, options )
        
    otherwise
        error('inv op');
end

return


function fname= get_fname()
[fname, pname]= uigetfile('*.DTX');
fname= [pname fname];


function options= add_options( a2, opt )
if isempty(a2)
    options= opt;
    return
end

options= a2;
names= fieldnames(opt);
for i= 1:length(names)
    if ~isfield(options, names{i})
        options.(names{i})= opt.(names{i});
    end
end


function y= truncate_Nx2_array( x )
y= x;
strList= cellstr( num2str(x) );

[indList, okFlag] = listdlg('PromptString',...
    {'Select data lines to keep' , ...
    '(click first and last, or just the first line to keep):', ...
    '(press the ctrl key for selecting also the last line)'},...
    'SelectionMode', 'multiple',... %'single', ... %'multiple',...
    'ListSize', [300 300], ...
    'ListString',strList);

if ~okFlag
    return
end

if length(indList)==1
    y= y(indList:end,:);
elseif length(indList)==2
    y= y(indList(1):indList(2),:);
elseif diff(indList)
    y= y(indList,:);
else
    warning('yet to implement more than two lines selected')
    % choose groups to display, or simply the clicked cells?
end

return


function mem_dump_show_main( fname, options )

% get the data from the file
x= mem_dump_load( fname, options );

% show datapoints as a list, and ask start or start+end
if isfield(options, 'selectData')
    % yet to implement
    x= truncate_Nx2_array( x' )';
end

% legacy display, two types of plot
plotFlags= [0 1];
if isfield(options, 'plotFlags')
    plotFlags= options.plotFlags;
end

% type1 of plot
if plotFlags(1)
    figure(201); clf;
    stairs(x(1,:), x(2,:), '.-', 'linewidth',4)
    xlabel('scan cycle number')
    ylabel('16bits word as decimal')
end

% type2 of plot
if plotFlags(2)
    figure(202); clf;
    z= dec2bin(x(2,:),16)-'0'; z= z(:,end:-1:1);
    %plot_z(x(1,:), z)
    %plot_z(x(1,:), z, struct('patch',1))
    plot_z(x(1,:), z, struct('patch',1,'zoh',1))
    xlabel('scan cycle number')
    ylabel('bit number')
end

return
