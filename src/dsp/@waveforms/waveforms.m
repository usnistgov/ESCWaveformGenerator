classdef waveforms < signalFile & threeGPPChannel
    %Waveforms generator combines radar signal from file and LTE signal
    %  parameters:
    %             Radar,LTE , and AWGN statuses
    %             LTE channel state
    %             freq offsets
    %             additional gains
    % Two modes of operations:
    %                         Dynamic, generate a signal in segments
    %                         Static, generate and save the signal
    %   See also, signalFile, threeGPPChannel
    
    properties
        Fs
        radarStatus          logical%radar status
        LTEStatus            logical%vector row logic [LTE1 LTE2]
        LTEChState           logical% logical scalar enable disbale 3gpp channel effect
        AWGNStatus           logical%AWGN channel status
        radarFreqOffset      %Radar freq offeset MHz
        LTEFreqOffset        %LTE freq offeset vector [f1 f2]
        radarGain            %Radar gain
        LTEGain              %LTE gain vector row size LTEChNum
        AWGNVar              %noise variance
        saveScaleFactor      %save scale factor
        LTESignal
        %samplesPerSegment    %defined in signalFile
        signalOut
        errorColl
    end
    
    methods
        function this=waveforms(Fs)
            
            if nargin > 0
                this.Fs=Fs;
            end
        end
        
        function this=setFs(this,Fs)
            this.Fs=Fs;
        end
        
        function  this=setSamplesPerSegment(this,samplesPerSegment)
            this.samplesPerSegment=samplesPerSegment;
        end
        
        function this=setUpLTECh(this,ChType,LTEChNum)
            if ~isempty(this.Fs)&& LTEChNum>0
                this.ChFs=this.Fs;
                this.ChType=ChType;
                this.NumCh=LTEChNum;
                this=initCh(this);
            else
                 error('Waveforms:NoSamplingFreq',...
                      'Error. \n Please set Fs value and/or Number of channels');
            end
        end
        
        function this=setUpRadar(this,radarMeasFile,radarMetaFile,radarMeasFileNum,seekPositionSamples)
            this=setMeasFile(this,radarMeasFile);
            this=setRadarMetaFile(this,radarMetaFile);
            % needed for RF gain, if no meta file available use
            % this=setRfGain(this,rfgain) instead by passing rfgain
            % directly
            this=readRadarMeta(this);
            this=setRadarMeasFileNum(this,radarMeasFileNum);
            
            this=setRfGain(this);
            
            this=initFile(this);
            if nargin<5
                % set default seek position to zero
                seekPositionSamples=0;
            end
            this=setSeekPositionSamples(this,seekPositionSamples);
            %this=setSamplesPerSegment(this,samplesPerSegment);
        end
        
        function this=setStatus(this,radarStatus,LTEStatus, AWGNStatus)
            this.radarStatus=radarStatus;
            this.LTEStatus=LTEStatus;
            this.AWGNStatus=AWGNStatus;
        end
        
        function this=setFreqOffset(this,radarFreqOffset,LTEFreqOffset)
            this.radarFreqOffset=radarFreqOffset;
            if ~iscolumn(LTEFreqOffset)
                LTEFreqOffset=LTEFreqOffset.';
            end
            this.LTEFreqOffset=LTEFreqOffset;
        end
        
        function this=setGainVar(this,radarGain,LTEGain,AWGNVar)
            this.radarGain=radarGain;
            this.LTEGain=LTEGain;
            if nargin==4
                this.AWGNVar=AWGNVar;
            end
        end
        

        function [this,t0,interfBndPowr]=mixSignal(this,t0,txWaveform_resampled,bndPowrStatus,freqRange)
            t=t0+(0:this.samplesPerSegment-1).'*1/this.Fs;
            Radarshift=exp(1i*(2*pi*this.radarFreqOffset*1e6)*t);
            
            NLTEavAilable=length(txWaveform_resampled);
            NLTESegAvailble=floor(NLTEavAilable/this.samplesPerSegment);
            NumOfActiveLTESigs=sum(this.LTEStatus);
            interfBndPowr=NaN;
            if this.LTEChState
                
                LTESigCh=complex(zeros(this.samplesPerSegment,NumOfActiveLTESigs));
            end
            WGN=complex(0,0);
            
            if NumOfActiveLTESigs>0
                LTEChshift=exp(1i*(2*pi*this.LTEFreqOffset(this.LTEStatus)*1e6).*t);
                for I=1:NumOfActiveLTESigs
                    nSelectLTEseg=randi(NLTESegAvailble,1,1);
                    LTESigShifted=this.LTEGain(I)*txWaveform_resampled((nSelectLTEseg-1)*this.samplesPerSegment+1:((nSelectLTEseg)*this.samplesPerSegment)).*LTEChshift(:,I);
                    if this.LTEChState
                        %LTESigCh(:,I)=step(this.Ch{I},LTESigShifted);
                        LTESigCh(:,I)=this.Ch{I}(LTESigShifted);
                    else
                        LTESigCh(:,I)=LTESigShifted;
                    end
                    
                end
                LTESig=sum(LTESigCh,2);
            else
                LTESig=0;
            end
            
            if this.AWGNStatus
                    WGN=sqrt(this.AWGNVar)*(randn(this.samplesPerSegment,1)+1i*randn(this.samplesPerSegment,1))/sqrt(2);                 
            end
            interfSig=LTESig+WGN;
            if bndPowrStatus
            interfBndPowr=util.bandPowerC(interfSig,this.Fs,freqRange);
            end
            radarMeasData=readMeasData(this);
            this=seekNextPositionSamples(this);
            radarSignal=this.radarStatus*this.radarGain*(radarMeasData.*Radarshift);          
            this.signalOut=radarSignal+interfSig;

            t0=t(end);
        end
        
        
        function [this,radarStartTimeAdj, success]=mixSignalSave(this,txWaveform_resampled,totalTime,radarStartTime,saveFileNamePath)
           NLTEavAilable=length(txWaveform_resampled);
           NLTESegAvailble=floor(NLTEavAilable/this.samplesPerSegment);
           t0=0;
           NumOfSeg=floor(totalTime/(this.samplesPerSegment*1/this.Fs));
           radarStartSeg=floor(radarStartTime/(this.samplesPerSegment*1/this.Fs));
           % update to exact radar start time for return
           radarStartTimeAdj=radarStartSeg*this.samplesPerSegment*1/this.Fs;
           %[SaveWaveformFileId,errmsg_write]=fopen(saveFileNamePath,'a','l','UTF-8');
           [SaveWaveformFileId,errmsg_write]=fopen(saveFileNamePath,'W','l','UTF-8');
           NumOfActiveLTESigs=sum(this.LTEStatus);
           if isempty(errmsg_write)
               if this.LTEChState

                 LTESigCh=complex(zeros(this.samplesPerSegment,NumOfActiveLTESigs));
               end
               WGN=complex(0,0);
           try
               errmsg_process=[];
            for sgmnt=1:NumOfSeg
               
