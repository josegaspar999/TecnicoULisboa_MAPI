function mapi_www
%
% Easy access to MAPI webpages and lab guides

% May2023, J. Gaspar

info= get_info_list;
strList= info(:,1);

[indList, okFlag] = listdlg('PromptString',...
    {'MAPI websites and PDF files', 'Press Cancel to do nothing'},...
    'SelectionMode','multiple', ... %'single',...
    'ListSize', [300 300], ...
    'ListString', strList);

if ~okFlag
    % do nothing
    return
end

for i= indList
    str= info{i,2};
    str= ['!start "open http" "' str '"'];
    %     disp(str)
    eval(str)
end

return; % end of main function


% function info= load_info
% info= {...
%     struct('menuItem','', 'url', 'https://www.dropbox.com/s/d60mmro2vpu1l44/PTZ_and_laser_calib.zip?dl=1'), ...
%     struct('menuItem','', 'url', 'https://www.dropbox.com/s/z1tnul4hdfe0rej/190600_vrml_chessboard.zip?dl=1'), ...
%    };
% return

function info= get_info_list
info= {
    'Main  webpage', 'http://users.isr.ist.utl.pt/~jag/courses/mapi24d/mapi2425.html';
    'Fenix webpage', 'https://fenix.tecnico.ulisboa.pt/disciplinas/MAPI36/2024-2025/2-semestre';
    'Lab0 PDF', 'http://users.isr.ist.utl.pt/~jag/courses/mapi24d/docs/lab_guides/MAPI_LAB0_2425.pdf';
    ... %'Lab1 PDF', 'http://users.isr.ist.utl.pt/~jag/courses/mapi23d/docs/lab_guides/MAPI_LAB1_2324.pdf';
    ... %'Lab2 PDF', 'http://users.isr.ist.utl.pt/~jag/courses/mapi23d/docs/lab_guides/MAPI_LAB2_2324.pdf';
	... %'Lab3 PDF', 'http://users.isr.ist.utl.pt/~jag/courses/mapi23d/docs/lab_guides/MAPI_LAB3_2022.pdf';
    };
