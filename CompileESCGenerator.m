...%% Legal Disclaimer
...% NIST-developed software is provided by NIST as a public service. 
...% You may use, copy and distribute copies of the software in any medium,
...% provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.
...% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.
...% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.

%%
ROOT_DIR=pwd;
SOURCE_DIR='src';
BUILD_DIR='bin';
APP_DIR='bin\app';
IN_APP_DIR='app';
DSP_DIR='dsp';
UTIL_DIR='util';
RES_DIR='res';
ICON_FILE='ESCGenIconVc.res';
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
%ICON_FILE='C:\Program Files\MATLAB\R2016b\toolbox\compiler\Resources\default_icon.ico';
ICON_PATH=fullfile(ROOT_DIR,SOURCE_DIR,RES_DIR,ICON_FILE);
SPLASH_FILE='C:\Program Files\MATLAB\R2016b\toolbox\compiler\Resources\default_splash.png';
%EXT_DIR='ext';

%SEARCH_DIR1=fullfile(SOURCE_DIR,IN_APP_DIR); % start from root
%FUNC_DIR=fullfile(SOURCE_DIR, UTIL_DIR); % start from root
%FUNC_NAME1='read_xsl_info_f.m';
%FUNC_NAME2='radar_data_reader.m';
%FUNC1=fullfile(ROOT_DIR,SOURCE_DIR, UTIL_DIR,FUNC_NAME1);
%FUNC2=fullfile(ROOT_DIR,SOURCE_DIR, UTIL_DIR,FUNC_NAME2);
SEARCH_DIR1=fullfile(SOURCE_DIR,DSP_DIR);
SEARCH_DIR2=fullfile(SOURCE_DIR,UTIL_DIR);
%mcc('-o', APP_NAME,'-W',WinMain,'-T', 'link:exe' ,'-d', OUT_DIR,'-v',APP_SOURCE_PATH,'-a',FUNC1 ,'-a', FUNC2,'-r',ICON_FILE);
mcc('-o', APP_NAME,'-W',WinMain,'-T', 'link:exe' ,'-d', OUT_DIR,'-v',APP_SOURCE_PATH,'-I',SEARCH_DIR1,'-I',SEARCH_DIR2,'-r',ICON_PATH);

% cd(SOURCE_DIR);
% copyfile config ..\bin\config;
% copyfile res ..\bin\res;
% copyfile(SPLASH_FILE, '..\bin\app\splash.png')
% cd('..')

%% restart matlab
!matlab &
exit
