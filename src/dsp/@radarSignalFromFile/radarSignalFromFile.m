classdef radarSignalFromFile<signalFromFile
    %Radar Rsignal reader
    %   Read binary data from measurement files
    % Example usage:
    %     Radar_info_file='metaFile.xlsx';
    %     fileNo=1;
    %     metaFilePath='metaFileDir';
    %     radarMetaFile=fullfile(metaFilePath,Radar_info_file);
    %     files_path='measFilesDir';
    %     file_name='measFile.dat';
    %     measFile=fullfile(files_path,file_name);
    %
    %     testwaveform=radarSignalFromFile(file_path_name,radar_meta_file);
    %     testwaveform=readRadarMeta(testwaveform);
    %
    %     testwaveform=setRadarMeasFileNum(testwaveform,fileNo);
    %     testwaveform=setreadScale(testwaveform);
    %
    %     testwaveform=initRadarFile(testwaveform);
    %     seekPositionSamples=0;
    %     testwaveform=setSeekPositionSamples(testwaveform,seekPositionSamples);
    %     samplesPerSegment=180*1024;
    %     testwaveform=setSamplesPerSegment(testwaveform,samplesPerSegment);
    %     
    %     testwaveform=readRadarMeasData(testwaveform);
    %     testwaveform=seekNextPositionSamples(testwaveform);
    %     measData=testwaveform.measData;

    
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
%                         switch nargin
%                             case 0
%                                 %set default IQ direction
%                                 this.IQDirection='QI';
%                                 %set default EOF action
%                                 this.EOFAction='Rzeros';
%                             case 1
%                                 this.inputFile=InputFile;
%                                 %set default IQ direction
%                                 this.IQDirection='QI';
%                                 %set default EOF action
%                                 this.EOFAction='Rzeros';
%                             case 2
%                                 this.inputFile=InputFile;
%                                 this.IQDirection=IQDirection;
%                                 %set default EOF action
%                                 this.EOFAction='Rzeros';
%                             case 3
%                                 this.inputFile=InputFile;
%                                 this.IQDirection=IQDirection;
%                                 this.EOFAction=EOFAction;
%                             case 4
%                                 this.inputFile=InputFile;
%                                 this.IQDirection=IQDirection;
%                                 this.EOFAction=EOFAction;
%                                 this.radarMetaFile=radarMetaFile;
%                                 this=readRadarMetaTable(this);
%                         end
            
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
        


        
%         function this=setInputFile(this,inputFile)
%             this.inputFile=inputFile;
%         end
%                 
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
        
        function signalTime=getSignalTime(this,Fs)
            if ~isempty(this.inputFile)
                 fInfo=dir(this.inputFile);
                 signalTime.totalNumberOfSamples=fInfo.bytes/this.bytesPerSample;
                 if nargin >1
                 signalTime.timeSec=signalTime.totalNumberOfSamples*1/Fs;
                 end
            else
                signalTime=[];
            end
        
        end
        
        
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

