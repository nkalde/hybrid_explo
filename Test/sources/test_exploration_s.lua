--Server threaded
  dofile(os.getenv('PWD')..'/Core/header.lua')
  agent, objects, humans, items, floor, server, explorers = objectsSet()
  
  --grid
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
  neighborsIndex = simGetScriptSimulationParameter(sim_handle_self,'neighborsFunction')
  neighborsFunction = neighborsFunctions[neighborsIndex]
  
  --plan
  dilate = simGetScriptSimulationParameter(sim_handle_self,'dilate')
  gradientIndex=simGetScriptSimulationParameter(sim_handle_self,'gradientFunction')
  gradientFunction=gradientFunctions[gradientIndex]
  planningIndex=simGetScriptSimulationParameter(sim_handle_self,'planningFunction')
  planningFunction=planningFunctions[planningIndex]
  heuristicIndex=simGetScriptSimulationParameter(sim_handle_self,'heuristicFunction')
  heuristicFunction=heuristicFunctions[heuristicIndex]
  limit=simGetScriptSimulationParameter(sim_handle_self,'depthPlanning')
  
  --navigation
  nominalVelocity=simGetScriptSimulationParameter(sim_handle_self,'robotSpeed')
  navigationIndex=simGetScriptSimulationParameter(sim_handle_self,'navigationFunction')
  navigationFunction=navigationFunctions[navigationIndex]
  
  --exploration
  explorationIndex = simGetScriptSimulationParameter(sim_handle_self,'explorationFunction')
  explorationFunction=explorationFunctions[explorationIndex]
  alpha=simGetScriptSimulationParameter(sim_handle_self,'alpha')
  sigma=simGetScriptSimulationParameter(sim_handle_self,'sigma')
  distanceIndex=simGetScriptSimulationParameter(sim_handle_self,'distanceFunction')
  distanceFunction=distanceFunctions[distanceIndex]
  radiusView=simGetScriptSimulationParameter(sim_handle_self,'radiusView')
  
  --communication
  serverMap=initRMap()
  centralizedIndex = simGetScriptSimulationParameter(sim_handle_self,'centralizedMerging')
  merge = merges[centralizedIndex]
  centralizedMerging = merge
  
  ---[[
  print('\v#####################')
  print('SIMULATION PARAMETERS')
  print('#####################')
  print('\nGrid')
  print('\tdimensions (m2):\t'..''..maxX-minX..'X'..maxY-minY)
  print('\tcell (m):\t\t'..coef)
  print('\tneighbors:\t\t'..neighborsNames[neighborsIndex])
      
  print('\nPlanning')
  print('\tdilatation :\t\t'..dilate)
  print('\tgradient :\t\t'..gradientNames[gradientIndex])
  print('\tplanning :\t\t'..planningNames[planningIndex])
  print('\theuristic :\t\t'..heuristicNames[heuristicIndex])
  print('\tmaximum depth :\t\t'..limit)
  
  print('\nNavigation')
  print('\tvelocity :\t\t'..nominalVelocity)
  print('\tnavigation :\t\t'..navigationNames[navigationIndex])

  print('\nExploration')
  print('\tmethod :\t\t'..explorationNames[explorationIndex])
  print('\tdistanceView :\t\t'..distanceNames[distanceIndex])
  print('\tradiusView :\t\t'..radiusView)
  print('\talpha :\t\t\t'..alpha)
  print('\tsigma :\t\t\t'..sigma)
  
  print('\nCommunication')
  print('\tcentralized :\t\t'..merge)
  --print('\nMonitoring')
  --print('\tmethod :\t\t'..monitoring)
  
  print('\nWorld')
  --print('\tdensity :\t\t'..densityH)
  print('\t#explorers :\t\t'..#explorers)
  print('\t#humans :\t\t'..#humans)
  print('\t#items :\t\t'..#items)
  print('#####################\v')
  --]]
  
  simSetThreadSwitchTiming(simGetSimulationTimeStep()*1000)
  simDelegateChildScriptExecution()

while (simGetSimulationState()~=sim_simulation_advancing_abouttostop) do
  --communication
  local readMap = readMapSignal(explorers)
  serverMap = addMap(serverMap, readMap)
  writeMapSignal(serverMap,server)
    
  --drawing
  local frontiers=extractFrontiers(serverMap)
  drawExploMap(serverMap)
  drawFrontiersG(frontiers,explorers,humans)
  simSwitchThread()
  simWait(1) 
end