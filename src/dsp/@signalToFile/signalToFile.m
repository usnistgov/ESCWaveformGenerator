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

