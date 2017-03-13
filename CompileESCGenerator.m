
%%
ROOT_DIR=pwd;
SOURCE_DIR='src';
BUILD_DIR='bin';
if exist(BUILD_DIR,'dir')~=7
    mkdir(BUILD_DIR)
end
APP_SOURCE_NAME='ESCWaveformGenerator.mlapp';
APP_NAME='ESCWaveformGenerator';
%APP_SOURCE_PATH=fullfile(ROOT_DIR,SOURCE_DIR,APP_SOURCE_NAME);

OUT_DIR=fullfile(ROOT_DIR,BUILD_DIR);

FUNC_DIR='func';
EXT_DIR='ext';
%SEARCH_DIR1=fullfile(SOURCE_DIR); % start from root
SEARCH_DIR2=fullfile(SOURCE_DIR, FUNC_DIR); % start from root
SEARCH_DIR3=fullfile(SOURCE_DIR,EXT_DIR);

mcc('-e', APP_SOURCE_NAME,'-N','-I',SOURCE_DIR ,'-I', SEARCH_DIR2, '-I', SEARCH_DIR3, '-d', OUT_DIR,'-o',APP_NAME);

