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
             this=setNumWorkers(this,NumWorkers); 
        end
        
        
        function this=setNumWorkers(this,NumWorkers)
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
                else
                    if nargin>1
                        this.NumWorkers=NumWorkers;
                    end
                end
            else
                this.ERROR.setNumWorkers=MException('executor:setNumWorkers', ...
                        'License %s is required.\n%s',licenseName,err);
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
                %this.ERROR=[];
                this.ERROR = rmfield(this.ERROR,'poolObj');
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
            %run currnetly initiated executor
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

