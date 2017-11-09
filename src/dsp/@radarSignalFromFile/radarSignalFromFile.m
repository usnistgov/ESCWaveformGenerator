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
classdef radarSignalFromFile<signalFromFile
    %Signal from file for radar files with meta data, i.e. readScale from sheet
    % set read scale from meta file 
    % estimate radar signal to noise ratio (require main sweep peak values)
    %see also, signalFromFile 
    
    properties (Access=protected)
%         readScale
%         measFile
        radarMetaFile
%        seekPositionSamples
%        radarSignalFromFileInfo
        radarInfoTable
    end

    properties(Constant)
%    bytesPerSample=4;
    combinedFrontEndGain=10.6;
   % combinedFrontEndGain=sqrt(db2pow(19.8)); % San Diego release 
   % combinedFrontEndGain=sqrt(db2pow(22.2)); % Virginia Beach release
%  combinedFrontEndGain=1;
    end
    
    methods
        function this=radarSignalFromFile(InputFile,IQDirection,EOFAction,radarMetaFile)
           
            switch nargin
                case 0
                    supClassArgs={};
                case 1
                    supClassArgs{1}=InputFile;
                case 2
                    supClassArgs{1}=InputFile;
                    supClassArgs{2}=IQDirection;
                case {3,4}
                    supClassArgs{1}=InputFile;
                    supClassArgs{2}=IQDirection;
                    supClassArgs{3}=EOFAction;
            end
            this=this@signalFromFile(supClassArgs{:});
            if nargin==4
                    this.radarMetaFile=radarMetaFile;
                    this=readRadarMetaTable(this);
            end
        end
               
        function this=setRadarMetaFile(this,radarMetaFile)
            this.radarMetaFile=radarMetaFile;
            this=readRadarMetaTable(this);
        end
        
        
         function this=setReadScale(this,readScale)
             if nargin<2
                 if ~isempty(this.radarInfoTable) && ~isempty(this.inputFile)
                     [~,FileName,FileExt] = fileparts(this.inputFile);
                     this.readScale=this.radarInfoTable.ADCScaleFactor(ismember(this.radarInfoTable.FileName,[FileName,FileExt]))/this.combinedFrontEndGain;
                    % disp(num2str(this.radarInfoTable.ADCScaleFactor(ismember(this.radarInfoTable.FileName,[FileName,FileExt]))))
                 else
                     this.signalFromFileERROR.setReadScale= MException('radarSignalFromFile:RadarMeta', ...
                                'No appropriate radar meta data found');
                     throw(this.signalFromFileERROR.setReadScale);
                 end
             else
                 this.readScale=readScale;
             end
         end

         
         function signalFromFileInfo=getSignalInfo(this)
             signalFromFileInfo.readScale=this.readScale;
             signalFromFileInfo.inputFile=this.inputFile;
             signalFromFileInfo.radarMetaFile=this.radarMetaFile;
             signalFromFileInfo.inputFileID=this.inputFileID;
             signalFromFileInfo.seekPositionSamples=this.seekPositionSamples;
             signalFromFileInfo.samplesPerSegment=this.samplesPerSegment;
             if ~isempty(this.radarInfoTable) && ~isempty(this.inputFile)
                 [~,FileName,FileExt] = fileparts(this.inputFile);
                 logicalIndex=ismember(this.radarInfoTable.FileName,[FileName,FileExt]);
                 signalFromFileInfo.radarFileIndex=find(logicalIndex);
                 signalFromFileInfo.radarInfoTable=this.radarInfoTable(logicalIndex,:);
             else
                 signalFromFileInfo.radarInfoTable=[];
             end
         end
        
%         function signalTime=getSignalTime(this,Fs)
%             if ~isempty(this.inputFile)
%                  fInfo=dir(this.inputFile);
%                  signalTime.totalNumberOfSamples=fInfo.bytes/this.bytesPerSample;
%                  if nargin >1
%                  signalTime.timeSec=signalTime.totalNumberOfSamples*1/Fs;
%                  end
%             else
%                 signalTime=[];
%             end
%         
%         end
        
        
         function this=readRadarMetaTable(this)
            %% Import the data
            if exist(this.radarMetaFile, 'file') == 2
                %MSGID='MATLAB:table:ModifiedAndSavedVarnames';warning('off', MSGID);
                this.radarInfoTable=readtable(this.radarMetaFile);
            else
             this.radarInfoTable=[];   
            end
        end
        
        
        function [this,sigmaW2,medianPeak,noiseEst,maxPeak,maxPeakLoc]=estimateRadarNoise(this,Fs,radarPeaks)
            segTime=0.8e-3;
            advancefromPeak=0.05e-3;
            %radarPeaks=load(peakFilePath);
            [maxPeak,maxPeakLocIndx]=max(radarPeaks.pks);
            medianPeak=median(radarPeaks.pks,'omitnan');
            samplesPerSegmentTemp=this.samplesPerSegment;
            seekPositionSamplesTemp=this.seekPositionSamples;
            this.samplesPerSegment=round(segTime/(1/Fs));
            maxPeakLoc=radarPeaks.locs(maxPeakLocIndx);
            seekTime=maxPeakLoc+advancefromPeak;
            this=setSeekPositionSamples(this,round(seekTime/(1/Fs)));                     
            noiseEst =readSamples(this);
            sigmaW2=sum(abs(noiseEst).^2)/length(noiseEst);
            this.samplesPerSegment=samplesPerSegmentTemp;
            this.seekPositionSamples=seekPositionSamplesTemp;
        end
        

    end
    
end

