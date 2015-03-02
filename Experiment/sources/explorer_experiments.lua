  package.path = package.path .. ";/Users/nkalde/Dropbox/Code/profiler/?.lua"  
  --ProFi = require 'ProFi'

init_explorer=function()
        --ProFi:start()
        
    --world objects
    agent, objects, humans, items, floor, server, explorers = objectsSet()    
    agentName = simGetObjectName(agent)
    
    --grid parameters
    dilate=simGetScriptSimulationParameter(baseScript,'dilate')
    coef=simGetScriptSimulationParameter(baseScript,'coef')
    minX=simGetScriptSimulationParameter(baseScript,'minX')
    minY=simGetScriptSimulationParameter(baseScript,'minY')
    maxX=simGetScriptSimulationParameter(baseScript,'maxX')
    maxY=simGetScriptSimulationParameter(baseScript,'maxY')
    
    --gradient parameters
    neighborsIndex = simGetScriptSimulationParameter(baseScript,'neighborsFunction')
    neighborsFunction=neighborsFunctions[neighborsIndex]
    gradientFunction=gradientFunctions[simGetScriptSimulationParameter(baseScript,'gradientFunction')]
    
    --planning parameters
    planningFunction=planningFunctions[simGetScriptSimulationParameter(baseScript,'planningFunction')]
    limit=simGetScriptSimulationParameter(baseScript,'depthPlanning')
    heuristicFunction=heuristicFunctions[simGetScriptSimulationParameter(baseScript,'heuristicFunction')]
    
    --navigation parameters
    navigationFunction=navigationFunctions[simGetScriptSimulationParameter(baseScript,'navigationFunction')]
    nominalVelocity=simGetScriptSimulationParameter(baseScript,'robotSpeed')
    
    --exploration parameters
    explorationIndex = simGetScriptSimulationParameter(baseScript,'explorationFunction')
    explorationFunction=explorationFunctions[explorationIndex]
    alpha=simGetScriptSimulationParameter(baseScript,'alpha')
    sigma=simGetScriptSimulationParameter(baseScript,'sigma')
    evalFun=simGetScriptSimulationParameter(baseScript,'evalFun')
    maxTime=simGetScriptSimulationParameter(baseScript,'maxTime')
    distanceIndex=simGetScriptSimulationParameter(baseScript,'distanceFunction')
    distanceFunction=distanceFunctions[distanceIndex]
    radiusView=simGetScriptSimulationParameter(baseScript,'radiusView')    
    
    --monitoring parameters
    monitoringEnabled = simGetScriptSimulationParameter(baseScript,'monitoringEnabled')
    
    --print(agentName,neighborsFunction,gradientFunction,planningFunction,limit,heuristicFunction,navigationFunction,explorationIndex,explorationFunction)
    
    --------------------
    --local parameters--
    --------------------
  
    --navigation
    followingTrajectory = false
    stepTrajectory = nil
    
    --exploration
    explorationGrid()
    
    --monitoring
    if monitoringEnabled then
      monitoringInit()
    end
    cntStep = 0
    cntFront = 0
    
    print(agentName,'START')
--end
end


if (simGetScriptExecutionCount()==0) then
    dofile(os.getenv('PWD')..'/Core/header.lua')
    
    --world objects
    agent, objects, humans, items, floor, server, explorers = objectsSet()    
    agentName = simGetObjectName(agent)
  
    ---------------------
    --global parameters--
    ---------------------
  
    --base script
    baseScript=simGetScriptAssociatedWithObject(server)
    start=false
end

if (start==false and simGetScriptSimulationParameter(baseScript,'start')==1) then
      init_explorer()
      start=true
end

if (start==true) then
  realityGrid()

  if simGetSimulationTime() < maxTime/1000 then  
    --exploration running  
    if (cntStep <= 1 and cntFront == 0) or (cntStep > 0 and cntFront > 0) then
      if followingTrajectory then
        --navigation to target
        navigateAlongNext(vectorGrid2World(plan), agent, stepTrajectory)
      else
        --target selection
        frontiers = extractFrontiers(exploGrid)
        cntFront = #frontiers
        cntStep = cntStep+1
        goal = assignFrontiers(frontiers, explorers)
        --target planning
        plan = planTrajectory(goal, exploCloseGG)
        followTrajectory(plan, nil)
      end  
      
    --exploration terminated
    else 
      if ended == nil then
        ended = true
        simSetScriptSimulationParameter(sim_handle_self,'end',1)
        if monitoringEnabled then
          print(agentName,'END')
          monitoringEnd()
          monitoringEndToFile()
        end
      end
      --ProFi:stop()
  --ProFi:writeReport( os.getenv('PWD')..'/Core/monitoring/data/profiling_'..agentName..'.txt' )
  --print("profiler write report")
    end
  else --terminated 
    if ended == nil then
      ended = true
      simSetScriptSimulationParameter(sim_handle_self,'end',1)
      if monitoringEnabled then
        print(agentName,'ENDMax')
        monitoringEnd()
        monitoringEndToFile()
      end
    end
  end

  --communication part
  writeMapSignal(exploGrid,agent)
  local readMap = readMapSignal({server})
  exploGrid = addMap(exploGrid, readMap)

end

if (simGetSimulationState()==sim_simulation_advancing_lastBeforestop) then
end