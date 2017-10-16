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
            datHasJSONIndx=0;
            for I=1:length(datFiles)
                %if ~strcmp(jsonFiles(I).name(end-length('Map.json')+1:end-length('.json')),'Map')
                datHasJSON=ismember(jsonFilesCellNoExt,datFiles(I).name(1:end-length('.dat')));
                if  any(datHasJSON)
                    datHasJSONIndx=datHasJSONIndx+1;
                    jsonText=fileread(fullfile(inputDir,char(jsonFilesCell(datHasJSON))));
                    waveformStruct(datHasJSONIndx,1)=jsondecode(jsonText);
                    waveformFilePath{datHasJSONIndx,1}=fullfile(inputDir,datFiles(I).name);
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
        
        function [hasLicense,err]=licenseCheck(licenseName)
            %checks for existance of license (unless compiled)
            %attempts to checkout license
            
            licTest=license( 'test' , licenseName);
            err='';
            hasLicense=false; %assume no license
            if (ismcc || isdeployed)
                hasLicense = true;
            else
                if licTest
                    %You own this license (license found)
                    licCheckout=license( 'checkout' , licenseName);
                    if licCheckout
                        hasLicense=true;
                    else
                        err=sprintf('All license are in use for %s',licenseName);
                    end
                else
                    err=sprintf('You do not have the toolbox %s',licenseName);
                end
            end
        end
    end
    
end

