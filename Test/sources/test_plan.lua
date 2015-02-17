--test plan
  dofile(os.getenv('PWD')..'/Core/header.lua')
  agent, objects, humans, items, floor, server, explorers = objectsSet()

  --grid parameters (size, resolution, neighborhood)
  r, minX=simGetObjectFloatParameter(floor,15)
  r, maxX=simGetObjectFloatParameter(floor,18)
  r, minY=simGetObjectFloatParameter(floor,16)
  r, maxY=simGetObjectFloatParameter(floor,19)
  r, minZ=simGetObjectFloatParameter(floor,17)
  r, maxZ=simGetObjectFloatParameter(floor,20)
  minX=math.floor(minX)
  minY=math.floor(minY)
  minZ=math.floor(minZ)
  maxX=math.ceil(maxX)
  maxY=math.ceil(maxY)
  maxZ=math.ceil(maxZ)
  if maxX <= 1 then
    maxX=maxZ
    minX=minZ
  end
  if maxY <= 1 then
    maxY=maxZ
    minY=minZ
  end
  simSetScriptSimulationParameter(sim_handle_self,'minX',minX)
  simSetScriptSimulationParameter(sim_handle_self,'minY',minY)
  simSetScriptSimulationParameter(sim_handle_self,'maxX',maxX)
  simSetScriptSimulationParameter(sim_handle_self,'maxY',maxY)
  coef = simGetScriptSimulationParameter(sim_handle_self,'coef')
  dilate = simGetScriptSimulationParameter(sim_handle_self,'dilate')
  neighborsIndex = simGetScriptSimulationParameter(sim_handle_self,'neighborsFunction')
  neighborsFunction = neighborsFunctions[neighborsIndex]
  gradientIndex=simGetScriptSimulationParameter(sim_handle_self,'gradientFunction')
  gradientFunction=gradientFunctions[gradientIndex]
  limit=simGetScriptSimulationParameter(sim_handle_self,'depthPlanning')

  --thread
  simSetThreadSwitchTiming(200)
  simDelegateChildScriptExecution()
 
  while (simGetSimulationState()~=sim_simulation_advancing_abouttostop) do
     -- INITIALIZATION
    local goalHandle=simGetObjectHandle('Bill')
    local goalPos=simGetObjectPosition(goalHandle, -1)
    local goalI, goalJ =mappingWorld2Grid(goalPos[1], goalPos[2])
    local targetPos=simGetObjectPosition(agent, -1)
    local targetI, targetJ= mappingWorld2Grid(targetPos[1], targetPos[2])
  
    print('','','Test Planning')
    for k=1,#planningFunctions do
      planningFunction = planningFunctions[k]
      print('','','',planningNames[k])
      local plan = nil
      if planningNames[k] == 'lrtaStar' then
        for l=1,#heuristicFunctions do
          heuristicFunction = heuristicFunctions[l]
          print('','','',heuristicNames[l])
          plan = planTrajectory(goalHandle,fullGG)
        end
      else        
        plan = planTrajectory(goalHandle,fullGG)
      end
      drawTrajectory(plan)
      simSwitchThread()
    end
  end