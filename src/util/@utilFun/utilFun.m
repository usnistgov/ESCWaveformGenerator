classdef utilFun
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
    end
    
    methods (Access = public, Static = true)
        
        function logicR=enable2Logic(OnOffIn)
            possIn={'On','Off'};
            if ismember(OnOffIn,possIn)
                switch OnOffIn
                    case 'On'
                        logicR=true;
                    case 'Off'
                        logicR=false;
                end
            else
                ME = MException('utilFunenable2Logic:invalidInput', ...
                    'Input must be one of these values: %s',strjoin(possIn));
                throw(ME);
            end
        end
        
        function enableR=logic2Enable(logicIn)
            if islogical(logicIn)
                switch logicIn
                    case true
                        enableR='On';
                    case false
                        enableR='Off';
                end
            else
                ME = MException('utilFunlogic2Enable:invalidInput', ...
                    'Input must be logical');
                throw(ME);
            end
        end
        
        function sortedCell=sortByNunbers(unsortedCell)
            digits=regexp(unsortedCell,'\d');
            values=zeros(length(unsortedCell),1);
            for I=1:length(unsortedCell)
                values(I)=str2double(unsortedCell{I}(digits{I}));
            end
            [~,I]=sort(values);
            sortedCell=unsortedCell(I);
        end
        
        function durationCh=sec2DurationChar(tsec)
            displayFormat='hh:mm:ss.SSS';
            runtime=duration(0,0,tsec,'Format',displayFormat);
            durationCh=sprintf('%s',runtime);
        end
        
        function [waveformStruct,waveformFilePath,waveformMapStruct]=readWaveformJsonDir(inputDir)
            % usage
            % inputDir='D:\Spectrum-Share\SanDiegoMixedWaveformsTestV9';
            % [waveformStruct9,waveformFilePath9,waveformMapStruct9]=utilFun.readWaveformJsonDir(inputDir)
            % waveformTable9=struct2table(waveformStruct9);
            % SIRdBmax=cell2mat(waveformTable9.('SIRdBmax').').';
            % SIRdBmin=cell2mat(waveformTable9.('SIRdBmin').').';
            % SIRdBmean=cell2mat(waveformTable9.('SIRdBmean').').';
            % targetSIR=waveformTable9.('targetSIR');
            % figure;plot(targetSIR,'d');hold on ;plot(SIRdBmax,'h');legend('targetSIR','SIRdBmax1','SIRdBmax2');hold off;
            jsonFiles=dir(fullfile(inputDir,'\*.json'));
            datFiles=dir(fullfile(inputDir,'\*.dat'));
            jsonFilesCell=struct2cell(jsonFiles);
            jsonFilesCell=jsonFilesCell(1,:).';
            jsonFilesCellNoExt = cellfun(@(x) x(1:end-length('.json')), jsonFilesCell, 'un', 0);
            jsonFilesCellMap = cellfun(@(x) x(end-length('Map')+1:end), jsonFilesCellNoExt, 'un', 0) ;
            for I=1:length(datFiles)
                %if ~strcmp(jsonFiles(I).name(end-length('Map.json')+1:end-length('.json')),'Map')
                datHasJSON=ismember(jsonFilesCellNoExt,datFiles(I).name(1:end-length('.dat')));
                if  any(datHasJSON)
                    jsonText=fileread(fullfile(inputDir,char(jsonFilesCell(datHasJSON))));
                    waveformStruct(I,1)=jsondecode(jsonText);
                    waveformFilePath{I,1}=fullfile(inputDir,datFiles(I).name);
                end
            end
            dirHasJSONMap=ismember(jsonFilesCellMap,'Map');
            if any(dirHasJSONMap)
                jsonText=fileread(fullfile(inputDir,char(jsonFilesCell(dirHasJSONMap))));
                waveformMapStruct=jsondecode(jsonText);
            else
                waveformMapStruct=[];
            end
        end
    end
    
end

