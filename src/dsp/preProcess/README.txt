== parDecimate README ==
    parDecimate is a group of MATLAB scripts designed to read multiple large files of data, process them in segments, and write the output to a different file.

    parDecimate consists of 6 files & 1 folder:
 
    0) This README

    1)  parDecimate_main.m
            The main file.  All other files are called from this script.  It handles the metadata of each file & dataset, as well as the parallel.

    2)  parDecimate_sub_file.m
            A sub script called from parDecimate_main.m.  This script handles an individual file, by taking the file name & opening the old file.  It also tracks the segments within a file passing that to parDecimate_sub_segment, and receiving the shifted values back to write to the new file. The filter for decimation is also created and handled here, so that it can retain it's state between segments (but NOT between files).
    
    3)  parDecimate_sub_segment.m
            A "sub" script called from parDecimate_main.m.  This script actually does the decimation & frequency shift across an individual segment, returning the result as an array.
   
    4)  parDecimate_sub_parse_metadata.m
            A "sub" script called from parDecimate_sub_segment.m.   This script parses the metadata from the ".xls" file and creates a struct with all the metadata (center frequency of detection unit, human readable description, so on)

    5) radar_freq_noted.mat
	    An array (radar_freq_noted) which contains the frequency of the radar.  This is subtracted from the recorded LO (in the metadata file) to generate the freqeuncy shift.  So setting this to zero will shift the LO to DC; set to LO frequency to avoid any shifting.  If this file is missing, either create a new file or manually add the values into the script.

    6) Extras folder
           This folder contains scripts that are not directly called by parDecimate, but may be useful, eg for verifying filesize/samplecount.



== Requirements == 
    1)  MATLAB license
    2)  MATLAB Signal toolbox (for filter)

    optional:
    1)  MATLAB parallel toolbox



== How to Run (quick) == 
    This is designed to serve as a reminder, not a complete list.
    0) open parDecimate_main.m
    1) Change filepaths: 
        a) radar_dir
        b) save_dir
    2) verify the array radar_freq_noted
    3) run parDecimate_main.m

== How to Run (non-par) == 
    If you don't have a parallel license for MATLAB, os simply don't wish to use it (even after seeing the "expected runtime section"), the following steps should remove any need for that toolbox

    1) disable (comment out) the section labeled  Create Parallel Pool.  It should be directly below the notes.
    2) change the for loop (in the "run program section") to "for" instead of "parfor"
    3) Run as normal 

== How to Run (detailed) == 

    == Before Running ==
    1) Verify you have a valid matlab license for the required toolboxes (see requirements)
    2) Place all radar data (and metadata) in the same file, specified by radar_dir
    3) Verify that save_dir (the location where the decimated data will be written to) actually exists.
    4) Verify that the variable radar_freq_noted is correct, as this is the new frequency to which the signal will be shifted.
    5) Verify that all 4 MATLAB scripts for this program (listed in the intro section of this document) are in the same folder.

    == To Begin Run ==
    1) Consider whether you wish to clear the matlab workspace.  
    2) Run parDecimate_main.m

    == After Running ==
    Compare_Decimation_Filesize.m is a tool used to verify the size of the file. NOTE: This only looks at the number of bytes of the file, it does not attempt to verify the actual data is correct.
        


== Expected Runtime ==
    parallel: ~8 hours for 35 files
    nonparallel: ~3 hours per file

    This being a parallel system, it's tricky to know exactly how it will scale...but it's not going to be quick!



== Important Notes ==

1) IQ (vs QI) 
    The radar data provided to us  was QI instead of IQ.  This means that within the 'word' making up a single sample, the Quadrature Data was listed before the In-Phase data.  So rather than IQIQIQ we see QIQIQI in the file.
    
    Note that I & Q are each 16bit samples so a single complex value will be a total of 32 bits.  Of course, it takes more memory in matlab once it is converted to a double

2) Segment Size
 As these files are too large to read in a whole file at once, files are divided into segments.  This is done with the variable samplesPerSegment. That, along with the file size, is used to determine how many segments the file is divided into.  ***IMPORTANT***   samplesPerSegment MUST divide evenly into the sampling rate ratio.  That is to say, if you decimate by a factor of 9, the number of samples per segment MUST be divisible by 9, or you will not have the correct number of samples.  This can be checked using the standalone script Compare_Decimation_Filesize

== I/O ==
    Inputs:
        1) Radar Metadata (xls)
        1) Radar Data (in provided file location)
    
    Outputs:
        1) decimated Radar Data (in provided file location)
        2) runtime (in MATLAB)