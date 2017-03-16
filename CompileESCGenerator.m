
%%
ROOT_DIR=pwd;
SOURCE_DIR='src';
BUILD_DIR='bin';
APP_DIR='bin\app';
if exist(BUILD_DIR,'dir')~=7
    mkdir(BUILD_DIR)
end
if exist(APP_DIR,'dir')~=7
    mkdir(APP_DIR)
end
APP_SOURCE_NAME='ESCWaveformGenerator.mlapp';
APP_NAME='ESCWaveformGenerator';
%APP_SOURCE_PATH=fullfile(ROOT_DIR,SOURCE_DIR,APP_SOURCE_NAME);


OUT_DIR=fullfile(ROOT_DIR,APP_DIR);

IN_APP_DIR='app';
UTIL_DIR='util';
%EXT_DIR='ext';
SEARCH_DIR1=fullfile(SOURCE_DIR,IN_APP_DIR); % start from root
SEARCH_DIR2=fullfile(SOURCE_DIR, UTIL_DIR); % start from root
%SEARCH_DIR3=fullfile(SOURCE_DIR,EXT_DIR);
%
%mcc('-e', APP_SOURCE_NAME,'-N','-I',SEARCH_DIR1 ,'-I', SEARCH_DIR2, '-d', OUT_DIR,'-o',APP_NAME);
%mcc('-m', '-v', '-C', '-e', APP_SOURCE_NAME,'-N','-I',SEARCH_DIR1 ,'-I', SEARCH_DIR2, '-d', OUT_DIR,'-o',APP_NAME);
%
mcc('-mv', APP_SOURCE_NAME,'-N','-I',SEARCH_DIR1 ,'-I', SEARCH_DIR2, '-d', OUT_DIR,'-o',APP_NAME);
cd(SOURCE_DIR);
copyfile config ..\bin\config;
cd('..')
