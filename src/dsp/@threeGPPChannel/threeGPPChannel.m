classdef threeGPPChannel
    %3GPP Rayleigh channel model for
    %  Example usage:
    %------------------------------
    % lte=threeGPPChannel(Fs,'EVA5Hz');
    % lte=lte.initCh();  
    properties
        %ThreeGPP
        ChFs
        Ch
        NumCh
        ChType
    end
    
   properties (Constant)
    ThreeGPP=struct('EPA',struct('TapDelays',[0 30 70 90 110 190 410].*1e-9,...
                     'PathGains', [0.0 -1.0 -2.0 -3.0 -8.0 -17.2 -20.8],...
                     'Doppeler5Hz',5,'NumberofChannelTaps',7,'DelaySpreadRMS',45e-9,'MaximumExcessTapDelaySpan',410e-9),...
                'EVA',struct('TapDelays',[0 30 150 310 370 710 1090 1730 2510].*1e-9,...
                     'PathGains', [0 -1.5 -1.4 -3.6 -0.6 -9.1 -7.0 -12.0 -16.9],...
                     'Doppeler5Hz',5,'Doppeler70Hz',70,'NumberofChannelTaps',9,'DelaySpreadRMS',357e-9,'MaximumExcessTapDelaySpan',2510e-9),...
                'ETU',struct('TapDelays',[0 50 120 200 230 500 1600 2300 5000].*1e-9,...
                     'PathGains', [-1 -1 -1 0 0 0 -3 -5 -7],...
                     'Doppeler70Hz',70,'Doppeler300Hz',300,'NumberofChannelTaps',9,'DelaySpreadRMS',991e-9,'MaximumExcessTapDelaySpan',5000e-9),...
                'Types',{{'EPA5Hz'  'EVA5Hz'  'EVA70Hz'  'ETU70Hz'  'ETU300Hz'}});
   end
    methods
        
        function this=threeGPPChannel(ChFs,NumCh,ChType)

            if nargin>0
                this.ChFs=ChFs;
                this.NumCh=NumCh;
                if sum(ismember(ChType,this.ThreeGPP.Types))==NumCh
                    this.ChType=ChType;
                else
                    error('LTE:ChannelModel',...
                        'Error. \nChType must be one of these options %s and a cell arry of length %d',strjoin(this.ThreeGPP.Types),NumCh);
                end
            end
            
        end
        
        function this=set.ChFs(this,fs)
            this.ChFs=fs;
        end
        
        function this=set.NumCh(this,N)
            this.NumCh=N;
        end
        
        function this=set.ChType(this,ChType)
            if sum(ismember(ChType,this.ThreeGPP.Types))==length(ChType)
                this.ChType=ChType;
            else
                error('LTE:ChannelModel',...
                    'Error. \nChType must be one of these options %s.',strjoin(this.ThreeGPP.Types));
            end
            
        end
        
        function threeGPPTypes=get3GPPTypes(this)
            threeGPPTypes=this.ThreeGPP.Types;
        end
        
        function this=initCh(this)
            %Possible ChTypes:
            % EPA5Hz, EVA5Hz, EVA70Hz, ETU70Hz, ETU300Hz
            
            %             rayleigh=rayleighchan(Ts,Fd,Tau,PdB);
            %             %rayleigh.DopplerSpectrum=[doppler.gaussian]; default is RayleighChan.DopplerSpectrum=[doppler.jakes];
            %             rayleigh.ResetBeforeFiltering=0;
            %             rayleigh.NormalizePathGains=1;
            %             rayleigh.StoreHistory=0;
            %             this.Ch=rayleigh;
            this.Ch=cell(1,this.NumCh);
            for I=1:this.NumCh
                switch this.ChType{I}
                    case this.ThreeGPP.Types{1} %'EPA5Hz'
                        Tau=this.ThreeGPP.EPA.TapDelays;
                        PdB=this.ThreeGPP.EPA.PathGains;
                        Fd=this.ThreeGPP.EPA.Doppeler5Hz;
                    case this.ThreeGPP.Types{2} %'EVA5Hz'
                        Tau=this.ThreeGPP.EVA.TapDelays;
                        PdB=this.ThreeGPP.EVA.PathGains;
                        Fd=this.ThreeGPP.EVA.Doppeler5Hz;
                    case this.ThreeGPP.Types{3} %'EVA70Hz'
                        Tau=this.ThreeGPP.EVA.TapDelays;
                        PdB=this.ThreeGPP.EVA.PathGains;
                        Fd=this.ThreeGPP.EVA.Doppeler70Hz;
                    case this.ThreeGPP.Types{4} %'ETU70Hz'
                        Tau=this.ThreeGPP.ETU.TapDelays;
                        PdB=this.ThreeGPP.ETU.PathGains;
                        Fd=this.ThreeGPP.ETU.Doppeler70Hz;
                    case this.ThreeGPP.Types{5} %'ETU300Hz'
                        Tau=this.ThreeGPP.ETU.TapDelays;
                        PdB=this.ThreeGPP.ETU.PathGains;
                        Fd=this.ThreeGPP.ETU.Doppeler300Hz;
                end
                this.Ch{I}=comm.RayleighChannel('SampleRate',this.ChFs,'PathDelays',Tau,'AveragePathGains',PdB,'MaximumDopplerShift',Fd,'NormalizePathGains',true);
            end
        end
        
    end
    
end

