function logout_mapi
% End of lab cleanup
% Oct2017, J. Gaspar

choice = questdlg('Close all text files, clear data and exit Matlab?', ...
    'Logout confirm', ...
    'Yes','No','No');
if strcmp( choice, 'No' )
    disp('-- Matlab exit aborted.')
    return
end

%% try to save data in the current folder
%[y,m,d,h,mi,s]= datevec(now);
%fname= sprintf('%04d%02d%02d_%02d%02d.mat', y,m,d,h,mi);
%str= ['save(''' fname ''')'];
%evalin('base', str)

% clear all data, clean command line
evalin('base', 'clear all')
clc

% close the editor
MLEditorServices = com.mathworks.mlservices.MLEditorServices;
MLEditor = MLEditorServices.getEditorApplication;
MLEditor.close();

% exit matlab
evalin('base', 'exit')
