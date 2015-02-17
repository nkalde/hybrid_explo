--test navigation --sfm crashes segfault
if (simGetScriptExecutionCount()==0) then
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
  planningIndex=simGetScriptSimulationParameter(sim_handle_self,'planningFunction')
  planningFunction=planningFunctions[planningIndex]
  heuristicIndex=simGetScriptSimulationParameter(sim_handle_self,'heuristicFunction')
  heuristicFunction=heuristicFunctions[heuristicIndex]
  
  --navigation
  nominalVelocity=simGetScriptSimulationParameter(sim_handle_self,'walkingSpeed')
  followingTrajectory = false
  stepTrajectory = nil
  navigationIndex=simGetScriptSimulationParameter(sim_handle_self,'navigationFunction')
  navigationFunction=navigationFunctions[navigationIndex]
  goalHandle=simGetObjectHandle('Bill#0')
  
end
  
  --TEST NAVIGATION
  print('','Test Navigation')
  print('','',navigationNames[navigationIndex])
  if followingTrajectory then
    --navigation to target
    navigateAlongNext(vectorGrid2World(plan), agent, stepTrajectory)
  else
    --planning to target
    plan = planTrajectory(goalHandle, fullGG)
    followTrajectory(plan, nil)
  end