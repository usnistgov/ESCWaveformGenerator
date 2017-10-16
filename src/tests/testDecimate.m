%% Test decimation using framework
% NOTE: You MUST specifiy files in the "manage files (I/O)" section or this will not work!
% This is an example script that should run as written (except for the note above).  This script:
% 0) clears workspace
% 1) Creates a decimation object
% 2) Passes that object the name(s) of the file(s) to decimate as a cell array
% 3) Decimates the input files & saves the result as the corresponding output file

%% Clear Memory & close all files
clear
fclose('all'); 

%% Setup other parameters
profile on
freqShifts=[15e6;15e6];
useParallel='On';

%% Manage files (I/O)
%inputFiles & outputFiles should BOTH have numFiles elements

numFiles=2; %number of files to decimate

inputFolder='C:\Path\to\Read\NonDecimated\Files';
inputFileName{1}='inputFileName_1.dat';
inputFileName{2}='inputFileName_2.dat';

outputFolder='C:\Path\to\Write\Decimated\Files';
outputFileName{1}='outputFileName_1.dat';
outputFileName{2}='outputFileName_2.dat';

inputFiles={
    fullfile(inputFolder,inputFileName{1});
    fullfile(inputFolder,inputFileName{2})
    };

outputFiles={
    fullfile(outputFolder,outputFileName{1});
    fullfile(outputFolder,outputFileName{2})
    };

%% Setup object
%create object for decimating these files
testMultiDec=decimationExecutor(numFiles);

%setup I/O files
testMultiDec.inputFiles=inputFiles; %cell array of input files
testMultiDec.outputFiles=outputFiles; %cell array of output files

%read frequency shifts into object
testMultiDec.freqShifts=freqShifts; %vector of frequncy shift, the order of inputFiles, outputFiles, freqShifts should match

%% Setup Parallel (if desired)
testMultiDec.useParallel=useParallel;
testMultiDec=initParallel(testMultiDec);

%% Decimate Files
testMultiDec=runExecutor(testMultiDec);

%% Report Results
profile viewer   