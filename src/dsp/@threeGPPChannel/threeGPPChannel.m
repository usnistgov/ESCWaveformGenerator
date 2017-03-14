classdef threeGPPChannel
    %3GPP Rayleigh channel model for  
    %  Example usage:
    %------------------------------
    % lte=threeGPPChannel(Fs,'EVA5Hz');
    % lte=lte.initCh();
    % lte.ChType='EPA5Hz';
    
    properties 
        ThreeGPP
        ChFs
        ChType
        Ch
    end
    
    
    methods 
        
        function this=threeGPPChannel(ChFs,chtype)
            load('ThreeGPP');
            this.ThreeGPP=ThreeGPP;
            if nargin>0
                this.ChFs=ChFs;
               if sum(strcmp(chtype,this.ThreeGPP.info))
                   this.ChType=chtype;
               else
               error('LTE:WrongChannelModel',...
                      'Error. \nchtype must be one of these options %s.',strjoin(this.ThreeGPP.info));
               end
                %this.ChType=ChType;
            end
            
        end
        
        function this=set.ChFs(this,fs)
            this.ChFs=fs;
        end
        
        function this=set.ChType(this,chtype)
            if sum(strcmp(chtype,this.ThreeGPP.info))
            this.ChType=chtype;
            else   
               error('LTE:WrongChannelModel',...
                      'Error. \nchtype must be one of these options %s.',strjoin(this.ThreeGPP.info));
            end
   
        end
        
        function this=initCh(this)
            %Possible ChTypes:
            % EPA5Hz, EVA5Hz, EVA70Hz, ETU70Hz, ETU300Hz
            load('ThreeGPP');
            Ts=1/this.ChFs;
            switch this.ChType
                case 'EPA5Hz'
                    Tau=this.ThreeGPP.EPA.TapDelays;
                    PdB=this.ThreeGPP.EPA.PathGains;
                    Fd=this.ThreeGPP.EPA.Doppeler5Hz;
                case 'EVA5Hz'
                    Tau=this.ThreeGPP.EVA.TapDelays;
                    PdB=this.ThreeGPP.EVA.PathGains;
                    Fd=this.ThreeGPP.EVA.Doppeler5Hz;
                case 'EVA70Hz'
                    Tau=this.ThreeGPP.EVA.TapDelays;
                    PdB=this.ThreeGPP.EVA.PathGains;
                    Fd=this.ThreeGPP.EVA.Doppeler70Hz;
                case 'ETU70Hz'
                    Tau=this.ThreeGPP.ETU.TapDelays;
                    PdB=this.ThreeGPP.ETU.PathGains;
                    Fd=this.ThreeGPP.ETU.Doppeler70Hz;
                case 'ETU300Hz'
                    Tau=this.ThreeGPP.ETU.TapDelays;
                    PdB=this.ThreeGPP.ETU.PathGains;
                    Fd=this.ThreeGPP.ETU.Doppeler300Hz;
            end
            
            rayleigh=rayleighchan(Ts,Fd,Tau,PdB);
            %RayleighChan.DopplerSpectrum=[doppler.gaussian]; default is RayleighChan.DopplerSpectrum=[doppler.jakes];
            %RayleighChan.ResetBeforeFiltering=1;
            rayleigh.NormalizePathGains=1;
            rayleigh.StoreHistory=1;
            this.Ch=rayleigh;
        end
        
    end
    
    %     methods (Access=public)
    %
    %
    %     end
    
end

