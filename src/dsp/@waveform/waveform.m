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
classdef waveform 
    %waveform generator combines radar signal from file and LTE signal
    %  parameters:
    %             Radar,LTE , adjacent band interference (ABI), and AWGN
    %             Status, Start time, Gain, freq offset 
    %             LTE channel
    %             gain estimate method: fixed power levels, target SIR
    % Two modes of operations:
    %                         Dynamic, generate a signal in segments
    %                         Static, generate full waveform and save it to a file
    % See also, signalFromFile, radarSignalFromFile, signalToFile, threeGPPChannel
    
    properties
        Fs
        samplesPerSegment
        totalTime
        numRadarSignals      %number of Radar Signals
        radarStatus          logical%radar status
        radarStartTime
        radarSignal          radarSignalFromFile
        radarGain            %Radar gain
        radarFreqOffset      %Radar freq offeset MHz
        numLTESignals
        LTEStatus            logical%vector row logic [LTE1 LTE2]
        LTEStartTime
        LTESignal            signalFromFile
        LTEGain              %LTE gain vector row size numLTESignals
        LTEFreqOffset        %LTE freq offeset vector [f1 f2]
        LTEChState           logical% logical scalar enable disbale 3gpp channel effect
        LTEChType            cell
        LTEChannel           threeGPPChannel
        numABISignals
        ABIStatus            logical% Adjacent Band Interference
        ABIStartTime
        ABISignal            radarSignalFromFile
        ABIGain              %ABI gain
        ABIFreqOffset        %ABI freq offeset MHz
        AWGNStatus           logical%AWGN channel status
        AWGNVar              %noise variance
        writeScaleFactor      %save scale factor
        %        saveWaveformFileId
        waveformToFile       signalToFile
        success
        gainEstimateMethod   char
        PowerLevels_dBm      struct
        targetSIR
        measParameters       struct        
        SIRdBmin
        SIRdBmax
        SIRdBmean
        SIRData
        signalOut
        errorColl
    end
    
    properties (Access=private)
        waveformFilepath
    end

    properties(Constant,Access=private)
        LTEBw=9e6;
        numLTEwindows=1;
        P_KTB_dB=-174-30;
        referenceLoad=50;
        peakPowerThreshold_dB=-89-30;
    end
    
    methods
        function this=waveform(Fs)  
            %Initialize waveform object
            if nargin > 0
                this.Fs=Fs;
            end
            this.measParameters=struct('SIRWindow',[],'SIRBw',[]);%struct('radarPeakPower_dBm',[],'LTEPower_dBm',[],'ABIAdjust_dB',[],'AWGNPSD_dBm',[],
            this.PowerLevels_dBm=struct('RadarPeakPower',[],'LTEPower',[],'ABIPower',[],'AWGNPSD',[]);
        end
        
        function this=set.Fs(this,Fs)
            this.Fs=Fs;
        end
        
        function this=set.samplesPerSegment(this,samplesPerSegment)
            this.samplesPerSegment=samplesPerSegment;
        end
        function this=set.totalTime(this,totalTime)
            this.totalTime=totalTime;
        end
        
        function this=set.numRadarSignals(this,numRadarSignals)
            this.numRadarSignals=numRadarSignals;
        end
        function this=set.numLTESignals(this,numLTESignals)
            this.numLTESignals=numLTESignals;
        end
        function this=set.numABISignals(this,numABISignals)
            this.numABISignals=numABISignals;
        end
        
        function this=set.radarStartTime(this,radarStartTime)
            this.radarStartTime=radarStartTime;
        end
        function this=set.LTEStartTime(this,LTEStartTime)
            this.LTEStartTime=LTEStartTime;
        end
        function this=set.ABIStartTime(this,ABIStartTime)
            this.ABIStartTime=ABIStartTime;
        end
        
        function this=set.targetSIR(this,targetSIR)
            this.targetSIR=targetSIR;
        end
        
        function this=set.radarStatus(this,radarStatus)
            this.radarStatus=radarStatus;
        end
        function this=set.LTEStatus(this,LTEStatus)
            this.LTEStatus=LTEStatus;
        end
        function this=set.AWGNStatus(this,AWGNStatus)
            this.AWGNStatus=AWGNStatus;
        end
        
        function this=set.radarFreqOffset(this,radarFreqOffset)
            this.radarFreqOffset=radarFreqOffset;
        end
        function this=set.LTEFreqOffset(this,LTEFreqOffset)
            this.LTEFreqOffset=LTEFreqOffset;
        end
        function this=set.ABIFreqOffset(this,ABIFreqOffset)
            this.ABIFreqOffset=ABIFreqOffset;
        end
        
        function this=set.radarGain(this,radarGain)
            this.radarGain=radarGain;
        end
        function this=set.LTEGain(this,LTEGain)
            this.LTEGain=LTEGain;
        end
        function this=set.ABIGain(this,ABIGain)
            this.ABIGain=ABIGain;
        end
        
        function this=set.AWGNVar(this,AWGNVar)
            this.AWGNVar=AWGNVar;
        end
%%        
        function this=setupRadarSignal(this,radarMeasFiles,radarMetaFile,radarSeekPositionSamples,readScale)
            %Initialize radar signals from files
            IQDirection='QI';
            EOFAction='Rzeros';
            
            if length(radarMeasFiles)~=this.numRadarSignals
                error('waveform:RadarSignal',...
                    'Error. \n number radarMeasFiles does not match numRadarSignals');
            end
            
            if nargin<4
                % set default seek position to zero
                radarSeekPositionSamples=zeros(size(1,this.numRadarSignals));
            end
            
            for I=1:this.numRadarSignals
                this.radarSignal(I)=radarSignalFromFile(radarMeasFiles{I},IQDirection,EOFAction,radarMetaFile);
                this.radarSignal(I).samplesPerSegment=this.samplesPerSegment;
                
                if nargin>4
                    this.radarSignal(I)=setReadScale(this.radarSignal(I),readScale);
                else
                    this.radarSignal(I)=setReadScale(this.radarSignal(I));
                end
                
                this.radarSignal(I)=initInputFile(this.radarSignal(I));
                this.radarSignal(I)=setSeekPositionSamples(this.radarSignal(I),radarSeekPositionSamples(I));
                
                %check if peak file exist for each radar signal
                pksFileName=strcat(radarMeasFiles{I}(1:end-length('dec01.dat')),'pks.mat');
                if  (exist(pksFileName, 'file') == 2)
                    this.SIRData(I).original=load(pksFileName);
                end
            end
            
        end
 
        function this=setupABISignal(this,ABIMeasFiles,ABIMetaFile,ABIseekPositionSamples,readScale)
            %Initialize Adjacent Band Interference (radar 3) signals from files
            IQDirection='QI';
            EOFAction='Rzeros';
            if length(ABIMeasFiles)~=this.numABISignals
                error('waveform:RadarSignals',...
                    'Error. \n number ABIMeasFiles does not match numABISignals');
            end
            
            if nargin<4
                % set default seek position to zero
                ABIseekPositionSamples=zeros(size(1,this.numABISignals));
            end
            
            for I=1:this.numABISignals
                this.ABISignal(I)=radarSignalFromFile(ABIMeasFiles{I},IQDirection,EOFAction,ABIMetaFile);
                this.ABISignal(I).samplesPerSegment=this.samplesPerSegment;
                
                if nargin>4
                    this.ABISignal(I)=setReadScale(this.ABISignal(I),readScale);
                else
                    this.ABISignal(I)=setReadScale(this.ABISignal(I));
                end
                
                this.ABISignal(I)=initInputFile(this.ABISignal(I));
                this.ABISignal(I)=setSeekPositionSamples(this.ABISignal(I),ABIseekPositionSamples(I));
            end
            
        end
        
        function this=setupLTESignal(this,LTESignalPaths,LTEReadScale,LTEseekPositionSamples)
            %Initialize LTE signals from files
            IQDirection='IQ';
            if length(LTESignalPaths)~=this.numLTESignals || length(LTEReadScale)~=this.numLTESignals
                error('waveform:LTESignal',...
                    'Error. \n number LTESignalPaths and/or LTEReadScale does not match numLTESignals');
            end
            
            if nargin<4
                % set default seek position to zero
                LTEseekPositionSamples=zeros(size(1,this.numLTESignals));
            end
            
            for I=1:this.numLTESignals
                this.LTESignal(I)=signalFromFile(LTESignalPaths{I},IQDirection);
                this.LTESignal(I).samplesPerSegment=this.samplesPerSegment;
                this.LTESignal(I)=setReadScale(this.LTESignal(I),LTEReadScale(I));
                this.LTESignal(I)=initInputFile(this.LTESignal(I));
                this.LTESignal(I)=setSeekPositionSamples(this.LTESignal(I),LTEseekPositionSamples(I));
            end
            
        end
       
        function this=setupLTEChannel(this)
            %Set LTE channel for each LTE signal
            if ~isempty(this.Fs)|| ~isempty(this.numLTESignals) || ~isempty(this.LTEChType)
                % Requires sampling rate number of LTE signal and LTE
                % channel type before initialization
                if length(this.LTEChType) == this.numLTESignals
                    this.LTEChannel=threeGPPChannel(this.Fs,this.numLTESignals,this.LTEChType);
                    this.LTEChannel=initCh(this.LTEChannel);
                else
                    error('waveform:LTESignal',...
                        'Error. \n length(LTEChType) does not equal numLTESignals');
                end
                
            else
                error('waveform:LTESignal',...
                    'Error. \n One or more variable is not set: Fs , numLTESignals, LTEChType');
            end
        end
%%        
        function this=updateSamplesPerSegment(this)
            %Update samples per segment for each signal
            for I=1:this.numLTESignals
                this.LTESignal(I).samplesPerSegment=this.samplesPerSegment;
            end
            
            for I=1:this.numRadarSignals
                this.radarSignal(I).samplesPerSegment=this.samplesPerSegment;
            end
            
            for I=1:this.numABISignals
                this.ABISignal(I).samplesPerSegment=this.samplesPerSegment;
            end
        end
        
        function this=setupWaveformToFile(this,waveformFilepath)
            %Initialize waveform output file 
            IQDirection='IQ';
            this.waveformFilepath=waveformFilepath;
            this.waveformToFile=signalToFile(waveformFilepath,IQDirection);
            this.waveformToFile=setWriteScale(this.waveformToFile,this.writeScaleFactor);
            this.waveformToFile=initOutputFile(this.waveformToFile);
        end
        
        function this=setStatus(this,radarStatus,LTEStatus, AWGNStatus)
            this.radarStatus=radarStatus;
            this.LTEStatus=LTEStatus;
            this.AWGNStatus=AWGNStatus;
        end

        function this=setFreqOffset(this,radarFreqOffset,LTEFreqOffset,ABIFreqOffset)
            this.radarFreqOffset=radarFreqOffset;
            this.LTEFreqOffset=LTEFreqOffset;
            this.ABIFreqOffset=ABIFreqOffset;
        end

        function this=setGainVar(this,radarGain,LTEGain,ABIGain,AWGNVar)
            this.radarGain=radarGain;
            this.LTEGain=LTEGain;
            this.ABIGain=ABIGain;
            this.AWGNVar=AWGNVar;
        end

        function waveformsMeta=getWaveformInfo(this,type)
            %Returns waveform info for two types 'meta', or 'parameters'
            if nargin >1 && strcmp(type,'meta')
                waveformFieldsRemove={'radarSignal','LTESignal','LTEChannel','ABISignal',...
                    'signalOut','waveformToFile','errorColl'};
            elseif nargin >1 && strcmp(type,'parameters')
                waveformFieldsRemove={'radarSignal','LTESignal','LTEChannel','ABISignal',...
                    'signalOut','waveformToFile','errorColl','success','SIRdBmin','SIRdBmax',...
                    'SIRdBmean','SIRData'};
            elseif nargin >1 && strcmp(type,'gains')
                waveformFieldsRemove={'Fs','samplesPerSegment','totalTime','numRadarSignals',...
                    'radarStatus','radarStartTime','radarFreqOffset','numLTESignals','LTEStatus',...
                    'LTEStartTime','LTEFreqOffset','LTEChState','LTEChType','numABISignals',...
                    'ABIStatus','ABIStartTime','ABIFreqOffset','AWGNStatus','targetSIR',...
                    'radarSignal','LTESignal','LTEChannel','ABISignal',...
                    'signalOut','waveformToFile','errorColl','success','SIRdBmin','SIRdBmax',...
                    'SIRdBmean','SIRData'};
            else
                waveformFieldsRemove={};
            end
            
            fldNames=properties(this);
            fldNames=fldNames(~ismember(fldNames,waveformFieldsRemove));
            
            for I=1:length(fldNames)
                fldValues{I}=this.(fldNames{I});
            end
            
            waveformsMeta=cell2struct(fldValues',fldNames,1);
        end
      
        function [this,t0,interfBndPowr]=generateWaveformSegment(this,t0,bndPowrStatus,Bw)
            %Generate one segment of a waveform
            t=t0+(0:this.samplesPerSegment-1).'*1/this.Fs;
            
            LTESigsActive=any(this.LTEStatus);
            radarSigsActive=any(this.radarStatus);
            ABISigsActive=any(this.ABIStatus);
            
            interfBndPowr=nan(this.numRadarSignals,1);
            
            if LTESigsActive
                LTESig=complex(zeros(this.samplesPerSegment,this.numLTESignals)); %preallocate for LTE signal
                for I=1:this.numLTESignals
                    if this.LTEStatus(I)
                        LTESigFromFile=readSamples(this.LTESignal(I));
                        LTESigShifted=this.LTEGain(I)*(LTESigFromFile.*exp(1i*(2*pi*this.LTEFreqOffset(I))*t));
                        if this.LTEChState
                            LTESig(:,I)=this.LTEChannel.Ch{I}(LTESigShifted);  %apply LTE channel
                        else
                            LTESig(:,I)=LTESigShifted;
                        end
                        this.LTESignal(I)=seekNextPositionSamples(this.LTESignal(I));
                    end
                end
                LTESigOut=sum(LTESig,2);
            else
                LTESigOut=complex(0,0);
            end
            
            if ABISigsActive
                ABISig=complex(zeros(this.samplesPerSegment,this.numABISignals)); %preallocate for ABI signal
                for I=1:this.numABISignals
                    if this.ABIStatus(I)
                        ABISigFromFile=readSamples(this.ABISignal(I));
                        ABISig(:,I)=this.ABIGain(I)*(ABISigFromFile.*exp(1i*(2*pi*this.ABIFreqOffset(I))*t));
                        this.ABISignal(I)=seekNextPositionSamples(this.ABISignal(I));
                    end
                end
                ABISigOut=sum(ABISig,2);
            else
                ABISigOut=complex(0,0);
            end
            
            
            if this.AWGNStatus
                WGN=sqrt(this.AWGNVar)*(randn(this.samplesPerSegment,1)+1i*randn(this.samplesPerSegment,1))/sqrt(2);
            else
                WGN=complex(zeros(this.samplesPerSegment,1));
            end
            
            %add all interference signals
            interfNoiseSig=LTESigOut+ABISigOut+WGN;
            
            if bndPowrStatus
                %calculate interference power for each radar signal
                for I=1:this.numRadarSignals
                    interfBndPowr(I,1)=dspFun.bandPowerfiltC(interfNoiseSig,this.Fs,[this.radarFreqOffset(I)-Bw/2 this.radarFreqOffset(I)+Bw/2]);
                end
            end
            
            if radarSigsActive
                radarSig=complex(zeros(this.samplesPerSegment,this.numRadarSignals)); %preallocate for Radar signal
                for I=1:this.numRadarSignals
                    %Generate radar signal
                    if this.radarStatus(I)
                        RadarSigFromFile=readSamples(this.radarSignal(I));
                        radarSig(:,I)=this.radarGain(I)*(RadarSigFromFile.*exp(1i*(2*pi*this.radarFreqOffset(I))*t));
                        this.radarSignal(I)=seekNextPositionSamples(this.radarSignal(I));
                    end
                end
                radarSigOut=sum(radarSig,2);
            else
                radarSigOut=complex(zeros(this.samplesPerSegment,1));
            end
            
            %Add radar signal to intereference
            this.signalOut=radarSigOut+interfNoiseSig;
            t0=t(end)+1/this.Fs;
        end
        
        function [this]=generateFullWaveform(this,forwardToMaxPeakFlag)
            %Generate and save full waveform to a file
            %SIR calculation expects peaks separation is larger than segment size and Window
            t0=0;
            
            roundingConst=ceil(abs(log10(1/this.Fs))); %rounding constant for peak locations
            NumOfSeg=floor(this.totalTime/(this.samplesPerSegment*1/this.Fs)); % calcualte total number of segments
            this.totalTime=NumOfSeg*(this.samplesPerSegment*1/this.Fs); % adjust total time
            
            % verify radarStartTime has an element for each radar signal
            if length(this.radarStartTime)~=this.numRadarSignals
                this.errorColl.fullWaveform= MException('fullWaveform:Initialization', ...
                    'radarStartTime length must equal numRadarSignals');
                throw(this.errorColl.fullWaveform);
            end
            
            % Radar start segment index defaults to 1
            if ~isempty(this.radarStartTime)
                radarStartSeg=round(this.radarStartTime./(this.samplesPerSegment*1/this.Fs))+1;
            else
                radarStartSeg=ones(1,this.numRadarSignals);
            end
            
            %start LTE from the beginning if not set
            if ~isempty(this.LTEStartTime)
                LTEStartSeg=round(this.LTEStartTime./(this.samplesPerSegment*1/this.Fs))+1;
            else
                LTEStartSeg=ones(1,this.numLTESignals);
            end
            
            %start ABI from the beginning if not set
            if ~isempty(this.ABIStartTime)
                ABIStartSeg=round(this.ABIStartTime./(this.samplesPerSegment*1/this.Fs))+1;
            else
                ABIStartSeg=ones(1,this.numABISignals);
            end
            
            % update to exact radar start time
            this.radarStartTime=((radarStartSeg-1)*this.samplesPerSegment)./this.Fs;
            
            % sets flag for SIR calculation if peaks are loaded to SIRData.original
            if ~isempty(this.SIRData) && isfield(this.SIRData,'original')
                calculateSIRFlag=true;
            else
                calculateSIRFlag=false;
            end
            
            if calculateSIRFlag
                
                if nargin>1
                    % Forwards both LTE & ABI to appropriate seek position for a short file
                    if forwardToMaxPeakFlag
                        timeBeforMaxPeak=1;
                        for I=1:this.numRadarSignals
                           [~,maxIndx]=max(this.SIRData(I).original.pks);
                           radarMaxPeakSeek=round(max(this.SIRData(I).original.locs(maxIndx)-timeBeforMaxPeak,0)*this.Fs);
                           this.radarSignal(I)=setSeekPositionSamples(this.radarSignal(I),radarMaxPeakSeek);
                        end
                    end
                end

                if length(this.SIRData)~=this.numRadarSignals
                    this.errorColl.misSignalSIR= MException('fullWaveform:SIRInitialization', ...
                        'Peaks must be a vector of structs(pks and locs) with length equal numRadarSignals');
                    throw(this.errorColl.misSignalSIR);
                end
                
                try
                    %Determine location of SIR calculation from both radar peak locations and radar start time
                    for I=1:this.numRadarSignals
                        
                        initialSeek(I)=getSeekPositionSamples(this.radarSignal(I));
                        numberOfPeaks=length(this.SIRData(I).original.locs);
                        this.SIRData(I).numberOfPeaks=numberOfPeaks;
                        this.SIRData(I).peakLocations=this.radarStartTime(I)+this.SIRData(I).original.locs-initialSeek(I)*1/this.Fs;%peakLocations(I,:);
                        
                        this.SIRData(I).radarPeakPower=zeros(1,numberOfPeaks);
                        this.SIRData(I).interferencePower=zeros(1,numberOfPeaks);
                        this.SIRData(I).powerCalcLocations=zeros(1,numberOfPeaks);
                        
                        %Account for the case of radar peak at edge of segment
                        leftOverToNextSeg(I)=0;
                        freqRange(I,:)=[this.radarFreqOffset(I)-this.measParameters.SIRBw/2, this.radarFreqOffset(I)+this.measParameters.SIRBw/2];
                        halfWindowSamp(I)=round((this.measParameters.SIRWindow/(1/this.Fs))/2);
                        forwardLastInterfernceWindow(:,I)=zeros(halfWindowSamp(I)*2,1);
                        %
                    end
                    
                catch errmsg_process
                    this.errorColl.mixSignalSIR=errmsg_process;
                end
            end
            
            LTESigsActive=any(this.LTEStatus);
            ABISigsActive=any(this.ABIStatus);
            radarSigsActive=any(this.radarStatus);
            
            try
                errmsg_process=[];
                for segIndx=1:NumOfSeg
                    t=t0+(0:this.samplesPerSegment-1).'*1/this.Fs;
                    if LTESigsActive
                        LTESig=complex(zeros(this.samplesPerSegment,this.numLTESignals));%preallocate for LTE
                        
                        for I=1:this.numLTESignals
                            if (this.LTEStatus(I) && segIndx>=LTEStartSeg(I))
                                LTESigFromFile=readSamples(this.LTESignal(I));
                                LTESigShifted=this.LTEGain(I)*(LTESigFromFile.*exp(1i*(2*pi*this.LTEFreqOffset(I))*t));
                                if this.LTEChState
                                    LTESig(:,I)=this.LTEChannel.Ch{I}(LTESigShifted);  %apply LTE channel
                                else
                                    LTESig(:,I)=LTESigShifted;
                                end
                                this.LTESignal(I)=seekNextPositionSamples(this.LTESignal(I));
                            end
                        end
                        
                        LTESigOut=sum(LTESig,2);
                    else
                        LTESigOut=complex(0,0);
                    end
                    
                    if ABISigsActive
                        
                        ABISig=complex(zeros(this.samplesPerSegment,this.numABISignals)); %preallocate for ABI
                        for I=1:this.numABISignals
                            if (this.ABIStatus(I) && segIndx>=ABIStartSeg(I))
                                ABISigFromFile=readSamples(this.ABISignal(I));
                                ABISig(:,I)=this.ABIGain(I)*(ABISigFromFile.*exp(1i*(2*pi*this.ABIFreqOffset(I))*t));
                                this.ABISignal(I)=seekNextPositionSamples(this.ABISignal(I));
                            end
                        end
                        ABISigOut=sum(ABISig,2);
                    else
                        ABISigOut=complex(0,0);
                    end
                    
                    
                    if this.AWGNStatus
                        WGN=sqrt(this.AWGNVar)*(randn(this.samplesPerSegment,1)+1i*randn(this.samplesPerSegment,1))/sqrt(2);
                    else
                        WGN=complex(zeros(this.samplesPerSegment,1));
                    end
                    
                    %Add Interference signals
                    interfNoiseSig=LTESigOut+ABISigOut+WGN;
                    
                    if radarSigsActive
                        radarSig=complex(zeros(this.samplesPerSegment,this.numRadarSignals)); %preallocate for Radar signal
                        for I=1:this.numRadarSignals
                            if (this.radarStatus(I) && segIndx>=radarStartSeg(I))
                                RadarSigFromFile=readSamples(this.radarSignal(I));
                                radarSig(:,I)=this.radarGain(I)*(RadarSigFromFile.*exp(1i*(2*pi*this.radarFreqOffset(I))*t));
                                this.radarSignal(I)=seekNextPositionSamples(this.radarSignal(I));
                                
                                if calculateSIRFlag
                                    %calculate SIR based on adjusted peakLocations
                                    if leftOverToNextSeg(I)>0
                                        % calculate interfernce if peak was close to the end in prev. segment
                                        interfernceWindow=[forwardLastInterfernceWindow((end-leftOverToNextSeg(I)+1):end,I);interfNoiseSig(1:(2*halfWindowSamp(I)-leftOverToNextSeg(I)))];
                                        this.SIRData(I).interferencePower(leftOverToNextSegidx_peaksLocs(I))=dspFun.bandPowerfiltC(interfernceWindow,this.Fs,freqRange(I,:));
                                        % reset leftOverToNextSeg
                                        leftOverToNextSeg(I)=0;
                                    end
                                    
                                    idx_peaksLocs=find(round(this.SIRData(I).peakLocations,roundingConst)>=round(t(1),roundingConst)...
                                        & round(this.SIRData(I).peakLocations,roundingConst)<=round(t(end),roundingConst));

                                    if ~isempty(idx_peaksLocs)
                                        %Calculate SIR if radar peak is within segment
                                        for J=1:length(idx_peaksLocs)
                                            
                                            [peakMag,centerOfPeakSamp]=max(abs(radarSig(:,I)));
                                            startOfPeakWindow=centerOfPeakSamp-halfWindowSamp(I);
                                            endOfPeakWindow=centerOfPeakSamp+halfWindowSamp(I);
                                            
                                            % calculate radar peak power and location
                                            this.SIRData(I).powerCalcLocations(idx_peaksLocs(J))=t0+(centerOfPeakSamp*1/this.Fs);
                                            this.SIRData(I).radarPeakPower(idx_peaksLocs(J))=peakMag^2;
                                            
                                            % manage adjacent segment in case peak is too close to edge of segment
                                            if startOfPeakWindow<=0
                                                % use interfernce window from last seg if peak is close to the beginning
                                                interfernceWindow=[forwardLastInterfernceWindow((end+startOfPeakWindow+1):end,I);interfNoiseSig(1:endOfPeakWindow)];
                                                this.SIRData(I).interferencePower(idx_peaksLocs(J))=dspFun.bandPowerfiltC(interfernceWindow,this.Fs,freqRange(I,:));
                                                
                                            elseif endOfPeakWindow>this.samplesPerSegment
                                                % save end of current segment to use with next segment if peak is close to the end of this segment
                                                leftOverToNextSeg(I)=endOfPeakWindow-this.samplesPerSegment;
                                                leftOverToNextSegidx_peaksLocs(I)=idx_peaksLocs(J);

                                            else
                                                % Calculate interference Power
                                                interfernceWindow=interfNoiseSig((startOfPeakWindow+1):endOfPeakWindow);
                                                this.SIRData(I).interferencePower(idx_peaksLocs(J))=dspFun.bandPowerfiltC(interfernceWindow,this.Fs,freqRange(I,:));
                                            end
                                            
                                        end
                                    end
                                    
                                    % record last size of window
                                    forwardLastInterfernceWindow(:,I)=interfNoiseSig((end-halfWindowSamp(I)*2+1):end);
                                end
                            end
                            
                        end
                        radarSigOut=sum(radarSig,2);
                    else
                        radarSigOut=complex(zeros(this.samplesPerSegment,1));
                    end
                    
                    signalOutLocal=radarSigOut+interfNoiseSig;
                    writeSamples(this.waveformToFile,signalOutLocal);
                    t0=t(end)+1/this.Fs;
                    
                end
                
                this=resetWaveformFiles(this);

                if calculateSIRFlag
                    for I=1:this.numRadarSignals
                        %this.SIRData(I).Window=SIRpks(I).Window;
                        this.SIRData(I).FreqRange=freqRange(I,:);
                        this.SIRdBmin(:,I)=10*log10(min(this.SIRData(I).radarPeakPower./this.SIRData(I).interferencePower,[],'omitnan'));
                        this.SIRdBmax(:,I)=10*log10(max(this.SIRData(I).radarPeakPower./this.SIRData(I).interferencePower,[],'omitnan'));
                        this.SIRdBmean(:,I)=10*log10(mean(this.SIRData(I).radarPeakPower./this.SIRData(I).interferencePower,'omitnan'));
                    end
                end
                
                %Save waveform metadata to JSON file
                jsonFilePath=strcat(this.waveformFilepath(1:end-3),'json');
                [SaveJsonFileId,errmsg_write_json]=fopen(jsonFilePath,'w','n','UTF-8');
                waveformMeta=getWaveformInfo(this,'meta');
                %waveformMeta.ID=[char(java.util.UUID.randomUUID),'-',datestr(now,'mm/dd/yy--HH:MM:SS.FFF')];
                if isempty(errmsg_write_json)
                    fwrite(SaveJsonFileId,jsonencode(waveformMeta),'char');
                else
                    this.errorColl.WaveFormWriteJson=errmsg_write_json;
                end
                
            catch errmsg_process
                this.errorColl.fullWaveform=errmsg_process;
            end
            
            if  isempty(errmsg_process)
                this.success.flag=true;
            else
                this.success.flag=false;
                this.success.message='Failed to generate';  
            end
        end
%%
        function this=estimateGains(this)
            switch this.gainEstimateMethod
                case 'Power Levels'
                    this=setPowerLevels(this);
                case 'Target SIR'
                    this=estimateGainsFromTargetSIR(this);
                otherwise
                    this.errorColl.estimateGains=MException('estimateGains:InvalidOption',...
                        'Only valid options are:Power Levels, Target SIR');
            end
        end
        
        function scaleFactor=estimateScaleFactor(this,sigPInterf)
            %Calculate scale factor for conversion from double to 16 bit integer
            minINT16=double(intmin('int16'));
            maxINT16=double(intmax('int16'));
            boundGuarddBMag=20;
            minData=min(min(real(sigPInterf),min(imag(sigPInterf))));
            maxData=max(max(real(sigPInterf),max(imag(sigPInterf))));
            scaleFactor=min(maxINT16/(maxData*db2mag(boundGuarddBMag)),minINT16/(minData*db2mag(boundGuarddBMag)));
            % round to lowest order of 10\times half number of integer digits
            numDigits=numel(num2str(floor(scaleFactor)));
            halfNumDigits=floor(numDigits/2);
            scaleFactor=floor(scaleFactor/(10^halfNumDigits))*(10^halfNumDigits);
        end
  
        function this=setPowerLevels(this)
            % estimate and set radarGain, LTEgain, ABIgain, and
            % writeScaleFactor from signal power levels
            samplesPerSegmentF=this.samplesPerSegment; %TODO Seems unnecessarry

            %temporarily disable LTE channel state
            tempLTEChstate=this.LTEChState;
            this.LTEChState=false;

            for IR=1:this.numRadarSignals
                %first estimate noise power & median/max peaks and locations
                %input needs pks and locs
                [ this.radarSignal(IR),sigma_w2(IR,1),medianPeak(IR,1),noiseEst(:,IR),maxPeak(IR,1),maxPeakLoc(IR)]=...
                    estimateRadarNoise(this.radarSignal(IR), this.Fs,this.SIRData(IR).original);
            end

            %keep noise floor below KTB
            noisePSD_dB=pow2db(sigma_w2./this.Fs);
            noisePowAdjustfactor=ones(this.numRadarSignals,1);
            noiseAdjustfactor_dB=this.P_KTB_dB-noisePSD_dB;
            noisePowAdjustfactor(noiseAdjustfactor_dB<0)=db2pow(noiseAdjustfactor_dB(noiseAdjustfactor_dB<0));
            noiseVolAdjustfactor=sqrt(noisePowAdjustfactor); % use this to make sure the noise floor is below KTB after adjustment

            radarPeakPower_dB=this.PowerLevels_dBm.RadarPeakPower-30;%-119 dB
            MedianPeaksdB=pow2db(medianPeak.^2);
            %Use this instead of median for max peak
            MaxPeaksdB=pow2db(maxPeak.^2);

            %calculate radar gain
            %TODO consider whether to use reference load or 1 ohm load
            rdrGains=sqrt(db2pow(radarPeakPower_dB-MedianPeaksdB));%%-pow2db(refLoad)));

            if any(rdrGains>noiseVolAdjustfactor)
                this.success.powerLevels='Radar noise floor may be above KTB';
            end

            this.radarGain=rdrGains.';
            LTESeekPositionSamples=0;
            tempSamplesPerSegment=round(this.numLTEwindows*this.measParameters.SIRWindow*this.Fs);
            t=1/this.Fs*(0:(tempSamplesPerSegment-1)).'; % exact time is not necessary here

            %Calculate LTE gain
            for JL=1:this.numLTESignals
                currentLTESeekPositionSamples(JL)=getSeekPositionSamples(this.LTESignal(JL));% save current LTE seek position
                this.LTESignal(JL).samplesPerSegment=tempSamplesPerSegment;
                this.LTESignal(JL)=setSeekPositionSamples(this.LTESignal(JL),  LTESeekPositionSamples);
                LTESignalData(:,JL) =readSamples(this.LTESignal(JL)).*exp(1i*2*pi*this.LTEFreqOffset(JL)*t);
                LTEPowdB=pow2db((sum(abs(LTESignalData(:,JL)).^2)/tempSamplesPerSegment)/9); %Approximation to set LTE over 1 MHz (see line below for more accurate approach)
                LTEdBLevel=this.PowerLevels_dBm.LTEPower-30;
                this.LTEGain(JL)=sqrt(db2pow(LTEdBLevel-LTEPowdB));
                this.LTESignal(JL)=setSeekPositionSamples(this.LTESignal(JL),currentLTESeekPositionSamples(JL)); %retrieve original LTE position
            end
            
            %Calculate ABI gain
            for JA=1:this.numABISignals
                ABIAdjust_dB=this.PowerLevels_dBm.ABIPower-30;
                currentABISeekPositionSamples(JA)=getSeekPositionSamples(this.ABISignal(JA));
                this.ABIGain(JA)=sqrt(db2pow(ABIAdjust_dB));
                this.ABISignal(JA).samplesPerSegment=tempSamplesPerSegment;
                ABISignalData(:,JA) =readSamples(this.ABISignal(JA)).*exp(1i*2*pi*this.ABIFreqOffset(JA)*t);
                this.ABISignal(JA)=setSeekPositionSamples(this.ABISignal(JA),  currentABISeekPositionSamples(JA));
            end

            %sample radar signal using new gain
            for JR=1:this.numRadarSignals
                currentRadarSeekPositionSamples(JR)=getSeekPositionSamples(this.radarSignal(JR));
                this.radarSignal(JR)=setSeekPositionSamples(this.radarSignal(JR),  round((maxPeakLoc(JR)-this.measParameters.SIRWindow/2)*this.Fs));
                this.radarSignal(JR).samplesPerSegment=tempSamplesPerSegment;
                radarSignalData(:,JR) =double(this.radarStatus(JR))*this.radarGain(JR)*readSamples(this.radarSignal(JR)).*exp(1i*2*pi*this.radarFreqOffset(JR)*t);
                this.radarSignal(JR)=setSeekPositionSamples(this.radarSignal(JR),  currentRadarSeekPositionSamples(JR));
            end

            %Calculate AWGN noise variance
            AWGNVarF=db2pow(this.PowerLevels_dBm.AWGNPSD-30)*this.Fs;
            this.AWGNVar=double(this.AWGNStatus)*AWGNVarF;
            WGN=sqrt(this.AWGNVar)*(randn(tempSamplesPerSegment,1)+1i*randn(tempSamplesPerSegment,1))/sqrt(2);
            
            %Add radar signal to interference
            sigPInterf=sum(radarSignalData,2)+sum(double(this.LTEStatus).*this.LTEGain.*LTESignalData,2)...
                +sum(double(this.ABIStatus).*this.ABIGain.*ABISignalData,2)+WGN;
            
            %calculate write scale factor
            scaleFactor=estimateScaleFactor(this,sigPInterf);
            
            %restore samples per segment value
            this.samplesPerSegment=samplesPerSegmentF;  %TODO Seems unnecessarry
            this=updateSamplesPerSegment(this);
            
            %restore LTE channel state
            this.LTEChState=tempLTEChstate;

            %update write scale factor
            this.writeScaleFactor=scaleFactor;
        end
