
%%
ROOT_DIR=pwd;
SOURCE_DIR='src';
BUILD_DIR='bin';
APP_DIR='bin\app';
IN_APP_DIR='app';
UTIL_DIR='util';
if exist(BUILD_DIR,'dir')~=7
    mkdir(BUILD_DIR)
end
if exist(APP_DIR,'dir')~=7
    mkdir(APP_DIR)
end
APP_SOURCE_NAME='ESCWaveformGenerator.mlapp';
APP_NAME='ESCWaveformGenerator';
WinMain='WinMain:ESCWaveformGenerator';
APP_SOURCE_PATH=fullfile(ROOT_DIR,SOURCE_DIR,IN_APP_DIR,APP_SOURCE_NAME);


OUT_DIR=fullfile(ROOT_DIR,APP_DIR);
ICON_DIR='C:\Program Files\MATLAB\R2016b\toolbox\compiler\Resources\default_icon.ico';

%EXT_DIR='ext';

SEARCH_DIR1=fullfile(SOURCE_DIR,IN_APP_DIR); % start from root
%FUNC_DIR=fullfile(SOURCE_DIR, UTIL_DIR); % start from root
FUNC_NAME1='read_xsl_info_f.m';
FUNC_NAME2='radar_data_reader.m';
FUNC1=fullfile(ROOT_DIR,SOURCE_DIR, UTIL_DIR,FUNC_NAME1);
FUNC2=fullfile(ROOT_DIR,SOURCE_DIR, UTIL_DIR,FUNC_NAME2);
%SEARCH_DIR3=fullfile(SOURCE_DIR,EXT_DIR);

mcc('-o', APP_NAME,'-W',WinMain,'-T', 'link:exe' ,'-d', OUT_DIR,'-v',APP_SOURCE_PATH,'-a',FUNC1 ,'-a', FUNC2,'-r',ICON_DIR);

cd(SOURCE_DIR);
copyfile config ..\bin\config;
cd('..')
