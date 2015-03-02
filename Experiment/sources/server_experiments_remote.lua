--Server threaded
  --dofile(os.getenv('PWD')..'/Util/header.lua')
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
  
  --PARAMETERS FOR EXPERIMENTS-
  local nbR = simGetStringParameter(sim_stringparam_app_arg1)
  local densityH = simGetStringParameter(sim_stringparam_app_arg2)
  local exploR = simGetStringParameter(sim_stringparam_app_arg3)
  local alpha = simGetStringParameter(sim_stringparam_app_arg4)
  local sigma = simGetStringParameter(sim_stringparam_app_arg5)
  local maxTime = simGetStringParameter(sim_stringparam_app_arg6)
  local evalFun = simGetStringParameter(sim_stringparam_app_arg8)
  
  print(' nbr '..nbR..' den '..densityH..' opt '..exploR..' alp '..alpha..' sig '..sigma..' max '..maxTime..' evalFun '..evalFun)
  
  if nbR == '' and densityH == '' and exploR == '' and alpha == '' and sigma == '' and maxTime == '' and evalFun == '' then --default value
    nbR, densityH, exploR, alpha, sigma, maxTime, evalFun = '2','0','1','0','0','300000','1'
  end
  
  nbR = tonumber(nbR)
  densityH = tonumber(densityH)
  exploR = tonumber(exploR)+7
  alpha = tonumber(alpha)
  sigma = tonumber(sigma)
  maxTime = tonumber(maxTime)
  evalFun = tonumber(evalFun)
  
  simSetScriptSimulationParameter(sim_handle_self,'numberExplorers',nbR)
  simSetScriptSimulationParameter(sim_handle_self,'ratio',densityH)
  simSetScriptSimulationParameter(sim_handle_self,'explorationFunction',exploR)
  simSetScriptSimulationParameter(sim_handle_self,'alpha',alpha)
  simSetScriptSimulationParameter(sim_handle_self,'sigma',sigma)
  simSetScriptSimulationParameter(sim_handle_self,'maxTime',maxTime)
  simSetScriptSimulationParameter(sim_handle_self,'evalFun',evalFun)
  print("#rob : "..nbR," #den : "..densityH," exp : "..exploR," alp : "..alpha," sig : "..sigma.." evalFun : "..evalFun)
  
  --monitoringBeginToFile()
  --densify
  ratio = tonumber(simGetScriptSimulationParameter(sim_handle_self,'ratio'))
  --densifyUFS(ratio)
  agent, objects, humans, items, floor, server, explorers = objectsSet()
  baseScript=simGetScriptAssociatedWithObject(server)

  --gradient
  --neighborsFunctions = {neighborsVonNeumann, neighborsMoore}
  neighborsIndex = simGetScriptSimulationParameter(sim_handle_self,'neighborsFunction')
  neighborsFunction = neighborsFunctions[neighborsIndex]
  
  --gradientFunctions = {gradientNewMooreSqrt2, gradientNew, gradientNewFromTargetToOrigin}
  gradientIndex=simGetScriptSimulationParameter(sim_handle_self,'gradientFunction')
  gradientFunction=gradientFunctions[gradientIndex]

  --planif
  --planificationFunctions = {simplePlanifNewCoord,simplePlanif,simplePlanifNew,dStarLite,lpaStar,lrtaStar}
  planningIndex = simGetScriptSimulationParameter(sim_handle_self,'planningFunction')
  planningFunction=planningFunctions[plannningIndex]
  limit=simGetScriptSimulationParameter(sim_handle_self,'depthPlanning')
  
  --navig
  --navigations = {constantVelocity,teleportTo,navigateTo,SFMNew}
  navigationIndex = simGetScriptSimulationParameter(sim_handle_self,'navigationFunction')
  navigationFunction=navigationFunctions[planificationIndex]

  --explo
  --explorationFunctions = {exploreRandom,exploreByFollowingHuman,exploreHumanTracesMin,exploreHumanTracesMax,SRFBEGreedyMin,SRFBEGreedyMax}
  explorationIndex = simGetScriptSimulationParameter(sim_handle_self,'explorationFunction')
  explorationFunction=explorationFunctions[explorationIndex]
  distanceIndex=simGetScriptSimulationParameter(sim_handle_self,'distanceFunction')
  distanceFunction=distanceFunctions[distanceIndex]
  radiusView=simGetScriptSimulationParameter(sim_handle_self,'radiusView')
  nominalVelocity = simGetScriptSimulationParameter(sim_handle_self,'robotSpeed')
  
  --monitoring
  monitoringIndex = simGetScriptSimulationParameter(sim_handle_self,'monitoringEnabled')
  monitoring=monitorings[monitoringIndex]
  monitoringEnabled = monitoringIndex

  --communication
  mergesIndex = simGetScriptSimulationParameter(sim_handle_self,'centralizedMerging')
  merge = merges[mergesIndex]
  centralizedMerging = merge
  serverMap = initRMap()
  clientMaps = {}
  monitoringMap = initRMap()
  simSetScriptSimulationParameter(sim_handle_self,'start',1)
  
  ---[[
  print('\v#####################')
  print('SIMULATION PARAMETERS')
  print('#####################')
  print('\nGrid')
  print('\tdimensions (m2):\t'..''..maxX-minX..'X'..maxY-minY)
  print('\tcell (m):\t\t'..coef)
  print('\tneighbors:\t\t'..neighborsNames[neighborsIndex])
  
  print('\nPlanning')
  --print('\tdilatation :\t\t'..dilate)
  print('\tgradient :\t\t'..gradientNames[gradientIndex])
  print('\tplanning :\t\t'..planningNames[planningIndex])
  --print('\theuristic :\t\t'..heuristicNames[heuristicIndex])
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
  print('\tevalFun :\t\t'..evaluationNames[evalFun])
 
  print('\nCommunication')
  print('\tcentralized :\t\t'..merge)
  --print('\nMonitoring')
  --print('\tmethod :\t\t'..monitoring)
  
  print('\nWorld')
  print('\tdensity :\t\t'..densityH)
  print('\t#explorers :\t\t'..#explorers)
  print('\t#humans :\t\t'..#humans)
  print('\t#items :\t\t'..#items)

  print('#####################\v')
  --]]

simSetThreadSwitchTiming(200)

-- Choose a port that is probably not used (try to always use a similar code):
simSetThreadAutomaticSwitch(false)
local portNb=simGetIntegerParameter(sim_intparam_server_port_next)
local portStart=simGetIntegerParameter(sim_intparam_server_port_start)
local portRange=simGetIntegerParameter(sim_intparam_server_port_range)
local newPortNb=portNb+1
if (newPortNb>=portStart+portRange) then
  newPortNb=portStart
end
simSetIntegerParameter(sim_intparam_server_port_next,newPortNb)
simSetThreadAutomaticSwitch(true)
  -- Check what OS we are using:
platf=simGetIntegerParameter(sim_intparam_platform)
if (platf==0) then
  pluginFile='v_repExtRemoteApi.dll'
end
if (platf==1) then
  pluginFile='libv_repExtRemoteApi.dylib'
end
if (platf==2) then
  pluginFile='libv_repExtRemoteApi.so'
end

  -- Check if the required remote Api plugin is there:
moduleName=0
moduleVersion=0
index=0
pluginNotFound=true
while moduleName do
  moduleName,moduleVersion=simGetModuleName(index)
  if (moduleName=='RemoteApi') then
    pluginNotFound=false
  end
  index=index+1
end

if (pluginNotFound) then
  -- Plugin was not found
  print('Error plugin')--,"Remote Api plugin was not found. ('"..pluginFile.."')&&nSimulation will not run properly")
else
  simExtRemoteApiStart(portNb,1300,false,true) -- this server function will automatically close again at simulation end
  result=simLaunchExecutable("/Users/nkalde/Dropbox/Code/cpp/gradientClient/bin/server_remote_client",portNb.." "..agent.." "..simGetObjectName(agent).." "..coef.." "..densityH.." "..exploR.." "..evalFun,1) -- set the last argument to 1 to see the console of the launched client
  if (result==-1) then
    print('Error executable')--,"'gradientClient' could not be launched. &&nSimulation will not run properly")
  end
end


  ---[[
while (simGetSimulationState()~=sim_simulation_advancing_abouttostop) do
  
  if not ended then
    -----------
    --MERGING--
    -----------
    if centralizedMerging then
        --communication
        local readMap = readMapSignal(explorers)
        serverMap = addMap(serverMap, readMap)
        writeMapSignal(serverMap, server)
      
        --drawing
        local frontiers = extractFrontiers(serverMap)
        drawExploMap(serverMap)
        drawFrontiersG(frontiers,explorers,humans)
    end  
    
    -------------
    --CHECK END--
    -------------
    local explorationEnd = 0
    for k,v in pairs(explorers) do
      explorationEnd = explorationEnd + simGetScriptSimulationParameter(simGetScriptAssociatedWithObject(v),'end')
    end
    ended = explorationEnd == #explorers
  else
    simStopSimulation()
  end
  simSwitchThread()
  simWait(1) 
end

if (simGetSimulationState()==sim_simulation_advancing_abouttostop) then
end
--]]
