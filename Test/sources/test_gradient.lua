--Server test gradient
--if (simGetScriptExecutionCount()==0) then
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
 
  --thread
  simSetThreadSwitchTiming(200)
  simDelegateChildScriptExecution()   
 
  while (simGetSimulationState()~=sim_simulation_advancing_abouttostop) do
     -- INITIALIZATION
    local goalHandle=simGetObjectHandle('Bill')
    local goalPos=simGetObjectPosition(goalHandle, -1)
    local goalI, goalJ=mappingWorld2Grid(goalPos[1], goalPos[2])
    local targetPos=simGetObjectPosition(agent, -1)
    local targetI, targetJ= mappingWorld2Grid(targetPos[1], targetPos[2])
  
    --TEST NEIGHBORS
    print('\nTest neighbors')
    for i=1,#neighborsFunctions do
      neighborsFunction = neighborsFunctions[i]
      print('',neighborsNames[i])
      ---[[
      local insideI, insideJ= mappingWorld2Grid(maxX/2,maxY/2)
      local minI, minJ=mappingWorld2Grid(minX,minY)
      local maxI, maxJ=mappingWorld2Grid(maxX,maxY)
      printNeighbors(insideI,insideJ,neighborsFunction) --inside ok
      printNeighbors(minI,minJ,neighborsFunction) --corner ok 
      printNeighbors(minI,maxJ-1,neighborsFunction) --corner ok
      printNeighbors(maxI-1,minJ,neighborsFunction) --corner ok
      printNeighbors(maxI-1,maxJ-1,neighborsFunction) --corner ok
      printNeighbors(minI,insideJ,neighborsFunction) --edge ok
      printNeighbors(maxI-1,insideJ,neighborsFunction) --edge ok 
      printNeighbors(insideI,minJ,neighborsFunction) --edge ok
      printNeighbors(insideI,maxJ-1,neighborsFunction) --edge ok
      --]]
      
      ---[[
      --TEST GRADIENT
      print('','Test Gradient')
      for j=1,#gradientFunctions do
        gradientFunction = gradientFunctions[j]
        print('','',gradientNames[j])
        fullGG()
        gradientFunction({{goalI, goalJ}},0,neighborsFunction,{targetI, targetJ})
        printGradient()
        drawGradient()
        simSwitchThread()
        --simWait(0.5,false)
      end
      --]]
    end
  end