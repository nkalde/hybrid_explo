if (simGetScriptExecutionCount()==0) then
  dofile(os.getenv('PWD')..'/Core/header.lua')
  agent, objects, humans, items, floor, server, explorers = objectsSet()    
  
  ---------------------
  --global parameters--
  ---------------------
  baseScript=simGetScriptAssociatedWithObject(server)
  dilate=simGetScriptSimulationParameter(baseScript,'dilate')
  coef=simGetScriptSimulationParameter(baseScript,'coef')
  minX=simGetScriptSimulationParameter(baseScript,'minX')
  minY=simGetScriptSimulationParameter(baseScript,'minY')
  maxX=simGetScriptSimulationParameter(baseScript,'maxX')
  maxY=simGetScriptSimulationParameter(baseScript,'maxY')
  neighborsIndex = simGetScriptSimulationParameter(baseScript,'neighborsFunction')
  neighborsFunction=neighborsFunctions[neighborsIndex]
  --exploration
  explorationGrid()
  distanceIndex=simGetScriptSimulationParameter(baseScript,'distanceFunction')
  distanceFunction=distanceFunctions[distanceIndex]
  radiusView=simGetScriptSimulationParameter(baseScript,'radiusView')
end
     
realityGrid()
updateExplorationGrid(getPoseIJ(agent))
writeMapSignal(exploGrid,agent)

local readMap=readMapSignal(server)
exploGrid=addMap(exploGrid,readMap)