%%        
        function this=estimateGainsFromTargetSIR(this)
            % estimate and set radarGain, LTEgain, ABIgain, and
            % writeScaleFactor from target SIR
            samplesPerSegmentF=this.samplesPerSegment;
            %tempSamplesPerSegment=round(this.SIRData(1).window*this.Fs);
            tempSamplesPerSegment=round(this.measParameters.SIRWindow*this.Fs);
            
            t=1/this.Fs*(0:(tempSamplesPerSegment-1)).'; % reference to t=0 start time
            this.samplesPerSegment=tempSamplesPerSegment;
            
            %temporarily disable LTE channel state
            tempLTEChstate=this.LTEChState;
            this.LTEChState=false;
            
            if (isempty(this.radarStartTime)) || length((this.radarStartTime))~=this.numRadarSignals
                radarStartTimeEst=zeros(1,this.numRadarSignals);
            else
                radarStartTimeEst=this.radarStartTime;
            end
            
            if (isempty(this.LTEStartTime)) || length((this.LTEStartTime))~=this.numLTESignals
                LTEStartTimeEst=zeros(1,this.numLTESignals);
            else
                LTEStartTimeEst=this.LTEStartTime;
            end
            
            if (isempty(this.ABIStartTime)) || length((this.ABIStartTime))~=this.numABISignals
                ABIStartTimeEst=zeros(1,this.numABISignals);
            else
                ABIStartTimeEst=this.ABIStartTime;
            end

            this=updateSamplesPerSegment(this);
            
            %save seek position for both LTE & ABI
            for JL=1:this.numLTESignals
                currentLTESeekPositionSamples(JL)=getSeekPositionSamples(this.LTESignal(JL));
            end          
            
            for JA=1:this.numABISignals
                currentABISeekPositionSamples(JA)=getSeekPositionSamples(this.ABISignal(JA));
            end
            
            for IR=1:this.numRadarSignals
                %first estimate noise power & median/max peaks and locations
                %input needs pks and locs
                [ this.radarSignal(IR),sigma_w2(IR,1),medianPeak(IR,1),noiseEst(:,IR),maxPeak(IR,1),maxPeakLoc(IR)]=...
                    estimateRadarNoise(this.radarSignal(IR), this.Fs,this.SIRData(IR).original);
                
                % save radar current seek position
                currentRadarSeekPositionSamples(IR)=getSeekPositionSamples(this.radarSignal(IR));
                
                % find location of max peak
                %peakSeekPositionSamples(IR)=round((maxPeakLoc(IR)-this.SIRData(IR).window/2)/(1/this.Fs));
                peakSeekPositionSamples(IR)=round((maxPeakLoc(IR)-this.measParameters.SIRWindow/2)/(1/this.Fs));
                this.radarSignal(IR)=setSeekPositionSamples(this.radarSignal(IR), peakSeekPositionSamples(IR));
                maxPeakSamples=readSamples(this.radarSignal(IR));
                
                % find correct peak location
                [~,maxPeakIndx]=max(abs(maxPeakSamples));
                maxPeakLocationAdjustmentSamples=round(tempSamplesPerSegment/2-maxPeakIndx); % peak location (in samples)
                peakSeekPositionSamples(IR)=peakSeekPositionSamples(IR)-maxPeakLocationAdjustmentSamples;
                this.radarSignal(IR)=setSeekPositionSamples(this.radarSignal(IR), peakSeekPositionSamples(IR));
                    maxPeakSamples=readSamples(this.radarSignal(IR));% set seek position to peak location
      
                tr=t+peakSeekPositionSamples(IR)*(1/this.Fs);
                radarSignalData(:,IR) =double(this.radarStatus(IR))*(maxPeakSamples.*exp(1i*2*pi*this.radarFreqOffset(IR)*tr));
                this.radarSignal(IR)=setSeekPositionSamples(this.radarSignal(IR),  currentRadarSeekPositionSamples(IR));  %retrieve original seek position for radar
                
                % 1st dim data, 2nd dim signal, 3rd dim radar ref (radar peak)
                %Matrix: (data samples,interference signal index,radar ref index)
                for JL=1:this.numLTESignals
                    LTESeekPositionSamples=round((radarStartTimeEst(IR)-LTEStartTimeEst(JL))*this.Fs)+peakSeekPositionSamples(IR);
                    tl=t+LTESeekPositionSamples*(1/this.Fs);
                    this.LTESignal(JL)=setSeekPositionSamples(this.LTESignal(JL),  LTESeekPositionSamples);
                    LTESignalData(:,JL,IR) =double(this.LTEStatus(JL))*readSamples(this.LTESignal(JL)).*exp(1i*2*pi*this.LTEFreqOffset(JL)*tl);
                end
                
                for JA=1:this.numABISignals
                    ABISeekPositionSamples=round((radarStartTimeEst(IR)-ABIStartTimeEst(JA))*this.Fs)+peakSeekPositionSamples(IR);
                    ta=t+ABISeekPositionSamples*(1/this.Fs);
                    this.ABISignal(JA)=setSeekPositionSamples(this.ABISignal(JA),  ABISeekPositionSamples);
                    ABISignalData(:,JA,IR) =double(this.ABIStatus(JA))*readSamples(this.ABISignal(JA)).*exp(1i*2*pi*this.ABIFreqOffset(JA)*ta);
                end

            end
            
            %Retrieve seek position for both LTE & ABI
            for JL=1:this.numLTESignals
                this.LTESignal(JL)=setSeekPositionSamples(this.LTESignal(JL),  currentLTESeekPositionSamples(JL));
            end
            
            for JA=1:this.numABISignals
                this.ABISignal(JA)=setSeekPositionSamples(this.ABISignal(JA),  currentABISeekPositionSamples(JA));
            end
            
            %peakPowerThreshold_dB=-89-30;%-119 dB %we declared peakPowerThreshold_dB
            noisePSD_dB=pow2db(sigma_w2./this.Fs);
            
            %TODO check how to use this (median) instead of max
            %medianPeakPowOrig_dB=pow2db((medianPeak).^2);
            
            %TODO clean up this code (Begin unmerged)
            noisePowAdjustfactor=ones(this.numRadarSignals,1);
            noiseAdjustfactor_dB=this.P_KTB_dB-noisePSD_dB;
            noisePowAdjustfactor(noiseAdjustfactor_dB<0)=db2pow(noiseAdjustfactor_dB(noiseAdjustfactor_dB<0));
            noiseVolAdjustfactor=sqrt(noisePowAdjustfactor);
