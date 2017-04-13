classdef util
    %util class combines common functions
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Access = public, Static = true)
        function p1= bandPowerC(sig,Fs,freq_range )
            %Band power for complex signal sig centered at zero
            %   compute power in freq_range
            % minimal similar to bandpower()
            if isrow(sig)
                sig=sig.';
            end
            N=length(sig);
            Xf=fftshift(fft(sig));
            F=((-N/2:N/2-1)*(Fs/N)).';
            ind1=find(F<=freq_range(1), 1, 'last' );
            ind2=find(F>=freq_range(2), 1, 'first');
            p1=sum(abs(Xf(ind1:ind2)).^2/N^2);
        end
    end
    
end