%                 LTERawSig=[txWaveform_resampled(nSelectLTEseg(1)*this.samplesPerSegment:((nSelectLTEseg(1)+1)*this.samplesPerSegment-1)),...
%                     txWaveform_resampled(nSelectLTEseg(2)*this.samplesPerSegment:((nSelectLTEseg(2)+1)*this.samplesPerSegment-1))];
                 t=t0+(0:this.samplesPerSegment-1).'*1/this.Fs;
%%
%{
                 nSelectLTEseg=randi(NLTESegAvailble,2,1);
                 LTERawSig=[txWaveform_resampled((nSelectLTEseg(1)-1)*this.samplesPerSegment+1:((nSelectLTEseg(1))*this.samplesPerSegment)),...
                             txWaveform_resampled((nSelectLTEseg(2)-1)*this.samplesPerSegment+1:((nSelectLTEseg(2))*this.samplesPerSegment))];
                 LTEChshift=exp(1i*(2*pi*this.LTEFreqOffset*1e6).*t);
                 
                if this.LTEChState
                    for I=1:this.LTEChNum
                        % LTESigCh(:,I)=filter(this.LTECh(I).Ch,this.LTEGain(I)*LTERawSig(:,I).*LTEChshift(:,I));
                        LTESigCh(:,I)=step(this.LTECh(I).Ch,this.LTEGain(I)*LTERawSig(:,I).*LTEChshift(:,I));
                    end
                else
                    LTESigCh=(LTERawSig.*LTEChshift).*this.LTEGain;
                end
                LTESig=LTESigCh.*this.LTEStatus;
%}
%%               
                if NumOfActiveLTESigs>0
                    LTEChshift=exp(1i*(2*pi*this.LTEFreqOffset(this.LTEStatus)*1e6).*t);
                    for I=1:NumOfActiveLTESigs
                     nSelectLTEseg=randi(NLTESegAvailble,1,1);
                     LTESigShifted=this.LTEGain(I)*txWaveform_resampled((nSelectLTEseg-1)*this.samplesPerSegment+1:((nSelectLTEseg)*this.samplesPerSegment)).*LTEChshift(:,I);
                      if this.LTEChState
                         %LTESigCh(:,I)=step(this.LTECh(I).Ch,LTESigShifted);
                         LTESigCh(:,I)=this.Ch{I}(LTESigShifted);
                      else
                         LTESigCh(:,I)=LTESigShifted;
                      end
                     
                    end
                    LTESig=sum(LTESigCh,2);
                else
                   LTESig=0;
                end
                
                if this.AWGNStatus
                    WGN=sqrt(this.AWGNVar)*(randn(this.samplesPerSegment,1)+1i*randn(this.samplesPerSegment,1))/sqrt(2);                 
                end
                
                if this.radarStatus && sgmnt>=radarStartSeg
                Radarshift=exp(1i*(2*pi*this.radarFreqOffset*1e6)*t);
                radarMeasData=readMeasData(this);
                this=seekNextPositionSamples(this);
                radarSignal=this.radarStatus*this.radarGain*(radarMeasData.*Radarshift);
                else
                    radarSignal=0;
                end
                signalOutLocal=radarSignal+LTESig+WGN;
                %disp(size(signalOutLocal))
                %save to a file
                data_out(:,1)=imag(signalOutLocal*this.saveScaleFactor); %simple scaling
                data_out(:,2)=real(signalOutLocal*this.saveScaleFactor); %simple scaling
                data_out_interleaved=reshape(data_out.',[],1);
                fwrite(SaveWaveformFileId,data_out_interleaved,'int16');
                t0=t(end);  
            end
            
           catch errmsg_process
                this.errorColl.mixSignal=errmsg_process;
           end
           end
           if isempty(errmsg_write) && isempty(errmsg_process)
               success=true;
           fclose(SaveWaveformFileId);
           this=resetSignalFile(this);
           else
               success=false;
           end
        end
        
        
        
    end
end
    
