classdef signalDecimator<radarSignalFromFile & signalToFile
    %signal decimator class
    %read radar waveform file, decimate and save it to a file
    %Example:
    %       filterSpec.filtCoef=.....; % anti-aliasing filter coefficients vector
    %       %Construct a signal decimator with appropriate parameters
    %       signalDec=signalDecimator(inputFile,outputFile,oldFs,newFs,freqShift,filterSpec);
    %       %Intitiate signal decimator
    %       signalDec=initDecimator(signalDec);
    %       %Start decimating the file
    %       signalDec=decimateFile(signalDec);
    %       %Close input and output files
    %       signalDec=resetSignalDecimator(signalDec);
    %see also radarSignalFromFile, signalToFile
    
    properties
        signalDecimatorError
        
    end
    properties (Access=protected)
        oldFs
        newFs
        freqShift
        filterSpec
    end
    
    methods
        function this=signalDecimator(inputFile,outputFile,oldFs,newFs,freqShift,filterSpec)
            this.inputFile=inputFile;
            
            this.outputFile=outputFile;
            
            this.oldFs=oldFs;
            this.newFs=newFs;
            this.freqShift=freqShift;
            this.filterSpec=filterSpec;
        end
        function this=initDecimator(this)
            %I&Q were swapped in the orignal NASCTN waveform files 
            this.inputIQDirection='QI';
            %Switch output files to I&Q
            this.outputIQDirection='IQ';
            this.EOFAction='Rnormal';
            %this.samplesPerSegment=samplesPerSegment;
            initialSeekSamples=0;
            this=setSeekPositionSamples(this,initialSeekSamples);
            this=setReadScale(this,1);
            this=initInputFile(this);
            this=setWriteScale(this,1);
            this=initOutputFile(this);

        end
        function this=decimateFile(this)
                % disp(this)
                 signalTime=getSignalTime(this);
                 numOfSegments=floor(signalTime.totalNumberOfSamples/this.samplesPerSegment);
                 leftOverSamples=0;
                 numOfSegmentsWithLeftOver=numOfSegments;
                 if signalTime.totalNumberOfSamples>numOfSegments*this.samplesPerSegment
                     leftOverSamples=signalTime.totalNumberOfSamples-numOfSegments*this.samplesPerSegment;
                 end
                 if leftOverSamples>0
                     numOfSegmentsWithLeftOver=numOfSegments+1;
                 end
                 filterRESET=false;
                 t0=0;
                 for I=1:numOfSegmentsWithLeftOver
                     if (I==numOfSegmentsWithLeftOver) && (numOfSegmentsWithLeftOver~=numOfSegments)
                         this.samplesPerSegment=leftOverSamples;
                     end
                     sigMeas =readSamples(this);
                     
                     t=((0:this.samplesPerSegment-1).')*(1/this.oldFs)+t0;
                     this=seekNextPositionSamples(this);
                     sigMeasShifted=sigMeas.*exp(-1i*2*pi*(this.freqShift)*t);
                     [sigResampled,~]=dspFun.resampleFilt(sigMeasShifted,this.oldFs,this.newFs,filterRESET,this.filterSpec);
                     writeSamples(this,sigResampled);
                     t0=t(end)+1/this.oldFs;
                     
%                      testVar(I,1)=length(sigMeas);
%                      testVar(I,2)=length(t);
%                      testVar(I,3)=length(sigMeasShifted);
%                      testVar(I,4)=length(sigResampled);
                 end
%                  save([this.outputFile,'Vars.mat'],'testVar','signalTime','numOfSegments','numOfSegmentsWithLeftOver',...
%                      'leftOverSamples');
        end
        function this=resetSignalDecimator(this)
            this=resetSignalFromFile(this);
            this=resetSignalToFile(this);

        end
        
    end
    
end

