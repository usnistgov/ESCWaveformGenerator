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
classdef decimationExecutor<executor
    %Execute multiple signals using signalDecimator
    %Example:
    %        %inputFiles, outputFiles, and freqShifts must be in the same order
    %        numFiles=2;
    %        %cell array of input files
    %        inputFiles={'inputFilesPath\fileNo1.dat';'inputFilesPath\fileNo2.dat'};
    %        %cell array of output files
    %        outputFiles={'outputFilesPath\fileNo1.dat';'outputFilesPath\fileNo2.dat'};
    %        %vector of frequency shifts for each input file 
    %        freqShifts=[15e6;45e6];
    %        multiDec=decimationExecutor(numFiles);
    %        %turn On parallel run, otherwise turn Off for sequential run 
    %        multiDec.useParallel='On';
    %        multiDec=initParallel(multiDec);
    %        multiDec.inputFiles=inputFiles; %cell array of input files
    %        multiDec.outputFiles=outputFiles; %cell array of output files
    %        multiDec.freqShifts=freqShifts; 
    %        multiDec=runExecutor(multiDec);
    %see also signalDecimator, executor
    
    properties
        signals               signalDecimator
        inputFiles            cell
        outputFiles           cell
        freqShifts
    end
    
    properties(Constant)
        samplesPerSegment=144e4;
        initialSeekSamples=0;
        oldFs=225e6;
        newFs=25e6;
        %anti-aliasing filter coefficients, 
        filterSpec=struct('filtCoef',[-1.5911e-19 -5.136e-05 -0.00011054 -0.0001692 -0.00021713 ...
            -0.00024359 -0.00023907 -0.00019712 -0.00011603 ...
            4.1213e-19 0.00014048 0.0002891 0.0004253 0.00052671 ...
            0.00057223 0.00054548 0.00043795 0.00025158 -7.7659e-19 ...
            -0.00029165 -0.00058872 -0.00085062 -0.0010358 -0.0011078 ...
            -0.0010405 -0.00082381 -0.00046707 1.2461e-18 0.00052861 ...
            0.0010553 0.0015089 0.0018194 0.0019275 0.0017944 ...
            0.0014088 0.00079239 -1.7983e-18 -0.00088365 -0.0017521 ...
            -0.0024892 -0.0029833 -0.0031426 -0.0029099 -0.0022732 ...
            -0.0012726 2.3962e-18 0.0014072 0.00278 0.0039361 ...
            0.0047029 0.0049406 0.0045638 0.003558 0.0019885 ...
            -2.9915e-18 -0.0021941 -0.0043321 -0.0061332 -0.0073306 ...
            -0.0077075 -0.007129 -0.0055682 -0.0031195 3.5304e-18 ...
            0.0034653 0.0068726 0.0097809 0.011762 0.012455 0.011614 ...
            0.009157 0.0051854 -3.9606e-18 -0.0059137 -0.011918 ...
            -0.017277 -0.021221 -0.023026 -0.022089 -0.018 -0.010597 ...
            4.2383e-18 0.013379 0.028856 0.04552 0.062305 0.078075 ...
            0.091722 0.10226 0.10891 0.11119 0.10891 0.10226 0.091722 ...
            0.078075 0.062305 0.04552 0.028856 0.013379 4.2383e-18 ...
            -0.010597 -0.018 -0.022089 -0.023026 -0.021221 -0.017277 ...
            -0.011918 -0.0059137 -3.9606e-18 0.0051854 0.009157 ...
            0.011614 0.012455 0.011762 0.0097809 0.0068726 0.0034653 ...
            3.5304e-18 -0.0031195 -0.0055682 -0.007129 -0.0077075 ...
            -0.0073306 -0.0061332 -0.0043321 -0.0021941 -2.9915e-18 ...
            0.0019885 0.003558 0.0045638 0.0049406 0.0047029 ...
            0.0039361 0.00278 0.0014072 2.3962e-18 -0.0012726 ...
            -0.0022732 -0.0029099 -0.0031426 -0.0029833 -0.0024892 ...
            -0.0017521 -0.00088365 -1.7983e-18 0.00079239 0.0014088 ...
            0.0017944 0.0019275 0.0018194 0.0015089 0.0010553 ...
            0.00052861 1.2461e-18 -0.00046707 -0.00082381 -0.0010405 ...
            -0.0011078 -0.0010358 -0.00085062 -0.00058872 -0.00029165 ...
            -7.7659e-19 0.00025158 0.00043795 0.00054548 0.00057223 ...
            0.00052671 0.0004253 0.0002891 0.00014048 4.1213e-19 ...
            -0.00011603 -0.00019712 -0.00023907 -0.00024359 ...
            -0.00021713 -0.0001692 -0.00011054 -5.136e-05 -1.5911e-19]);
    end
    
    
    methods
        function  this=decimationExecutor(numFiles)
            this=this@executor(numFiles);
        end

        function signalDecimators=setupDecimators(this)
            %creates an array of signalDecimator instances 
            for I=1:this.numFiles
                signalDecimators(I)=signalDecimator(this.inputFiles{I},this.outputFiles{I},this.oldFs,this.newFs,this.freqShifts(I),this.filterSpec);
                signalDecimators(I).samplesPerSegment=this.samplesPerSegment;
            end
        end
        
        function this=set.inputFiles(this,inputFiles)
            if this.numFiles==length(inputFiles)
                this.inputFiles=inputFiles;
            else
                this.ERROR.inputFiles= MException('decimationExecutor:inputFiles', ...
                    'Number of input files must be equal to numFiles= %d',this.numFiles);
                throw(this.ERROR.inputFiles);
            end
        end
        
        function this=set.freqShifts(this,freqShifts)
            if this.numFiles==length(freqShifts)
                this.freqShifts=freqShifts;
            else
                this.ERROR.freqShifts= MException('decimationExecutor:freqShifts', ...
                    'Number of frequency shifts must be equal to numFiles= %d',this.numFiles);
                throw(this.ERROR.freqShifts);
            end
        end
        
        function this=set.outputFiles(this,outputFiles)
            if this.numFiles==length(outputFiles)
                this.outputFiles=outputFiles;
            else
                this.ERROR.outputFiles= MException('decimationExecutor:outputFiles', ...
                    'Number of output files must be equal to numFiles= %d',this.numFiles);
                throw(this.ERROR.outputFiles);
            end
        end

        function this=executeSequential(this)
            %generate signals sequentially
            try
                signalDecimators=setupDecimators(this);
                for I=1:this.numFiles
                    signalDecimators(I)=initDecimator(signalDecimators(I));
                    signalDecimators(I)=decimateFile(signalDecimators(I));
                    signalDecimators(I)=resetSignalDecimator(signalDecimators(I)); 
                end
                this.signals=signalDecimators;
            catch ME
                this.ERROR.executeSequential=ME;
            end
        end
        
        function this=executeParallel(this)
            %generate signals in parallel
            try
                signalDecimators=setupDecimators(this);
                parfor  I=1:this.numFiles
                    signalDecimators(I)=initDecimator(signalDecimators(I));
                    signalDecimators(I)=decimateFile(signalDecimators(I));
                    signalDecimators(I)=resetSignalDecimator(signalDecimators(I)); 
                end
                this.signals=signalDecimators;
            catch ME
                this.ERROR.executeParallel=ME;
            end
        end

    end
    
end

