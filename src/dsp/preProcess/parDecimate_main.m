%% parDecimate - Main script used to decimate radar capture files
%
% Written by Raied Caromi & John Mink
% Version: 1.0
% Date: 24 Feb 2017
%
% NOTES:
% #1) This script currently uses parfor to run individual files in parallel.
% If this is not desirable (or if the toolbox is not available):
%    -1) change parfor to for
%    -2) delete (or comment out) the section "Create Parallel Pool"
%
% #2) As these files are too large to read in a whole file at once, files
% are divided into segments.  This is done with the variable samplesPerSegment.
% That, along with the file size, is used to determine how many segments
% the file is divided into.  ***IMPORTANT***   samplesPerSegment MUST
% divide evenly into the sampling rate ratio.  That is to say, if you
% decimate by a factor of 9, the number of samples per segment MUST be
% divisible by 9, or you will not have the correct number of samples.  This
% can be checked using the standalone script Compare_Decimation_Filesize
%
% Inputs:
%   - radar metadata
%       - reads from radar_Metadata_filename
%   - radar data 
%       - pwd: radar_dirpath
%       - filename: comes from the metadata
% Outputs:
%   - radar data (decimated)
%       - pwd: save_dirpath
%       - filename:
%           - appends save_filepath_suffix to end
%
% Useful commands:
%checks for parallel license ALREADY IN USE
%license('inuse','distrib_computing_toolbox') 
%
%checks for an available parallel license
%license('test','distrib_computing_toolbox')
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Create Parallel Pool %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{%
NumWorkers=20; %Set to desired number of workers (do not exceed # cores in system)
poolobj = gcp('nocreate'); % If no pool, do not create new one.

if isempty(poolobj)
    poolsize = 0;
else
    poolsize = poolobj.NumWorkers;
end

if poolsize<NumWorkers
    delete(poolobj)
    poolobj=parpool(NumWorkers);
end
%}

%%
%%%%%%%%%%%%%%%%%%%%
%%% Setup Params %%%
%%%%%%%%%%%%%%%%%%%%

radar_dir='D:\Spectrum-Share\NASCTN 3.5 GHz San Diego Release\';
save_dir='D:\Spectrum-Share\NASCTN 3.5 GHz San Diego Release - Decimated & Shifted - v7 - test3\';
save_file_suffix='_dec_shift'; %appended to end of file name for 
metadata_filename=[radar_dir 'File_Parameters.xlsx'];

init_seekPositionSamples=0; %start at beginning of file
samplesPerSegment=1024*180; % read in this many samples at once

old_Fs=225e6; %225 MHz original sampling rate
new_Fs=25e6; %25 MHz new sampling rate

BytesPerSample=4; % int16 is 16 bits (2 bytes) & double for both Q & I total of 4 bytes
ElementsPerSample=2;

%This array should contain the measured center frequencies of the radar and
%is used for the shift
radar_freq_noted=1e6*[3550,3550,3550,3550,3550,3550,3550,3550,3550,3600,3600,3600,3600,3600,3550,3550,3550,3550,3550,3550,3550,3520,nan,3600,3600,3600,3600,3600,3550,3550,3550,3550,3550,3550,3550];
load('D:\Spectrum-Share\Waveforms data\parDecimate\radar_freq_noted.mat','radar_freq_noted')
RadarInfo.RFcenterfrequencyHz(23) = 3565;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Read in Radar Metadata %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[RadarInfo,valid_indeces]=parDecimate_sub_parse_metadata(metadata_filename);

%%
%%%%%%%%%%%%%%%%%%%
%%% Run program %%%
%%%%%%%%%%%%%%%%%%%

mytic(1)=tic;

this_radar_freq_noted=radar_freq_noted(1:length(valid_indeces));
this_RF_center_freq=RadarInfo.RFcenterfrequencyHz(1:length(valid_indeces));
freq_shift_vec=this_RF_center_freq-transpose(this_radar_freq_noted);

parfor fileNum=1:length(valid_indeces)
    
    
    freq_shift=freq_shift_vec(fileNum);  %read in current frequency shift  
    
%create full file path for individual file
    radar_filename=strcat(char(RadarInfo.Filename(fileNum)),'.dat');
    radar_filepath=fullfile(radar_dir,radar_filename);
        
    save_filename=strcat(char(RadarInfo.Filename(fileNum)),save_file_suffix,'.dat');
    save_filepath=fullfile(save_dir,save_filename);

% decimate file as long as the radar data actually exists
    if exist(radar_filepath, 'file') == 2
        %calls function to decimate
%{%
        parDecimate_sub_file(radar_filepath,init_seekPositionSamples,...
            samplesPerSegment,ElementsPerSample,BytesPerSample,freq_shift,old_Fs,...
            new_Fs,save_filepath)
 %}
    end
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Reports runtime in readable format %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mytoc(1)=toc(mytic(1));
displayFormat='hh:mm:ss.SSS';
runtime=duration(0,0,mytoc(1),'Format',displayFormat);
fprintf('The processing section took %s to run\n',runtime)