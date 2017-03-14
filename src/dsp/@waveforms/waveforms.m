classdef waveforms < radarSignal & threeGPPChannel
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    %
    %   See also, radarSignal, threeGPPChannel
    
    properties
        Fs
        radarLTEStatus       %vector logic e.g. [Radar LTE1 LTE2]
        frequencyOffset      %vector freq. MHz [RadarOf LTE1Of LTE2Of]
        AWGNVar              %noise variance
        scaleFactor          %save scale factor
        radarLTEGain         %vector [RadarG LTE1G LTE2G]
        AWGNStatus           %logic
        LTEChannelStatus     %vector logic [LTE1 LTE2]
    end
    
    methods
        function mixSignal=RadarWaveforms(Fs,radarLTEStatus,frequencyOffset,radarLTEGain,scaleFactor)
            
            if nargin > 0
                mixSignal.Fs=Fs;
                mixSignal.radarLTEStatus=radarLTEStatus;
                mixSignal.frequencyOffset=frequencyOffset;
                mixSignal.radarLTEGain=radarLTEGain;
                mixSignal.scaleFactor=scaleFactor;
            end
        end
        
        function mixSignal=setFs(mixSignal,Fs)
            mixSignal.Fs=Fs;
        end
        
        function mixSignal=setFrequencyOffset(mixSignal,frequencyOffset)
            mixSignal.rrequencyOffset=frequencyOffset;
        end
        
        function mixSignal=setRadarLTEstatus(mixSignal,radarLTEStatus)
            mixSignal.radarLTEStatus=radarLTEStatus;
        end
        
        function mixSignal=setRadarLTEGain(radarLTEGain)
            mixSignal.radarLTEGain=radarLTEGain;
        end
    end
    
end

