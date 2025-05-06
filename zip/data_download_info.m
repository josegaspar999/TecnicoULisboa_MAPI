function datasets= data_download_info(op)
if nargin<1
    op= 'ret_info';
end

switch op
    case 'ret_info', datasets= ret_info();
    case 'add_pipe2', mycnf('set', 'Pipe2_download', 1);
    otherwise
        error('inv op "%s"', op)
end

return


function ret= mycnf(op, a1, a2)
global DDI
if isempty(DDI)
    DDI= struct('Pipe2_download', 0);
end

switch op
    case 'set', DDI.(a1)= a2;

    case 'get'
        if ~isfield(DDI, a1)
            ret= [];
        else
            ret= DDI.(a1);
        end
        
    otherwise
        error('inv op "%s"', op);
end


function datasets= ret_info()
% datasets= {...
%    struct('dataId','PN_editor_Pipe2',	'url', 'http://users.isr.ist.utl.pt/~jag/software/PIPEv4.3.0.zip'), ...
%    };

datasets= {};

if mycnf('get', 'Pipe2_download')
    datasets{end+1}= struct('dataId','PN_editor_Pipe2',	...
        'url', 'http://users.isr.ist.utl.pt/~jag/software/PIPEv4.3.0.zip');
end
