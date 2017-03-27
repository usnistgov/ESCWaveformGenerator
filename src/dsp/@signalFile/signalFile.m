classdef signalFile
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
    %     testwaveform=signalFile(file_path_name,radar_meta_file);
    %     testwaveform=readRadarMeta(testwaveform);
    %
    %     testwaveform=setRadarMeasFileNum(testwaveform,fileNo);
    %     testwaveform=setRfGain(testwaveform);
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
        rfGain
        measFile
        radarMeasFileNum
        radarMetaFile
        %fileID
        seekPositionSamples
        radarInfo
        signalFileInfo
        IQDirectionNum
    end
    properties (Access=public)
        measData
        fileID
        samplesPerSegment
        IQDirection
    end
    properties(Constant)
    bytesPerSample=4;
    end
    
    methods
        function this=signalFile(measFile,IQDirection,radarMetaFile)
            
            switch nargin
                case 0
                    %set default IQ direction
                    this.IQDirection='QI';
                case 1
                    this.measFile=measFile;
                    %set default IQ direction
                    this.IQDirection='QI';
                case 2
                    this.measFile=measFile;
                    this.IQDirection=IQDirection;
                case 3
                    this.measFile=measFile;
                    this.IQDirection=IQDirection;
                    this.radarMetaFile=radarMetaFile;
            end

            
        end
        


        
        function this=setMeasFile(this,measFile)
            this.measFile=measFile;
        end
                
        function this=setRadarMetaFile(this,radarMetaFile)
            this.radarMetaFile=radarMetaFile;
        end
        
        function this=setRadarMeasFileNum(this,radarMeasFileNum)
            this.radarMeasFileNum=radarMeasFileNum;
        end
        
        function this=setSeekPositionSamples(this,seekPositionSamples)
            this.seekPositionSamples=seekPositionSamples;
        end
        
        function this=setSamplesPerSegment(this,samplesPerSegment)
            this.samplesPerSegment=samplesPerSegment;
        end

         function this=setRfGain(this,rfGain)
            if nargin<2 
            if isempty(this.radarInfo)
                error('Radar:WrongRadarInfo',...
                      'Error. \n no appropriate radar meta data found');
            else
            this.rfGain=this.radarInfo.ADCscalefactorFADC(this.radarMeasFileNum)/10.6;
            end
            else 
                this.rfGain=rfGain;
            end
         end
     
        function signalFileInfo=getRadarWaveformInfo(this)
        signalFileInfo.rfGain=this.rfGain;
        signalFileInfo.measFile=this.measFile;
        signalFileInfo.radarMeasFileNum=this.radarMeasFileNum;
        signalFileInfo.radarMetaFile=this.radarMetaFile;
        signalFileInfo.fileID=this.fileID;
        signalFileInfo.seekPositionSamples=this.seekPositionSamples;
        signalFileInfo.samplesPerSegment=this.samplesPerSegment;
        signalFileInfo.radarInfo=this.radarInfo;
        signalFileInfo.fileID=this.fileID;
        end
        
        function this=readRadarMeta(this)
            %% Import the data
            if exist(this.radarMetaFile, 'file') == 2
            [~, ~, raw] = xlsread(this.radarMetaFile,'Sheet1','','basic');
            raw = raw(2:end,:);
            raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
            cellVectors = raw(:,[1,2,3,6]);
            raw = raw(:,[4,5]);
            
            %% Replace non-numeric cells with NaN
            R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
            raw(R) = {NaN}; % Replace non-numeric cells
            
            %% Create output variable
            data = reshape([raw{:}],size(raw));
            
            %% Allocate imported array to column variable names
            radarinfo.Filename = cellVectors(:,1);
            radarinfo.Antenna = cellVectors(:,2);
            radarinfo.Comments = cellVectors(:,3);
            radarinfo.RFcenterfrequencyHz = data(:,1);
            radarinfo.ADCscalefactorFADC = data(:,2);
            %RadarInfo.SHA1Hash = cellVectors(:,4);
            this.radarInfo=radarinfo;
            %% Clear temporary variables
            clearvars data raw cellVectors R;
            else
             this.radarInfo=[];   
            end
        end
        
        function this=initFile(this)
            %errmsg = '';
            switch this.IQDirection
                case 'IQ'
                    
                    this.IQDirectionNum=[1 2];
                case 'QI'
                    this.IQDirectionNum=[2 1];
            end

            if isfield(this,'fileID') && this.fileID>=3
                fclose(this.fileID);
            end
            
            if exist(this.measFile, 'file') == 2
            [ FileID,errmsg]=fopen(this.measFile,'r','l','UTF-8');
            else
                errmsg='file does not exist';
            end
            
            if isempty(errmsg)
                this.fileID=FileID;
            end
        end
        
        function measData = readMeasData(this)
            %
            %[file_id,~]=fopen(file_path_name,'r','l','UTF-8');

            
            seekPosition=this.bytesPerSample*this.seekPositionSamples;
            status=fseek( this.fileID,seekPosition,'bof'); %return 0 if success, o.w. -1
%             if res == -1
%                 Data_Vec_Interleaved = [];
%                 %close(file_id);
%                 %return;
%             end
            
            if ~status
            Data_Vec_Interleaved=fread(this.fileID,2*this.samplesPerSegment,'int16=>double');
            
            DataIQ=reshape(Data_Vec_Interleaved.',2,[]).';
            %clear Data_Vec_Interleaved
            % Note I&Q are switched
            %Data_Vector_c=complex(DataIQ(:,2),DataIQ(:,1));
            %Data_Vector_c=complex(DataIQ(:,this.IQDirectionNum));
            Data_Vector_c=complex(DataIQ(:,this.IQDirectionNum(1)),DataIQ(:,this.IQDirectionNum(2)));
            %clear DataIQ
            else 
                Data_Vector_c=[];
            end
            %fclose(file_id);
            
            measData=Data_Vector_c*this.rfGain;
        end
        
        function this=seekNextPositionSamples(this)
                this.seekPositionSamples=this.seekPositionSamples+this.samplesPerSegment;  
        end
        
        function this=resetSignalFile(this)
            if this.fileID~= -1
                fids=fopen('all');
                if any(this.fileID==fids)
                fclose(this.fileID);
                end
            end
%             if ~isempty(this.measData)
%             this.measData=[];
%             end
        end
        
    end
    
end

