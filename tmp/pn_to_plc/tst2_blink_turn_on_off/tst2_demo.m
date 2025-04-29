function tst2_demo
% Test PN to PLC converter for various hardware configurations
% May 2020, J. Gaspar

% 1. put the compiler in the path
path(path,'../pn_to_plc_compiler')

% 2. define compile options
ofname= 'tst2_mk_program_res.txt';
odname= 'tmp';
optionsHW= { ...
    's2_DEY16D2_s4_DSY16T2', '.txt', '_16t2.txt'; ...
    's3_DMY28FK',            '.txt', '_28fk.txt'; ...
    'm0-9_m10-19',           '.txt', '_m019.txt'; ...
    };
optionsTPMem= { ...
    [10 49 50 89]; ...
    [200 299 300 399]; ...
    };

% 3. do the compilation for many cases
if ~exist( odname, 'dir' )
    mkdir( odname );
end
for i= 1:size(optionsHW,1)
    % choose the hardware configuration
    hwStr= char( optionsHW{i,1} );

    for j= 1:size(optionsTPMem,1)
        % choose the memory usage
        tpMem= optionsTPMem{j};
        plc_z_code_helper('config', hwStr, tpMem );

        % define the output filename
        s2= optionsHW{i,2};
        s3= optionsHW{i,3};
        s3= strrep( s3, s2, [sprintf('_mem%d',j) s2] );
        ofname2= [odname filesep strrep( ofname, s2, s3 )];
        
        % create the output file
        tst2_blink_on_off( 1, ofname2 );
    end
end
