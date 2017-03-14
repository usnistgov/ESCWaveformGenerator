classdef radarSignal
    %Radar Rsignal reader
    %   Read binary data from measurement files
    % Example usage:
    %     Radar_info_file='metaFile.xlsx';
    %     fileNo=1;
    %     metaFilePath='metaFileDir';
    %     radar_meta_file=fullfile(metaFilePath,Radar_info_file);
    %     files_path='measFilesDir';
    %     file_name='measFile.dat';
    %     file_path_name=fullfile(files_path,file_name);
    %
    %     testwaveform=radarSignal(file_path_name,radar_meta_file);
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
    %     measData=testwaveform.radarMeasData;

    
    properties (Access=protected)

        rfGain
        radarMeasFile
        radarMeasFileNum
        radarMetaFile
        radarFileID
        seekPositionSamples
        samplesPerSegment
        radarInfo
        radarWaveformInfo
        
    end
    properties (Access=public)
        radarMeasData
        
    end
    properties(Constant)
    bytesPerSample=4;
    end
    
    methods
        function Rsignal=radarSignal(radarMeasFile,radarMetaFile)
               
            if nargin > 0
                Rsignal.radarMeasFile=radarMeasFile;
                Rsignal.radarMetaFile=radarMetaFile;

            end
        end
        


        
        function Rsignal=setRadarMeasFile(Rsignal,radarMeasFile)
            Rsignal.radarMeasFile=radarMeasFile;
        end
                
        function Rsignal=setRadarMetaFile(Rsignal,radarMetaFile)
            Rsignal.radarMetaFile=radarMetaFile;
        end
        
        function Rsignal=setRadarMeasFileNum(Rsignal,radarMeasFileNum)
            Rsignal.radarMeasFileNum=radarMeasFileNum;
        end
        
        function Rsignal=setSeekPositionSamples(Rsignal,seekPositionSamples)
            Rsignal.seekPositionSamples=seekPositionSamples;
        end
        
        function Rsignal=setSamplesPerSegment(Rsignal,samplesPerSegment)
            Rsignal.samplesPerSegment=samplesPerSegment;
        end

         function Rsignal=setRfGain(Rsignal,rfGain)
            if nargin<2 
                
            Rsignal.rfGain=Rsignal.radarInfo.ADCscalefactorFADC(Rsignal.radarMeasFileNum)/10.6;
            else 
                Rsignal.rfGain=rfGain;
            end
         end
     
        function radarWaveformInfo=getRadarWaveformInfo(Rsignal)
        radarWaveformInfo.rfGain=Rsignal.rfGain;
        radarWaveformInfo.radarMeasFile=Rsignal.radarMeasFile;
        radarWaveformInfo.radarMeasFileNum=Rsignal.radarMeasFileNum;
        radarWaveformInfo.radarMetaFile=Rsignal.radarMetaFile;
        radarWaveformInfo.radarFileID=Rsignal.radarFileID;
        radarWaveformInfo.seekPositionSamples=Rsignal.seekPositionSamples;
        radarWaveformInfo.samplesPerSegment=Rsignal.samplesPerSegment;
        radarWaveformInfo.radarInfo=Rsignal.radarInfo;
        radarWaveformInfo.radarFileID=Rsignal.radarFileID;
        end
        
        function Rsignal=readRadarMeta(Rsignal)
            %% Import the data
            if exist(Rsignal.radarMetaFile, 'file') == 2
            [~, ~, raw] = xlsread(Rsignal.radarMetaFile,'Sheet1','','basic');
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
            Rsignal.radarInfo=radarinfo;
            %% Clear temporary variables
            clearvars data raw cellVectors R;
            else
             Rsignal.radarInfo=[-1];   
            end
        end
        
        function Rsignal=initRadarFile(Rsignal)
            %errmsg = '';
            if isfield(Rsignal,'radarFileID') && Rsignal.radarFileID>=3
                fclose(Rsignal.radarFileID);
            end
            
            if exist(Rsignal.radarMeasFile, 'file') == 2
            [ FileID,errmsg]=fopen(Rsignal.radarMeasFile,'r','l','UTF-8');
            else
                errmsg='file does not exist';
            end
            
            if isempty(errmsg)
                Rsignal.radarFileID=FileID;
            end
        end
        
        function Rsignal = readRadarMeasData(Rsignal)
            %
            %[file_id,~]=fopen(file_path_name,'r','l','UTF-8');
            
            seekPosition=Rsignal.bytesPerSample*Rsignal.seekPositionSamples;
            status=fseek( Rsignal.radarFileID,seekPosition,'bof'); %return 0 if success, o.w. -1
%             if res == -1
%                 Data_Vec_Interleaved = [];
%                 %close(file_id);
%                 %return;
%             end
            
            if ~status
            Data_Vec_Interleaved=fread(Rsignal.radarFileID,2*Rsignal.samplesPerSegment,'int16=>double');
            
            DataIQ=reshape(Data_Vec_Interleaved.',2,[]).';
            clear Data_Vec_Interleaved
            % Note I&Q are switched
            Data_Vector_c=complex(DataIQ(:,2),DataIQ(:,1));
            
            clear DataIQ
            else 
                Data_Vector_c=[];
            end
            %fclose(file_id);
            
            Rsignal.radarMeasData=Data_Vector_c*Rsignal.rfGain;
        end
        
        function Rsignal=seekNextPositionSamples(Rsignal)
                Rsignal.seekPositionSamples=Rsignal.seekPositionSamples+Rsignal.samplesPerSegment;  
        end
        
        function resetSignal(Rsignal)
            if Rsignal.radarFileID~= -1  
                fclose(Rsignal.radarFileID);
            end
            if ~isempty(Rsignal.radarMeasData)
            Rsignal.radarMeasData=[];
            end
        end
        
    end
    
end

