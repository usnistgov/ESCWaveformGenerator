%% test decimate using framework 
clear
fclose('all'); 
numFiles=2;
filesPathNondec='D:\Spectrum-Share\NASCTN 3.5 GHz San Diego Release';
filesPathDec='D:\Spectrum-Share\NASCTN 3.5 GHz San Diego Release - Decimated & Shifted - Rdecv6\newDec';

inputFiles={fullfile(filesPathNondec,'SanDiego_1.dat');fullfile(filesPathNondec,'SanDiego_2.dat')};
outputFiles={fullfile(filesPathDec,'SanDiego_1_dec01.dat');fullfile(filesPathDec,'SanDiego_2_dec01.dat')};
freqShifts=[15e6;15e6];
profile on
testMultiDec=decimationExecutor(numFiles);
testMultiDec.useParallel='On';
testMultiDec=initParallel(testMultiDec);
testMultiDec.inputFiles=inputFiles; %cell array of input files
testMultiDec.outputFiles=outputFiles; %cell array of output files
testMultiDec.freqShifts=freqShifts; %vector of frequncy shift, the order of inputFiles, outputFiles, freqShifts should match

testMultiDec=runExecutor(testMultiDec);

profile viewer   