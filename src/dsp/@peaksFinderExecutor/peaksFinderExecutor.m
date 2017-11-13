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
classdef peaksFinderExecutor<executor
    %Execute multiple signals using radarPeaksFinder
    %Example:
           %inputFiles, radarMetaFile, save peaks to .mat file in the same dir of input files
           % may take a lot of memory if run in parallel for multiple files 
%            numFiles=2;
%            %cell array of input files
%            inputFiles={'inputFilesPath\fileNo1.dat';'inputFilesPath\fileNo2.dat'};
%            radarMetaFile='inputFilesPath\radarmetafile.xlsx';
%            testMultiPeak=peaksFinderExecutor(numFiles);
%            %turn On parallel run, otherwise turn Off for sequential run 
%            testMultiPeak.useParallel='On';
%            testMultiPeak=initParallel(testMultiPeak);
%            testMultiPeak.inputFiles=inputFiles; %cell array of input files
%            testMultiPeak.radarMetaFile=radarMetaFile;
%            testMultiPeak=runExecutor(testMultiPeak);
    %see also radarPeaksFinder, executor
    
    properties
        signals               radarPeaksFinder
        inputFiles            cell
        radarMetaFile
    end
    
    properties(Constant)
        Fs=25e6;
        peakThresholdAboveNoise_dB=20;
    end
    
    
    methods
        function  this=peaksFinderExecutor(numFiles)
            this=this@executor(numFiles);
        end

        function peaksFinders=setupPeaksFinders(this)
            %creates an array of radarPeaksFinder instances 
            
            for I=1:this.numFiles
                peaksFinders(I)=radarPeaksFinder(this.inputFiles{I},this.radarMetaFile,this.Fs,this.peakThresholdAboveNoise_dB);
            end
        end
        
        function this=set.inputFiles(this,inputFiles)
            if this.numFiles==length(inputFiles)
                this.inputFiles=inputFiles;
            else
                this.ERROR.inputFiles= MException('peaksFinderExecutor:inputFiles', ...
                    'Number of input files must be equal to numFiles= %d',this.numFiles);
                throw(this.ERROR.inputFiles);
            end
        end
        
        function this=set.radarMetaFile(this,radarMetaFile)
            %checks for radarMetaFile file
            
            if exist(radarMetaFile, 'file') == 2
                this.radarMetaFile=radarMetaFile;
            else
                this.ERROR.radarMetaFile= MException('peaksFinderExecutor:radarMetaFile', ...
                    'radarMetaFile file does not exist, file name: %s',radarMetaFile);
                throw(this.ERROR.radarMetaFile);
            end
        end

        function this=executeSequential(this)
            %find radar peaks sequentially along the files
            try
                peaksFinders=setupPeaksFinders(this);
                for I=1:this.numFiles
                    peaksFinders(I)=initRadarPeakFinder( peaksFinders(I));
                    peaksFinders(I)=findRadarPeaks(peaksFinders(I));
                    peaksFinders(I)=resetRadarPeaksFinder(peaksFinders(I)); 
                end
                this.signals=peaksFinders;
            catch ME
                this.ERROR.executeSequential=ME;
            end
        end
        
        function this=executeParallel(this)
            %find radar peaks in parallel along the files
            try
                peaksFinders=setupPeaksFinders(this);
                parfor  I=1:this.numFiles
                    peaksFinders(I)=initRadarPeakFinder( peaksFinders(I));
                    peaksFinders(I)=findRadarPeaks(peaksFinders(I));
                    peaksFinders(I)=resetRadarPeaksFinder(peaksFinders(I));
                end
                this.signals=peaksFinders;
            catch ME
                this.ERROR.executeParallel=ME;
            end
        end

    end
    
end

