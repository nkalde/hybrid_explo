if (simGetScriptExecutionCount()==0) then
  dofile(os.getenv('PWD')..'/Core/header.lua')
  agent, objects, humans, items, floor, server, explorers = objectsSet()    
  baseScript=simGetScriptAssociatedWithObject(server)
  agentName=simGetObjectName(agent)
  --grid
  coef=simGetScriptSimulationParameter(baseScript,'coef')
  minX=simGetScriptSimulationParameter(baseScript,'minX')
  minY=simGetScriptSimulationParameter(baseScript,'minY')
  maxX=simGetScriptSimulationParameter(baseScript,'maxX')
  maxY=simGetScriptSimulationParameter(baseScript,'maxY')
  neighborsIndex = simGetScriptSimulationParameter(baseScript,'neighborsFunction')
  neighborsFunction=neighborsFunctions[neighborsIndex]
  
  --plan
  dilate = simGetScriptSimulationParameter(baseScript,'dilate')
  gradientIndex=simGetScriptSimulationParameter(baseScript,'gradientFunction')
  gradientFunction=gradientFunctions[gradientIndex]
  planningIndex=simGetScriptSimulationParameter(baseScript,'planningFunction')
  planningFunction=planningFunctions[planningIndex]
  heuristicIndex=simGetScriptSimulationParameter(baseScript,'heuristicFunction')
  heuristicFunction=heuristicFunctions[heuristicIndex]
  
  --navigation
  limit=simGetScriptSimulationParameter(baseScript,'depthPlanning')
  nominalVelocity=simGetScriptSimulationParameter(baseScript,'robotSpeed')
  followingTrajectory = false
  stepTrajectory = nil
  navigationIndex=simGetScriptSimulationParameter(baseScript,'navigationFunction')
  navigationFunction=navigationFunctions[navigationIndex]
  
  --exploration
  explorationGrid()
  explorationIndex = simGetScriptSimulationParameter(baseScript,'explorationFunction')
  explorationFunction=explorationFunctions[explorationIndex]
  alpha=simGetScriptSimulationParameter(baseScript,'alpha')
  sigma=simGetScriptSimulationParameter(baseScript,'sigma')
  distanceIndex=simGetScriptSimulationParameter(baseScript,'distanceFunction')
  distanceFunction=distanceFunctions[distanceIndex]
  radiusView=simGetScriptSimulationParameter(baseScript,'radiusView')
  
  --communication
end
     
--update
realityGrid()
updateExplorationGrid(getPoseIJ(agent))

--communication
writeMapSignal(exploGrid,agent)
local readMap=readMapSignal(server)
exploGrid=addMap(exploGrid,readMap)

if followingTrajectory then
  --target navigation
  navigateAlongNext(vectorGrid2World(plan), agent, stepTrajectory)
else
  --target selection
  frontiers = extractFrontiers(exploGrid)
  goal = assignFrontiers(frontiers, explorers)
  
  --target planning
  plan = planTrajectory(goal, exploCloseGG)
  followTrajectory(plan, nil)
end