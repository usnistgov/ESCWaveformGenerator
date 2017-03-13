%% This function is only to be called by filter_downsample_save_func_main
% This function actually does the frequency & time shifts, parses QI (not
% IQ), and 
% Note: The data in the radar files starts with the out of phase component
% followed by in-phase (QI).  Reversing these results in a negative
% frequency and a phase shift of pi/4.
%
% Written by Raied Caromi & John Mink
% Version: 1.0
% Date: 24 Feb 2017

function [data_out_interleaved,x_filt]=parDecimate_sub_segment(Hd,t0,samplesPerSegment,Data_Interleaved,freq_shift,old_Fs,new_Fs,DEBUG)
    %%    
    %%%%%%%%%%%%%%%%%%%%
    %%% Setup Params %%%
    %%%%%%%%%%%%%%%%%%%%
    old_Ts=1/old_Fs;
    
    N=samplesPerSegment;
    %% 
    %************************************************
    %NOTE THE REVERSAL OF I & Q, this is intentional!
    %************************************************
    Data_A=Data_Interleaved(1:2:end);
    Data_B=Data_Interleaved(2:2:end); clear Data_Interleaved;
    Data_IQ=complex(Data_B,Data_A); clear Data_A Data_B;
    %% 
    %%%%%%%%%%%%%%%%%
    %%% Decimcate %%%
    %%%%%%%%%%%%%%%%%
    % Time Shift
    t=((0:N-1).')*old_Ts+t0; %t=t0+linspace(0,samplesPerSegment/Fs,N)';
    
    % Freq Shift
    xmod=Data_IQ.*exp(1i*2*pi*(freq_shift)*t); clear Data_IQ;
    
    % Step through filter
    x_filt = filter(Hd,xmod);
    
    % Decimate
    [p,q] = rat(new_Fs / old_Fs);
    x_up=upsample(x_filt,p);
    x_res=downsample(x_up,q);
    
    %% Rewrite decimated data for file.  Note that this maintains QI order.
    data_out(:,1)=imag(x_res);
    data_out(:,2)=real(x_res);
    clear x_res;
    data_out_interleaved=reshape(data_out.',[],1); clear data_out;

end %function call