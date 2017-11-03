# 3.5 GHz Waveform Generation for Testing and Development of ESC Detectors
<!-- TOC -->

- [3.5 GHz Waveform Generation for Testing and Development of ESC Detectors](#35-ghz-waveform-generation-for-testing-and-development-of-esc-detectors)
    - [1. Legal Disclaimers](#1-legal-disclaimers)
        - [Software Disclaimer](#software-disclaimer)
        - [Commercial Disclaimer](#commercial-disclaimer)
    - [2. Outline](#2-outline)
    - [3. Prerequisites for generating waveforms:](#3-prerequisites-for-generating-waveforms)
        - [Prerequisites for Deployment:](#prerequisites-for-deployment)
        - [Files to Deploy and Package](#files-to-deploy-and-package)
        - [Definitions](#definitions)

<!-- /TOC -->
![ESC Icon](src/res/icon.ico)
## 1. Legal Disclaimers
### Software Disclaimer
 NIST-developed software is provided by NIST as a public service. 
 You may use, copy and distribute copies of the software in any medium,
 provided that you keep intact this entire notice. You may improve,
 modify and create derivative works of the software or any portion of
 the software, and you may copy and distribute such modifications or
 works. Modified works should carry a notice stating that you changed
 the software and should note the date and nature of any such change.
 Please explicitly acknowledge the National Institute of Standards and
 Technology as the source of the software.
 
 NIST-developed software is expressly provided "AS IS." NIST MAKES NO
 WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY
 OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT
 AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE
 OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR
 THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY 
 REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS 
 THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY,
 RELIABILITY, OR USEFULNESS OF THE SOFTWARE.
 
 You are solely responsible for determining the appropriateness of
 using and distributing the software and you assume all risks
 associated with its use, including but not limited to the risks and
 costs of program errors, compliance with applicable laws, damage to 
 or loss of data, programs or equipment, and the unavailability or
 interruption of operation. This software is not intended to be used in
 any situation where a failure could cause risk of injury or damage to
 property. The software developed by NIST employees is not subject to
 copyright protection within the United States.

### Commercial Disclaimer
 Certain commercial equipment, instruments, or materials are identified in this paper to foster understanding. Such identification does not imply recommendation or endorsement by the National Institute of Standards and Technology, nor does it imply that the materials or equipment identified are necessarily the best available for the purpose.
 
## 2. Outline

- A simple Matlab framework for reading/saving signals from/to large files 
- Signal processing for decimating radar field-measured waveforms 
- Signal processing for mixing radar field-measured waveforms with interference signals
- The GUI simplifies the selection of certain parameters such as signal power levels, and randomizes other parameters such as start time, and frequency
- Automates the generation of multiple waveform files 
- Generate waveforms for developing detection algorithm of incumbent radar for 3.5 GHz spectrum sharing
- Generate training data for machine learning based algorithms 
- Current development using Matlab 2017b
- The Generation tool can be compiled and deployed
- For more information see [WInnComm Presentation](docs/3.5_GHz_Waveform_Generation_for_Testing_and_Development_of_ESC_Detectors_WInnComm2017.pdf)

This tool has both a GUI & 


## 3. Prerequisites for generating waveforms:
1. Requires field measured radar waveforms 
    * [3.5 GHz Radar Waveform Capture at Point Loma Final Test Report](https://www.nist.gov/publications/35-ghz-radar-waveform-capture-point-loma)

    * [3.5 GHz Radar Waveform Capture at Fort Story Final Test Report](https://www.nist.gov/publications/35-ghz-radar-waveform-capture-fort-story-final-test-report)
    
2. Files can be reduced in size using the included Decimator from the raw 225 MHz down to 25 MHz.  See the example testDecimate.m located at:

    *  src\tests\testDecimate.m

3. Evaluate main sweep peaks of radar one files and save them in the same directory, e.g. see peaks finder code. These are necessary for setting power levels or target SIR per definition. 
4. SIR is defined as:
5. Additional interference signals must be generated and saved in files before mixing
   a. LTE signals are generated as 90 sec length, up-sampled to 25 MHz and saved to files
   b. Adjacent band interference (ABI) are extracted from NACTN field measured radar waveforms and decimated to 25 MHz
The GUI application is currently limited to process two radar one files, two LTE signals, and one ABI signal. All files must be on the binary IQ format with 25 MHz sampling rates. However, the framework can be used for different sampling rates. 

### Prerequisites for Deployment:
Verify that version 9.3 (R2017b) of the MATLAB Runtime is installed.   

If the MATLAB Runtime is not installed, you can run the MATLAB Runtime installer.
To find its location, enter
  
    >>mcrinstaller
      
at the MATLAB prompt.

Alternatively, download and install the Windows version of the MATLAB Runtime for R2017b 
from the following link on the [MathWorks website](http://www.mathworks.com/products/compiler/mcr/index.html)
   
For more information about the MATLAB Runtime and the MATLAB Runtime installer, see 
Package and Distribute in the MATLAB Compiler documentation  
in the MathWorks Documentation Center.    

NOTE: You will need administrator rights to run the MATLAB Runtime installer. 


### Files to Deploy and Package

Files to Package for Standalone: 
* ESCWaveformGenerator.exe
* MCRInstaller.exe 
    Note: if end users are unable to download the MATLAB Runtime using the
    instructions in the previous section, include it when building your 
    component by clicking the "Runtime downloaded from web" link in the
    Deployment Tool.
* This readme file 

### Definitions

For information on deployment terminology, go to
http://www.mathworks.com/help and select MATLAB Compiler >
Getting Started > About Application Deployment >
Deployment Product Terms in the MathWorks Documentation
Center.