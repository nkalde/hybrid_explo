----------
--MATRIX--
----------
 --normalize matrix
 function normalizeMat(t)
    if #t == 0 or #t[1] == 0 then return nil end
    local iMax,jMax, max = maxMat(t)
    --print(max)
    for i,ti in ipairs(t) do
      for j,tij in ipairs(ti) do
        if tij ~= 0 then
            t[i][j] = tij/max
        end
      end
    end
    return t
  end
  
  --transpose matrix
  transpose=function(mat)
    local transposedMat = {}
    for i,v in ipairs(mat) do
      for j,v2 in ipairs(v) do
        if transposedMat[j] == nil then
          transposedMat[j] = {}
        end
        transposedMat[j][i] = v2    
      end
    end
    return transposedMat
  end
  
  --find min or max table
  function minmax(t, fn)
    if #t == 0 then return nil, nil end
    local key, value = 1, t[1]
    for i = 2, #t do
        if fn(value, t[i]) then
            key, value = i, t[i]
        end
    end
    return key, value
  end

  --find min table
  function min(t)
    if #t == 0 then return nil, nil end
    local key, value = 1, t[1]
    for i = 2, #t do
        if value > t[i] then
            key, value = i, t[i]
        end
    end
    return key, value
  end
  
  --find max table
  function max(t)
    if #t == 0 then return nil, nil end
    local key, value = 1, t[1]
    for i = 2, #t do
        if value < t[i] then
            key, value = i, t[i]
        end
    end
    return key, value
  end
  
  --find max matrix
  function maxMat(t)
    if #t == 0 or #t[1] == 0 then return nil, nil, nil end
    local key1, key2, value = 1, 1, t[1][1]
    for i,ti in ipairs(t) do
      for j,tij in ipairs(ti) do
        if value < tij and tij ~= math.huge then
            key1, key2, value = i, j, tij
        end
      end
    end
    return key1, key2, value
  end
  
  --replace a by b in matrix t
  function replaceMat(t,a,b)
    if #t == 0 or #t[1] == 0 then return nil end
    for i,ti in ipairs(t) do
      for j,tij in ipairs(ti) do
        if tij == a then
            t[i][j] = b
        end
      end
    end
    return t
  end
  
  --return keys same value val
  function eq(t,val)
    if #t == 0 then return nil end
    local keys = {}
    for k,v in ipairs(t) do
      if val == v then
        keys[#keys+1] = k
      end
    end
    return keys
  end
  
  --add matrices
  function addMat(t1,t2)
    local addM = {}
    for i,t1i in ipairs(t1) do
      addM[i] = {}
      for j,t1ij in ipairs(t1i) do
        addM[i][j] = t1ij + t2[i][j]
      end
    end
    return addM
  end
  
  --add matrices
  function mulMat(t1,t2)
    local addM = {}
    for i,t1i in ipairs(t1) do
      addM[i] = {}
      for j,t1ij in ipairs(t1i) do
        addM[i][j] = t1ij * t2[i][j]
      end
    end
    return addM
  end
  
----------
--VECTOR--
----------
--produit perpendiculaire
perpDotProduct=function(v1,v2)
  local v1x, v1y = v1[1], v1[2]
  local v2x, v2y = v2[1], v2[2]
  local perpDP = v1x*v2y - v1y*v2x
  return perpDP
end

--beware of the parameters x y Function to compute the vector dot product
dotProduct2D=function(ax, ay, bx, by)
  if type(ax)=='table' and type(ay)=='table' then
    by = ay[2]
    bx = ay[1]
    ay = ax[2]
    ax = ax[1]
  end
  return ax*ay + bx*by
end

--dot product
dotProduct=function(v1,v2)
  local sp = 0
  for i=1,2,1 do
    local c1 = v1[i]
    local c2 = v2[i]
    sp = sp + c1*c2
  end
  return sp
end

--minimum angle in radian between 
angleBetweenV=function(v1,v2)
  local sp=dotProduct(v1,v2)
  --print(v1[1]..','..v1[2],v2[1]..','..v2[2])
  local nv1, nv2 = normV(v1), normV(v2)
  if nv1 == 0 or nv2 == 0 then
    return 0
  else
    local cosT = sp/(nv1*nv2)
    local angle = math.acos(cosT)
    return angle
  end
end

--minimum angle in radian between 
signedAngleBetweenV=function(v1,v2)
  local perpDP = perpDotProduct(v1,v2)
  local dotP = dotProduct(v1,v2)
  local atan2 = math.atan2(perpDP,dotP)
  return atan2
end

--norm
normV=function(v1)
  local nV = 0
  for i,v in ipairs(v1) do
    nV = nV +v*v
  end
  nV = math.sqrt(nV)
  return nV
end

--set of n (x,y) points
--y=a + bx find a and b to express y_est = a+bx
linearRegression=function(setOfPoints)
  local meanX, meanY, nbPoints =0, 0, #setOfPoints
  local varX, covXY = 0, 0
  for i,v in ipairs(setOfPoints) do
    local x,y = v[1],v[2]
    meanX, meanY = meanX + x, meanY + y
  end
  meanX, meanY = meanX/nbPoints, meanY/nbPoints
  
  for i,v in ipairs(setOfPoints) do
    local x,y = v[1],v[2]
    varX = varX + math.pow((x-meanX),2)
    covXY = covXY + (x-meanX)*(y-meanY)
  end
  local b= covXY/varX
  local a = meanY-b*meanX
  
  return a,b,meanX,meanY,varX,covXY
end

--y=a + bx
normalVectors=function(a,b)
  --y = a +bx -> bx - y + a = 0 or -bx + y - a = 0
  --normal vectors are b,-1 or -b,1
  return {b,-1},{-b,1}
  --be careful math.atan(a/-b),math.atan(-a/b) check the value of angle
end

absoluteDiffAngle=function(sourceA,targetA)
  local a = targetA - sourceA
  a = (a + 180) % 360 - 180
  a=math.abs(a)
  --a = targetA - sourceA
  --a += (a>180) ? -360 : (a<-180) ? 360 : 0
  return a
end

--angle of the vector from a to b expressed
--the angle is measured from (1,0) counterclockwise -0/0,pi/2,pi/-pi,-pi/2,-0/0
angleFromAToB=function(a,b)
  local posT = getPoseXY(b)--simGetObjectPosition(goalHandle,-1)
  local posS = getPoseXY(a)--simGetObjectPosition(sourceHandle,-1)
  local vect = {posT[1]-posS[1],posT[2]-posS[2],posT[3],posS[3]}
  local angle = math.atan2(vect[2],vect[1])
  return angle
end