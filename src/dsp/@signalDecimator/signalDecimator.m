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
            %Verify input file exists, throw error if they do not
              if (exist(inputFile,'file') ~= 2)
                  ME = MException('signalDecimator:invalidFile', ...
                      'Input file does not exist! Filename:\n%s\n\n',...
                      inputFile);
                  throw(ME);
              else
                  this.inputFile=inputFile;
              end
              
              %Verify output folder exists but individual files do not
              [filesPathDec,~,~]=fileparts(outputFile);
              if (exist(filesPathDec,'file') ~= 7)
                  ME = MException('testDecimate:invalidFile', ...
                      'Output folder does not exist!');
                  throw(ME);
              elseif (exist(outputFile,'file') == 2)
                  ME = MException('signalDecimator:invalidFile', ...
                      'Output file already exists! Filename:\n%s\n\n',...
                      outputFile);
                  throw(ME);
              else
                  this.outputFile=outputFile;
              end
            
            this.oldFs=oldFs;
            this.newFs=newFs;
            this.freqShift=freqShift;
            this.filterSpec=filterSpec;
        end
        
        function this=initDecimator(this)
            %NASCTN waveform files use QI format
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

