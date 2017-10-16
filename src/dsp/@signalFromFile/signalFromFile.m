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

classdef signalFromFile
    %IQ data signal reader
    %   Read binary data from measurement files
    % Example usage:
    %     files_path='C:\measFilesDir';
    %     file_name='measFile.dat';
    %     measFile=fullfile(files_path,file_name);
    %
    %     testwaveform=signalFromFile(measFile,'IQ');
    %     testwaveform=setreadScale(testwaveform,1);
    %     testwaveform=initInputFile(testwaveform);
    %     seekPositionSamples=0;
    %     testwaveform=setSeekPositionSamples(testwaveform,seekPositionSamples);
    %     samplesPerSegment=50e3;
    %     testwaveform=setSamplesPerSegment(testwaveform,samplesPerSegment);
    %     ------
    %     measData1=readSamples(testwaveform);
    %     testwaveform=seekNextPositionSamples(testwaveform);  
    %     measData2=readSamples(testwaveform);
    %     -------
    %     testwaveform=resetSignalFromFile(testwaveform); % close opened file

    
    properties (Access=protected)
        readScale
        inputFile
        inputFileID
%        radarMetaFile
        seekPositionSamples
        signalFromFileInfo
%        radarInfoTable
    end
    properties (Access=private)
    inputIQDirectionNum
    end
    properties (Access=public)
        samplesPerSegment
        inputIQDirection
        EOFAction % fills the remaining samples with zeros or Return zeros size samplesPerSegment(default): 'Rzeros', rewind to bof: 'Rewind', Return empty []: 'Rempty' 
        signalFromFileERROR
    end

    properties(Constant)
    bytesPerSample=4;
    %combinedFrontEndGain=10.6;
   % combinedFrontEndGain=sqrt(db2pow(19.8)); % San Diego release 
   % combinedFrontEndGain=sqrt(db2pow(22.2)); % Virginia Beach release
 %  combinedFrontEndGain=1;
    end
    
    methods
       % function this=signalFromFile(inputFileName,inputIQDirection,EOFAction,radarMetaFile)
        function this=signalFromFile(InputFile,inputIQDirection,EOFAction)    
            switch nargin
                case 0
                    %set default IQ direction
                    this.inputIQDirection='QI';
                    %set default EOF action
                    this.EOFAction='Rzeros';
                case 1
                    this.inputFile=InputFile;
                    %set default IQ direction
                    this.inputIQDirection='QI';
                    %set default EOF action
                    this.EOFAction='Rzeros';
                case 2
                    this.inputFile=InputFile;
                    this.inputIQDirection=inputIQDirection;
                    %set default EOF action
                    this.EOFAction='Rzeros';
                case 3
                    this.inputFile=InputFile;
                    this.inputIQDirection=inputIQDirection;
                    this.EOFAction=EOFAction;
            end

            
        end
        


        
        function this=setInputFile(this,InputFile)
            this.inputFile=InputFile;
        end
                
        
        function this=setSeekPositionSamples(this,seekPositionSamples)
            this.seekPositionSamples=seekPositionSamples;
        end
        
        function this=set.samplesPerSegment(this,samplesPerSegment)
            if ~isempty(this.inputFile)
             signalTime=getSignalTime(this);
            if samplesPerSegment<=floor(signalTime.totalNumberOfSamples) && samplesPerSegment>=1
            this.samplesPerSegment=samplesPerSegment;
            else
              this.signalFromFileERROR.samplesPerSegment= MException('signalFromFile:samplesPerSegment', ...
                    'samplesPerSegment must be >=1 and <= %d',floor(signalTime.totalNumberOfSamples));
                throw(this.signalFromFileERROR.samplesPerSegment);
            end
            else
                this.samplesPerSegment=samplesPerSegment;
            end
        end
        
        function this=set.EOFAction(this,EOFAction)
            EOFActionOptions={'Rzeros','Rewind','Rempty','Rnormal'};
            if ismember(EOFAction,EOFActionOptions)
            this.EOFAction=EOFAction;
            else
                this.signalFromFileERROR.EOFAction= MException('signalFromFile:EOFActionInitialization', ...
                    'EOFAction must be one of these options: %s',strjoin(EOFActionOptions));
                throw(this.signalFromFileERROR.EOFAction);
            end
        end
        
        function this=set.inputIQDirection(this,inputIQDirection)
            inputIQDirectionOptions={'IQ','QI'};
            if ismember(inputIQDirection,inputIQDirectionOptions)
                this.inputIQDirection=inputIQDirection;
            else
                this.signalFromFileERROR.inputIQDirection= MException('signalFromFile:inputIQDirection', ...
                    'inputIQDirection must be one of these options: %s',strjoin(inputIQDirectionOptions));
                throw(this.signalFromFileERROR.inputIQDirection);
            end
            
        end

         function this=setReadScale(this,readScale)
                 this.readScale=readScale;
         end
         
         function seekPositionSamples=getSeekPositionSamples(this)
             seekPositionSamples=this.seekPositionSamples;
         end

         
        function signalFromFileInfo=getSignalInfo(this)
        signalFromFileInfo.readScale=this.readScale;
        signalFromFileInfo.inputFile=this.inputFile;
        signalFromFileInfo.inputFileID=this.inputFileID;
        signalFromFileInfo.seekPositionSamples=this.seekPositionSamples;
        signalFromFileInfo.samplesPerSegment=this.samplesPerSegment;
        end
        
        function signalTime=getSignalTime(this,Fs)
            if ~isempty(this.inputFile)
                 fInfo=dir(this.inputFile);
                 signalTime.totalNumberOfSamples=round(fInfo.bytes/this.bytesPerSample);
                 if nargin >1
                 signalTime.timeSec=signalTime.totalNumberOfSamples*1/Fs;
                 end
            else
                signalTime=[];
            end
        
        end
        
        function this=initInputFile(this)
            %errmsg = '';
            switch this.inputIQDirection
                case 'IQ'
                    
                    this.inputIQDirectionNum=[1 2];
                case 'QI'
                    this.inputIQDirectionNum=[2 1];
            end

            if isfield(this,'inputFileID') && this.inputFileID>=3
                fclose(this.inputFileID);
            end
            
            if exist(this.inputFile, 'file') == 2
            [ InputFileID,errmsg]=fopen(this.inputFile,'r','l','UTF-8');
            else
                errmsg='file does not exist';
            end
            
            if isempty(errmsg)
                this.inputFileID=InputFileID;
            end
        end
        
        function samplesData = readSamples(this)
            seekPosition=this.bytesPerSample*this.seekPositionSamples;
            status=fseek( this.inputFileID,seekPosition,'bof'); %return 0 if success, o.w. -1   
            % rewind if eof and EOF action is Rwind 
            [Data_Vec_Interleaved,count]=fread(this.inputFileID,2*this.samplesPerSegment,'int16=>double');
            % we always request even number of data bc of IQ
            % if file is not standard, check last segment
            if feof(this.inputFileID)
                    if mod(count,2) % if count is odd ignore last value
                        Data_Vec_Interleaved=Data_Vec_Interleaved(1:end-1);
                        count=count-1;
                    end
                
                    switch this.EOFAction
                        case 'Rzeros'
                            % pad with zeros the rest of the array or return zeros
                            Data_Vec_Interleaved=[Data_Vec_Interleaved;zeros(2*this.samplesPerSegment-count,1)];
                            %Data_Vec_Interleaved= padarray(Data_Vec_Interleaved,[2*this.samplesPerSegment-count,0],'post');
                        case 'Rempty' % in this case empty last segment
                            if count~=2*this.samplesPerSegment
                            Data_Vec_Interleaved=[];
                            end
                        case 'Rewind'
                            frewind(this.inputFileID)
                            % set seek position to zero
                            [Data_Vec_Interleaved1,~]=fread(this.inputFileID,2*this.samplesPerSegment-count,'int16=>double');
                            Data_Vec_Interleaved=[Data_Vec_Interleaved;Data_Vec_Interleaved1];
                            % set seek position so when
                            % seekNextPositionSamples() is called, seek
                            % position is adjusted
                            this=setSeekPositionSamples(this,count/2-this.samplesPerSegment);
                        case 'Rnormal' % do nothing
                        otherwise
                            this.signalFromFileERROR.signalFromFile= MException('signalFromFile:EOFAction', ...
                                'EOF action not set properly');
                            throw(this.signalFromFileERROR.readSamples);
                            
                    end
              
            end
            DataIQ=reshape(Data_Vec_Interleaved.',2,[]).';
            % Note I&Q are switched in some radar meas files
            Data_Vector_c=complex(DataIQ(:,this.inputIQDirectionNum(1)),DataIQ(:,this.inputIQDirectionNum(2)));
            samplesData=Data_Vector_c*this.readScale;
        end
        
        function this=seekNextPositionSamples(this)
                this.seekPositionSamples=this.seekPositionSamples+this.samplesPerSegment;  
        end
        
        
        function this=resetSignalFromFile(this)
            if this.inputFileID~= -1
                fids=fopen('all');
                if any(this.inputFileID==fids)
                fclose(this.inputFileID);
                end
            end

        end
        
    end
    
end

