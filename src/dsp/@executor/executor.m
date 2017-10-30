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

classdef executor
    %Organize parallel and sequential execution of tasks
   
    properties
        numFiles
        useParallel            char
        parallelState          logical % report state of par 
        NumWorkers=20         % default min number of workers 
        poolObj
        ERROR
        
    end
    
    
    methods
        % construct waveforms objects numFiles
        % start parallel%%%done
        % run serial
        % run parallel
        function this=executor(numFiles)
            if nargin>0
                this.numFiles=numFiles;
            end
        end
        
        function this=set.useParallel(this,useParallel)
         possIn={'On','Off'};
            if ismember(useParallel,possIn)
                this.useParallel=useParallel;
            else
                ME = MException('executor:invalidInput', ...
                    'useParallel must be one of these values: %s',strjoin(possIn));
                throw(ME);
            end
        end
        
        function this=set.NumWorkers(this,NumWorkers) 
             [this,NumWorkersOut]=setNumWorkers(this,NumWorkers); 
             this.NumWorkers=NumWorkersOut;
        end
        
        
        function [this,NumWorkersOut]=setNumWorkers(this,NumWorkers)
            if nargin<2
                NumWorkers=this.NumWorkers;
            end
            
            licenseName='Distrib_Computing_Toolbox';
            [hasLicense,err]=utilFun.licenseCheck(licenseName);

            if hasLicense
                localCluster= parcluster('local');
                maxNumWorkers=localCluster.NumWorkers;
                
                if NumWorkers>maxNumWorkers || NumWorkers<=0
                    this.ERROR.setNumWorkers=MException('executor:setNumWorkers', ...
                        'NumWorkers=%d must be >0 and <=%d',NumWorkers,maxNumWorkers);
                    throw(this.ERROR.setNumWorkers);
                else
                    if nargin>1
                        NumWorkersOut=NumWorkers;
                    end
                end
            else
                this.ERROR.setNumWorkers=MException('executor:setNumWorkers', ...
                        'License %s is required.\n%s',licenseName,err);
                    throw(this.ERROR.setNumWorkers);
            end %hasLicense
        end
        
        function this=initParallel(this)
            this.ERROR.poolObj=[];
            try
                %Do not create a pool if one with the correct number of
                %workers already exists
                
                this=setNumWorkers(this);
                this.poolObj = gcp('nocreate');
                
                if isempty(this.poolObj)
                    currentNumWorkers = 0;
                else
                    currentNumWorkers = this.poolObj.NumWorkers;
                end
                
                if currentNumWorkers~=this.NumWorkers
                    delete(this.poolObj)
                    this.poolObj=parpool(this.NumWorkers);
                end
                
            catch ME
                this.ERROR.poolObj=ME;
            end

            if isempty(this.ERROR.poolObj)
                this.ERROR=[];
                this.parallelState=true;
            else
                this.parallelState=false;
            end
            %}
        end
        
        function this=updateParalelState(this)
            %checks for par current state
            if ~isempty(this.poolObj) && (this.poolObj.Connected)
                this.parallelState=true;
            else
                 this.parallelState=false;
            end
        end
                
        function this=executeSequential(this)
            %generate signals sequentially 
        end
        
        function this=executeParallel(this)
            %generate signals in parallel
        end
        
        function this=runExecutor(this)
            %run currently initiated executor
            switch this.useParallel
                case 'On'
                    this=updateParalelState(this);
                    if ~this.parallelState
                        this=initParallel(this);
                    end
                    this=executeParallel(this);
                case 'Off'
                    this=executeSequential(this);
            end
        end
    end
    
end

