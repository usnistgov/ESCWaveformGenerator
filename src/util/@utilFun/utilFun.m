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
    end
    
end

