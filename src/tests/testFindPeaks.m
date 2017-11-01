...%% Legal Disclaimer
...% NIST-developed software is provided by NIST as a public service. 
...% You may use, copy and distribute copies of the software in any medium,
...% provided that you keep intact this entire notice. You may improve,
...% modify and create derivative works of the software or any portion of
...% the software, and you may copy and distribute such modifications or
...% works. Modified works should carry a notice stating that you changed
...% the software and should note the date and nature of any such change.
...% Please explicitly acknowledge the National Institute of Standards and
...% Technology as the source of the software.
...% 
...% NIST-developed software is expressly provided "AS IS." NIST MAKES NO
...% WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY
...% OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY
...% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT
...% AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE
...% OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR
...% THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY 
...% REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS 
...% THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY,
...% RELIABILITY, OR USEFULNESS OF THE SOFTWARE.
...% 
...% You are solely responsible for determining the appropriateness of
...% using and distributing the software and you assume all risks
...% associated with its use, including but not limited to the risks and
...% costs of program errors, compliance with applicable laws, damage to 
...% or loss of data, programs or equipment, and the unavailability or
...% interruption of operation. This software is not intended to be used in
...% any situation where a failure could cause risk of injury or damage to
...% property. The software developed by NIST employees is not subject to
...% copyright protection within the United States.

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
%freqShifts=[15e6;15e6];
useParallel='On';

%% Manage files (I/O)
%inputFiles & outputFiles should BOTH have numFiles elements

numFiles=2; %number of files to decimate

inputFolder='D:\Spectrum-Share\NASCTN 3.5 GHz San Diego Release - Decimated & Shifted - v5';
inputFileName{1}='SanDiego_1_dec01.dat';
inputFileName{2}='SanDiego_2_dec01.dat';

radarMetaFile=fullfile(inputFolder,'FileMeta.xlsx');
% outputFolder='C:\Path\to\Write\Decimated\Files';
% outputFileName{1}='outputFileName_1.dat';
% outputFileName{2}='outputFileName_2.dat';

inputFiles={
    fullfile(inputFolder,inputFileName{1});
    fullfile(inputFolder,inputFileName{2})
    };

% outputFiles={
%     fullfile(outputFolder,outputFileName{1});
%     fullfile(outputFolder,outputFileName{2})
%     };

%% Setup object
%create object for decimating these files
testMultiPeak=peaksFinderExecutor(numFiles);

%setup I/O files
testMultiPeak.inputFiles=inputFiles; %cell array of input files
%testMultiPeak.outputFiles=outputFiles; %cell array of output files
testMultiPeak.radarMetaFile=radarMetaFile;
%read frequency shifts into object
%testMultiPeak.freqShifts=freqShifts; %vector of frequncy shift, the order of inputFiles, outputFiles, freqShifts should match

%% Setup Parallel (if desired)
testMultiPeak.useParallel=useParallel;
%limit number of worker since radarPeaksFinder use a lot of memory
testMultiPeak.NumWorkers=2;

testMultiPeak=initParallel(testMultiPeak);

%% Decimate Files
testMultiPeak=runExecutor(testMultiPeak);

%% Report Results
profile viewer   