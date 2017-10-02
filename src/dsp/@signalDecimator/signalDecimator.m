classdef signalDecimator<radarSignalFromFile & signalToFile
    %signal decimator class
    %   read radar signal, decimate and save to a file
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
        function this=initDecimator(this,initialSeekSamples,samplesPerSegment)
%            this=setMeasFile(this);
            this.inputIQDirection='QI';
            this.outputIQDirection='IQ';
            this.EOFAction='Rnormal';
            this.samplesPerSegment=samplesPerSegment;
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
                 filterRESET=0;
                 t0=0;
                 for I=1:numOfSegmentsWithLeftOver
                     if (I==numOfSegmentsWithLeftOver) && (numOfSegmentsWithLeftOver~=numOfSegments)
                         this.samplesPerSegment=leftOverSamples;
                     end
                     sigMeas =readSamples(this);
                     t=((0:this.samplesPerSegment-1).')*(1/this.oldFs)+t0;
                     this=seekNextPositionSamples(this);
                     sigMeasShifted=sigMeas.*exp(1i*2*pi*(this.freqShift)*t);
                     [sigResampled,~]=dspFun.resampleFilt(sigMeasShifted,this.oldFs,this.newFs,filterRESET,this.filterSpec);
                     writeSamples(this,sigResampled);
                     t0=t(end)+1/this.oldFs;
                 end
        end
        function this=resetSignalDecimator(this)
            this=resetSignalFromFile(this);
            this=resetSignalToFile(this);

        end
        
    end
    
end

