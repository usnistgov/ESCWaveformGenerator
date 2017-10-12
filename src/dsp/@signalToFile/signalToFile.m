classdef signalToFile
    %Save signal to a file:
    %              writeScale: sacle signal before saving
    %              outputFile: output file name
    % Example:
    %     signalSeg1=sqrt(1e-5/2)complex(randn(1000,1),randn(1000,1));
    %     signalSeg2=sqrt(1e-5/2)complex(randn(1000,1),randn(1000,1));
    %     writeScaleFactor=1e5;
    %     saveToFile=signalToFile('test','QI');
    %     saveToFile=setWriteScale(saveToFile,writeScaleFactor);
    %     saveToFile=initOutputFile(saveToFile);
    %     writeSamples(saveToFile,signalSeg1); % write one segment to a file
    %     writeSamples(saveToFile,signalSeg2); % write next segment to the same file
    %     saveToFile=resetSignalToFile(saveToFile); % close opened file
    
    properties (Access=protected)
        writeScale
        outputFile
        outputFileID
    end
    
    properties (Access=private)
        outputIQDirectionNum
    end
    
    properties (Access=public)
        %measData
        
%        fileName
%        samplesPerSegment
        outputIQDirection
        signalToFileERROR
    end
    
    properties(Constant)
        
    end
    
    methods
        function this=signalToFile(OutputFile,outputIQDirection)
            switch nargin
                case 0
                    this.outputIQDirection='IQ'; %default
                case 1
                    %set default IQ direction
                    this.outputIQDirection='IQ';
                    this.outputFile=OutputFile;
                case 2
                    this.outputIQDirection=outputIQDirection;
                    this.outputFile=OutputFile;
                    
            end
            
        end
        
        function this=setOutputFile(this,OutputFile)
            this.outputFile=OutputFile;
        end
        
        function this=setWriteScale(this,writeScale)
            this.writeScale=writeScale;
        end
        
        function this=set.outputIQDirection(this,outputIQDirection)
            outputIQDirectionOptions={'IQ','QI'};
            if ismember(outputIQDirection,outputIQDirectionOptions)
                this.outputIQDirection=outputIQDirection;
            else
                this.signalToFileERROR.outputIQDirection= MException('signalToFile:outputIQDirection', ...
                    'outputIQDirection must be one of these options: %s',strjoin(outputIQDirectionOptions));
                throw(this.signalToFileERROR.outputIQDirection);
            end
            
        end
        
        function this=initOutputFile(this)
                        switch this.outputIQDirection
                            case 'IQ'
            
                                this.outputIQDirectionNum=[1 2];
                            case 'QI'
                                this.outputIQDirectionNum=[2 1];
                        end
            [SaveSignalFileId,errmsg_write]=fopen(this.outputFile,'w','l','UTF-8');
            if isempty(errmsg_write)
                this.outputFileID=SaveSignalFileId;
%                this.fileName=this.outputFile;
            else
                this.signalToFileERROR.initFile=errmsg_write;
            end
        end
        
        function writeSamples(this,signalIn)
            dataOut(:,this.outputIQDirectionNum(1))=real(signalIn*this.writeScale); %simple scaling
            dataOut(:,this.outputIQDirectionNum(2))=imag(signalIn*this.writeScale); %simple scaling
            dataOutInterleaved=reshape(dataOut.',[],1);
            fwrite(this.outputFileID,dataOutInterleaved,'int16');
        end
        
        function this=resetSignalToFile(this)
            if this.outputFileID~= -1
                fids=fopen('all');
                if any(this.outputFileID==fids)
                    fclose(this.outputFileID);
                end
            end
            
        end
        
    end
end