%             peakPowAdjustfactor=db2pow(peakPowerThreshold_dB-medianPeakPowOrig_dB);
%             peakVolAdjustfactor=sqrt(peakPowAdjustfactor);
%             rdrGainLowUpVol=[peakVolAdjustfactor,noiseVolAdjustfactor];
            
            % need to make sure that peakVolAdjustfactor<noiseVolAdjustfactor otherwise
            % either don't use this waveform or set it to noiseVolAdjustfactor
            %RDRSig=(noiseVolAdjustfactor.').*radarSignalData;
            
            %
            dBMin=3;
            dBMax=6;
            LTEBandwidth=10e6;
            %avrgLTEPSD=pow2db(mean(abs(LTESignalData).^2,1).'/LTEBandwidth);
            avrgLTEPSD=pow2db(max(mean(abs(LTESignalData).^2,1),[],3).'/LTEBandwidth);% mean of each LTE signal, min of each LTE signal relative to radar
            LTEGainsAboveKTB=randi([dBMin,dBMax],2,1);
            LTEGainsPow=db2pow((this.P_KTB_dB+LTEGainsAboveKTB)-avrgLTEPSD);
            LTEGainsVol=sqrt(LTEGainsPow);
            % in case of LTEStatus is 0, check for inf and set the gain to zero
            LTEGainsVol(isinf(LTEGainsVol))=0; % gain for each LTE signal
            
            %LTESig=(LTEGainsVol.').*LTESignalData;
%             for JL=1:this.numLTESignals
%             LTESig(:,JL,:)=LTEGainsVol(JL)*LTESignalData(:,JL,:);
%             end
            LTESig=(LTEGainsVol.').*LTESignalData;
            % END unmerged

            SIRtargetNum=db2pow(this.targetSIR);
            
            %TODO this needs to be corrected according to ADCscale (i.e. for each ADCscale the noise floor is the same)
            % should result to noise floor of ABI signals at KTB
            ABIGainsVol=noiseVolAdjustfactor(2)*double(this.ABIStatus).';
            ABISig=(ABIGainsVol.').*ABISignalData;
            
            % set awgn var near KTB
            AWGNAboveKTB=5;
            AWGNVarF=db2pow(this.P_KTB_dB+AWGNAboveKTB)*this.Fs;
            WGN=double(this.AWGNStatus)*sqrt(AWGNVarF)*(randn(this.samplesPerSegment,1)+1i*randn(this.samplesPerSegment,1))/sqrt(2);
            
            %Calculate radar gain
            for I=1:this.numRadarSignals
                freqRange=[this.radarFreqOffset(I)-this.measParameters.SIRBw/2 this.radarFreqOffset(I)+this.measParameters.SIRBw/2];
                yI=sum(LTESig(:,:,I),2)+sum(ABISig(:,:,I),2)+WGN;
                Gr(I,1)=sqrt((SIRtargetNum*dspFun.bandPowerfiltC(yI,this.Fs,freqRange))/max(abs(radarSignalData(:,I)))^2); %TODO allow for median instead of max
            end

            %TODO check Nan & Infinite for gains
            %TODO check for redundancy (e.g. WGN)
            %Set gain variable 
            radarGainF=Gr;
            radarGainF(isnan(radarGainF))=0;
            LTEGainF=LTEGainsVol;
            LTEGainF(isnan(LTEGainF))=0;
            ABIGainF=ABIGainsVol;
            ABIGainF(isnan(ABIGainF))=0;
            AWGNVarF=AWGNVarF*this.AWGNStatus;
            AWGNVarF(isnan(AWGNVarF))=0;
            WGN=double(this.AWGNStatus)*sqrt(AWGNVarF)*(randn(this.samplesPerSegment,1)+1i*randn(this.samplesPerSegment,1))/sqrt(2);
           
            %Add signals to interference
            sigPInterf=sum((radarGainF.').*radarSignalData,2)+sum((LTEGainF.').*LTESignalData(:,:,1),2)+sum((ABIGainF.').*ABISignalData(:,:,1),2)+WGN; % this should be equal to sigPInterf
            
            %TODO consider remove reference load from input power
            %TODO whether to use reference load for output power
            %scale by peaks>> min(median for each radar) >>-89 db
            MedianPeaksdB=pow2db((radarGainF.*medianPeak).^2);
            MedianPeaksdB=MedianPeaksdB(isfinite(MedianPeaksdB));
            
            if ~isempty(MedianPeaksdB)
                meadianPeakPowMinus89dBm=db2pow(this.peakPowerThreshold_dB-(min(MedianPeaksdB)-pow2db(this.referenceLoad)));
            else
                meadianPeakPowMinus89dBm=db2pow(-99-30);
            end

            constMultiply=sqrt(meadianPeakPowMinus89dBm);
            radarGainF=constMultiply*radarGainF; %TODO need to check compare to noiseVolAdjustfactor, to make sure radar noisefoar is still below KTB
            LTEGainF=constMultiply*LTEGainF;
            ABIGainF=constMultiply*ABIGainF;
            AWGNVarF=constMultiply^2*AWGNVarF;
            sigPInterf=constMultiply*sigPInterf;
            
            scaleFactor=estimateScaleFactor(this,sigPInterf);

            %restore samples per segment value
            this.samplesPerSegment=samplesPerSegmentF;
            this=updateSamplesPerSegment(this);
            
            %restore LTE channel state
            this.LTEChState=tempLTEChstate;
            
            %set gain value (expects row vectors)
            this=setGainVar(this,radarGainF.',LTEGainF.',ABIGainF.',AWGNVarF);
            this.writeScaleFactor=scaleFactor;
        end
%%        
        function [previewState, generationState]=isReady(this)
            %TODO check if function is out of date or is compatible with
            %current state of class
            %Determine if object is ready for preview or generation 
            pars=getWaveformInfo(this,'parameters');
            generationState=~any( structfun(@isempty, pars) );
            
            waveformFieldsRemove={'totalTime','radarStartTime','LTEStartTime','ABIStartTime','writeScaleFactor'};
            fldNames=fieldnames(pars);
            fldNames=fldNames(~ismember(fldNames,waveformFieldsRemove));
            for I=1:length(fldNames)
                fldValues{I}=this.(fldNames{I});
            end
            previewStruct=cell2struct(fldValues',fldNames,1);
            previewState=~any( structfun(@isempty, previewStruct) );
        end
%%        
        function this=resetWaveformFiles(this)
            %reset all signals from/to file
            
            if ~isempty(this.waveformToFile)
                this.waveformToFile=resetSignalToFile(this.waveformToFile);
            end
            
            if ~isempty(this.radarSignal)
                for I=1:this.numRadarSignals
                    this.radarSignal(I)=resetSignalFromFile(this.radarSignal(I));
                end
            end
            
            if ~isempty(this.LTESignal)
                for I=1:this.numLTESignals
                    this.LTESignal(I)=resetSignalFromFile(this.LTESignal(I));
                end
            end
            
            if ~isempty(this.ABISignal)
                for I=1:this.numABISignals
                    this.ABISignal(I)=resetSignalFromFile(this.ABISignal(I));
                end
            end
        end
        
    end
end

