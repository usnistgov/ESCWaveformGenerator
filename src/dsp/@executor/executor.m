classdef executor
    %Organize parallel and sequential execution of tasks
    %   Detailed explanation goes here
    
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
            localCluster= parcluster('local');
            maxNumWorkers=localCluster.NumWorkers;
            if NumWorkers>maxNumWorkers || NumWorkers<=0
                ME=MException('executor:NumWorkers', ...
                    'NumWorkers=%d must be >0 and <=%d',NumWorkers,maxNumWorkers);
               throw(ME);
            else
            this.NumWorkers=NumWorkers;
            end  
        end
        
        function this=initParallel(this)
            this.ERROR.poolObj=[];
            localCluster= parcluster('local');
            maxNumWorkers=localCluster.NumWorkers;
            if this.NumWorkers>maxNumWorkers
                this.ERROR.poolObj=MException('executor:initPar', ...
                    'NumWorkers=%d must be less or equal to maxNumWorkers=%d',this.NumWorkers,maxNumWorkers);
                throw(this.ERROR.poolObj);
            else
                try
                    %ME=[];
                    %minNumWorkers=20; %Set to desired number of workers (do not exceed # cores in system)
                    this.poolObj = gcp('nocreate'); % If no pool, do not create new one.
                    
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
            end
            if isempty(this.ERROR.poolObj)
                this.ERROR=[];
                this.parallelState=true;
            else
                this.parallelState=false;
            end
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

