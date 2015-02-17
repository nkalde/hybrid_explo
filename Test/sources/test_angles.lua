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
  
  -- INITIALIZATION
  goalHandle=simGetObjectHandle('Bill_base')
  sourceHandle=server
    
  --thread
  simSetThreadSwitchTiming(200)
  simDelegateChildScriptExecution()   
 
  print('TEST ANGLE')
  while (simGetSimulationState()~=sim_simulation_advancing_abouttostop) do
    
    --TEST Angles
    local angleT = simGetObjectOrientation(goalHandle,-1)
    local angleS = simGetObjectOrientation(sourceHandle,-1)
    
    simWait(1,true)
    
    --To degrees
    local radToDeg = 180/math.pi
    
    local degAngleT = {angleT[1] *radToDeg,angleT[2] *radToDeg,angleT[3] *radToDeg}
    local degAngleT2 = {math.deg(angleT[1]),math.deg(angleT[2]),math.deg(angleT[3])}
    
    local degAngleS = {angleS[1] *radToDeg,angleS[2] *radToDeg,angleS[3] *radToDeg}
    local degAngleS2 = {math.deg(angleS[1]),math.deg(angleS[2]),math.deg(angleS[3])}
    
    --print('degT ('..degAngleT[3]..')'..' degS ('..degAngleS[3]..')')
    --print('degT2 ('..degAngleT2[3]..')'..' degS2 ('..degAngleS2[3]..')')
    --print('d:('..degAngleT[1]..','..degAngleT[2]..','..degAngleT[3]..')')
    --print('d:('..degAngleT2[1]..','..degAngleT2[2]..','..degAngleT2[3]..')')
    --assert(degAngleT[1]==degAngleT2[1] and degAngleT[2]==degAngleT2[2] and degAngleT[3]==degAngleT2[3],"degre T false"..degAngleT[3]..';'..degAngleT2[3])
    --assert(degAngleS[1]==degAngleS2[1] and degAngleT[2]==degAngleS2[2] and degAngleS[3]==degAngleS2[3],"degre S false"..degAngleS[3]..';'..degAngleS2[3])
    
    --print('r:('..angleT[1]..','..angleT[2]..','..angleT[3]..')'..'->'..'d:('..degAngleT[1]..','..degAngleT[2]..','..degAngleT[3]..')')
    --print('r:('..angleS[1]..','..angleS[2]..','..angleS[3]..')'..'->'..'d:('..degAngleS[1]..','..degAngleS[2]..','..degAngleS[3]..')')
    --print('radT ('..angleT[3]..')'..' radS ('..angleS[3]..')')
    --print('degT ('..degAngleT[3]..')'..' degS ('..degAngleS[3]..')')
  
    
    --diff Angle
    local aAngle = degAngleS[3]
    local bAngle = degAngleT[3]
    local sourceA, targetA = aAngle, bAngle
    local a = targetA - sourceA
    a = (a + 180) % 360 - 180
    a = math.abs(a)
    --print('diff:'..a)
    --simWait(1,true)
      
    --angle of the vector from server to dummy
    local posT = simGetObjectPosition(goalHandle,-1)
    local posS = simGetObjectPosition(sourceHandle,-1)
    local vect = {posT[1]-posS[1],posT[2]-posS[2],posT[3],posS[3]}
    print('vect'..vect[1]..','..vect[2]..','..vect[3])
    local angle = math.atan2(vect[2],vect[1])
    print('v'..vect[1]..','..vect[2]..'->'..angle..'*****'..math.deg(angle))
    
  end