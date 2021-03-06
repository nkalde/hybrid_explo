--Server threaded
  dofile(os.getenv('PWD')..'/Core/header.lua')
  --dofile(os.getenv('PWD')..'/Evaluation/header.lua')
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
  neighborsIndex = simGetScriptSimulationParameter(sim_handle_self,'neighborsFunction')
  neighborsFunction = neighborsFunctions[neighborsIndex]
  simSetThreadSwitchTiming(simGetSimulationTimeStep()*1000)
  simDelegateChildScriptExecution()
  serverMap=initRMap()
  distanceIndex=simGetScriptSimulationParameter(sim_handle_self,'distanceFunction')
  distanceFunction=distanceFunctions[distanceIndex]
  radiusView=simGetScriptSimulationParameter(sim_handle_self,'radiusView')
  
  print('TEST FRONTIERS')
 
while (simGetSimulationState()~=sim_simulation_advancing_abouttostop) do
  --communication
  local readMap = readMapSignal(explorers)
  serverMap = addMap(serverMap, readMap)
  writeMapSignal(serverMap,server)
  
  --drawing
  local frontiers=extractFrontiers(serverMap)
  drawExploMap(serverMap)
  drawFrontiersG(frontiers,explorers,humans)
  exploGrid=serverMap
  
  local targets, cellsL=regroupFrontiers(frontiers, robots, humans)
  getFrontiersOrientation(cellsL,targets,explorers[2])

  simSwitchThread()
  simWait(1) 
  
end