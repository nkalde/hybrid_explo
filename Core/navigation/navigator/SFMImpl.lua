----------------------
--SOCIAL FORCE MODEL--
----------------------

	--constants
	mI=80
	--mI=1
	thoI=0.5
	lambda=0.5
	aKo=100
	bKo=0.01
	aKp=70
	bKp=0.4
	cKo=600
	cKp=250

	--drawings
	drawingPoint =  simAddDrawingObject(sim_drawing_points+sim_drawing_cyclic, 10, 0.0, -1, 1, {0,0,0}, nil, nil, nil)
	drawingFPers = simAddDrawingObject(sim_drawing_lines+sim_drawing_cyclic,3, 0.0, -1, 1, {255,0,0},nil,nil,nil)
	drawingFSoc = simAddDrawingObject(sim_drawing_lines+sim_drawing_cyclic,3, 0.0, -1, 1, {0,255,0},nil,nil,nil)
	drawingFSocIO = simAddDrawingObject(sim_drawing_lines+sim_drawing_cyclic,1, 0.0, -1, 0, {100,255,0},nil,nil,nil)
	drawingFSocIP = simAddDrawingObject(sim_drawing_lines+sim_drawing_cyclic,1, 0.0, -1, 0, {0,255,100},nil,nil,nil)
	drawingFPhys = simAddDrawingObject(sim_drawing_lines+sim_drawing_cyclic,3, 0.0, -1, 1, {0,0,255},nil,nil,nil)
	drawingFPhysIO = simAddDrawingObject(sim_drawing_lines+sim_drawing_cyclic,1, 0.0, -1, 0, {100,0,255},nil,nil,nil)
	drawingFPhysIP = simAddDrawingObject(sim_drawing_lines+sim_drawing_cyclic,1, 0.0, -1, 0, {0,100,255},nil,nil,nil)
	drawingF = simAddDrawingObject(sim_drawing_lines+sim_drawing_cyclic,3, 0.0, -1, 1, {0,0,0},nil,nil,nil)	
	drawFPers = false
	drawFSoc = false
	drawFSocI = false
	drawFPhys = false
	drawFPhysI = false
	drawF = false

  ------------------
  --PERSONAL FORCE--
  ------------------
  
	-- mI mass,
	-- eI intendedDirection
	-- viI intendedVelocity
	-- vI velocity
	-- thoI relaxationTime
	FPersI=function(mI, eIx, eIy, viI, vIx, vIy, thoI)
		local fPersIx = mI * ((viI * eIx) - vIx)/ thoI
		local fPersIy = mI * ((viI * eIy) - vIy)/ thoI
		
		--[[
		--new modification maximum force
		local d = distanceEuclid({0,0},{fPersIx,fPersIy})
		local test = math.min(d,100)
		if (test == 100) then
			fPersIx = fPersIx/d*test
			fPersIy = fPersIy/d*test
		end
    --]]
		--printing
		if (drawFPers) then
			t = simGetObjectPosition(agent, -1)
			simAddDrawingObjectItem(drawingFPers, {t[1];t[2];2;t[1]+fPersIx;t[2]+fPersIy;2})
			print('\n'..'FPers:'..'('..fPersIx..','..fPersIy..')')
			--print('\nFPersI'..' m:'..mI..' eI:'..'('..eIx..','..eIy..')'..' viI:'..viI..' vI:'..'('..vIx..','..vIy..')'..' thoI:'..thoI..' FPers:'..'('..fPersIx..','..fPersIy..')')
		end
		
		return fPersIx, fPersIy
	end

  ----------------
  --SOCIAL FORCE--
  ----------------
  
	FSocI=function(objectTable, akp, bkp, ako, bko, lambda, eIx, eIy)
    if (drawFSocI) then
    	simRemoveDrawingObject(drawingFSocIO)
    	drawingFSocIO = simAddDrawingObject(sim_drawing_lines+sim_drawing_cyclic,1, 0.0, -1, #items, {100,255,0},nil,nil,nil)
    	simRemoveDrawingObject(drawingFSocIP)
    	drawingFSocIP = simAddDrawingObject(sim_drawing_lines+sim_drawing_cyclic,1, 0.0, -1, #humans, {0,255,100},nil,nil,nil)
    end

    local fSocijx = 0
    local fSocijy = 0
    local fSociox = 0
    local fSocioy = 0
    local objectI = agent
    for i=1,#humans do
      local objectK = humans[i]
      if objectK ~= objectI then
        local a, b = fSocIK(objectI, objectK, akp, bkp, lambda, eIx, eIy)
        fSocijx = fSocijx + a
        fSocijy = fSocijy + b
        if (drawFSocI) then
          t = simGetObjectPosition(objectI, -1)
          simAddDrawingObjectItem(drawingFSocIP, {t[1];t[2];2;t[1]+a;t[2]+b;2})
        end
      end
    end
    for i=1,#items do
      local objectK = items[i]
      if objectK ~= objectI then
        local a, b = fSocIK(objectI, objectK, ako, bko, nil, eIx, eIy)
        fSociox = fSociox + a
        fSocioy = fSocioy + b
        if (drawFSocI) then
          t = simGetObjectPosition(objectI, -1)
          simAddDrawingObjectItem(drawingFSocIO, {t[1];t[2];2;t[1]+a;t[2]+b;2})
        end
      end
    end
		fSocIx = fSocijx+fSociox
		fSocIy = fSocijy+fSocioy
		if (drawFSoc) then
			t = simGetObjectPosition(objectI, -1)
			simAddDrawingObjectItem(drawingFSoc, {t[1];t[2];2;t[1]+fSocIx;t[2]+fSocIy;2})
			print('\n'..'FSocI'..'('..fSocIx..','..fSocIy..')')
		end
		norm = math.sqrt(math.pow(fSocIx,2)+math.pow(fSocIy,2))
		return fSocIx, fSocIy, norm
	end

	--Function to compute the individual interaction force:
	--aK magnitude, 
	--bK range of the force, 
	--dIK distance between the centers of pI and entity k,
	--rIK is rI summed up with rK
	--nIK normalized vector from k to pI
	fSocIK=function(objectI, objectK, aK, bK, lambda, eIx, eIy)
		local name1 = simGetObjectName(objectI)
		local name2 = simGetObjectName(objectK)
		local rIK=boundingBoxDiameter(objectI)/2 + boundingBoxDiameter(objectK)/2
		local dIK=distanceObjectMin(objectI, objectK)
		local nIKx, nIKy =normalizedVector(objectI, objectK)
		local fSocIKx = aK * math.exp((rIK - dIK)/bK) * nIKx
		local fSocIKy = aK * math.exp((rIK - dIK)/bK) * nIKy
		if (objectI ~= objectK and simGetObjectType(objectI) == simGetObjectType(objectK) and lamda ~= nil) then
			local scalingIsotropic = ( lambda + (1 - lambda)*(1+cosPhiIK(nIKx, nIKy, eIx, eIy))/2 )
			fSocIKx = fSocIKx * scalingIsotropic
			fSocIKy = fSocIKy * scalingIsotropic
		else
			lambda = 0
		end

		--[[
		--new modification maximum force
		local d = distanceEuclid({0,0},{fSocIKx,fSocIKy})
		local test = -1
		if bK == bKo then
			test = math.min(d,125)
		else
			test = math.min(d,100)
		end
		if (test == 125 and bK == bKo) or (test == 100 and bK == bKp) then
			fSocIKx = fSocIKx/d*test
			fSocIKy = fSocIKy/d*test
		end
		--]]

		--printing
		if drawFSocI and dIK < 1 then
			print('\nFSocIK'..' n1:'..name1..' n2:'..name2..' ak:'..aK..' bk:'..bK..' lambda:'..lambda..' eI:'..'('..eIx..','..eIy..')'..' FSocIK:'..'('..fSocIKx..','..fSocIKy..')'..'\n')
		end
		return fSocIKx, fSocIKy
	end

  ------------------
  --PHYSICAL FORCE--
  ------------------
  
	FPhysI=function(objectTable, cKo, cKp)
		if (drawFPhysI) then
			simRemoveDrawingObject(drawingFPhysIO)
			drawingFPhysIO = simAddDrawingObject(sim_drawing_lines+sim_drawing_cyclic,1, 0.0, -1, #items, {100,0,255},nil,nil,nil)
			simRemoveDrawingObject(drawingFPhysIP)
			drawingFPhysIP = simAddDrawingObject(sim_drawing_lines+sim_drawing_cyclic,1, 0.0, -1, #humans, {0,100,255},nil,nil,nil)
		end
		local fPhysijx = 0
		local fPhysijy = 0
		local fPhysiox = 0
		local fPhysioy = 0
		for i=1, #humans do
			local objectK = humans[i]
			if objectK ~= objectI then
  			local a, b = fPhysIK(agent, objectK, cKp)
  			fPhysijx = fPhysijx + a
  			fPhysijy = fPhysijy + b
  			if (drawFPhysI) then
  				t = simGetObjectPosition(agent, -1)
  				simAddDrawingObjectItem(drawingFPhysIP, {t[1];t[2];2;t[1]+a;t[2]+b;2})
  			end
      end
		end
		for i=1, #items do
			local objectK = items[i]
			if objectK ~= objectI then
  			local a, b = fPhysIK(agent, objectK, cKo)
  			fPhysiox = fPhysiox + a
  			fPhysioy = fPhysioy + b
  			if (drawFPhysI) then
  				t = simGetObjectPosition(agent, -1)
  				simAddDrawingObjectItem(drawingFPhysIO, {t[1];t[2];2;t[1]+a;t[2]+b;2})
  			end
      end
		end
		fPhysIx = fPhysijx+fPhysiox
		fPhysIy = fPhysijy+fPhysioy

		--printing
		if (drawFPhys) then
			t = simGetObjectPosition(agent, -1)
			simAddDrawingObjectItem(drawingFPhys, {t[1];t[2];2;t[1]+fPhysIx;t[2]+fPhysIy;2})
			print('\n'..'FPhysI'..'('..fPhysIx..','..fPhysIy..')')
		end
		return fPhysIx, fPhysIy
	end

	--Function to compute the individual interaction force:
	--aK magnitude, 
	--bK range of the force, 
	--dIK distance between the centers of pI and entity k,
	--rIK is rI summed up with rK
	--nIK normalized vector from k to pI
	fPhysIK=function(objectI, objectK, cK)--, rIK, dIK, nIK	
		local rIK=boundingBoxDiameter(objectI)/2 + boundingBoxDiameter(objectK)/2
		local dIK=distanceObjectMin(objectI, objectK)
		local nIKx, nIKy =normalizedVector(objectI, objectK)
		local fPhysIKx = cK * g(rIK - dIK) * nIKx
		local fPhysIKy = cK * g(rIK - dIK) * nIKy
		
		--[[
		--new modification maximum force
		local d = distanceEuclid({0,0},{fPhysIKx,fPhysIKy})
		local test = -1
		if cK == cKo then
			test = math.min(d,125)
		else
			test = math.min(d,100)
		end
		if (test == 125 and cK == cKo) or (test == 100 and cK == cKp) then
			fPhysIKx = fPhysIKx/d*test
			fPhysIKy = fPhysIKy/d*test
		end
		--]]

		--printing
		if drawFPhysI and dIK < 0.4 then
			print('\nFPhysIK'..'_'..' n1:'..simGetObjectName(objectI)..' n2:'..simGetObjectName(objectK)..' cK:'..cK..' FPhysIK:'..'('..fPhysIKx..','..fPhysIKy..')'..'\n')
			--print('rIK:'..rIK..'-'..'dIK:'..dIK..'-'..'nIK:'..'('..nIKx..','..nIKx..')'..'-'..'fPhysIK:'..'('..fPhysIKx..','..fPhysIKy..')')
		end
		return fPhysIKx, fPhysIKy
	end
  
  -------------------
  --COMBINED FORCES--
  -------------------
	FI=function(objectTable, mI, eIx, eIy, viI, vIx, vIy, thoI, akp, bkp, ako, bko, lambda, cKo, cKp)
		local fipersx, fipersy = FPersI(mI, eIx, eIy, viI, vIx, vIy, thoI)
		local fisocx, fisocy = FSocI(objectTable, akp, bkp, ako, bko, lambda, eIx, eIy)
		local fiphysx, fiphysy = FPhysI(objectTable, cKo, cKp)
		local fIx = fipersx+fiphysx+fisocx
		local fIy = fipersy+fiphysy+fisocy

		--printing
		if (drawF) then
			t = simGetObjectPosition(agent, -1)
			simAddDrawingObjectItem(drawingF, {t[1];t[2];2;t[1]+fIx;t[2]+fIy;2})
			print('\n'..'FI'..'('..fIx..','..fIy..')')
		end
		return fIx, fIy
	end
  
  --------------
  --NAVIGATION--
  --------------
  
	SFMNew=function(coordinates, object)    
    --intended direction
    local xt = simGetObjectPosition(object,-1)
    local gt = coordinates--simGetObjectPosition(goalHandle,-1) 
    angularTo(gt,object)
    local normGX = distanceEuclid(gt,xt)
    local e_t = {0,0}
    if (normGX > 0) then
      e_t[1] = (gt[1] - xt[1]) / normGX
      e_t[2] = (gt[2] - xt[2]) / normGX
    else
      e_t[1] = 0
      e_t[2] = 0
    end
    
    --intended velocity
    local dt = simGetSimulationTimeStep()
    local t = simGetSimulationTime()+dt
    local k = 2
    local dg = k*dt
    local tg = t + dg
    local v_t = normGX / (tg - t)    
    v_t = nominalVelocity
    local vt = simGetObjectVelocity(object)
    simAddDrawingObjectItem(drawingPoint, {xt[1]+e_t[1],xt[2]+e_t[2], 2})
    
    --compute FI
    local fIx, fIy = FI(modelObjects, mI, e_t[1], e_t[2], v_t, vt[1], vt[2], thoI, aKp, bKp, aKo, bKo, lambda, cKo, cKp)

    --update position and velocity
    local vt1 = vt
    vt1[1] = vt[1]+(fIx/mI)*dt
    vt1[2] = vt[2]+(fIy/mI)*dt
    xt[1] = xt[1]+dt*vt1[1]+((fIx/mI)/2)*math.pow(dt,2)
    xt[2] = xt[2]+dt*vt1[2]+((fIy/mI)/2)*math.pow(dt,2)
    simSetObjectPosition(object,-1,xt)
  end
