module SvgArcSegment ( 
                       convertSvgArc
                     ) where

import Types                     
                     
radiansPerDegree = pi / 180.0;

iif True t f = t 
iif False t f = f

calculateVectorAngle :: Double -> Double -> Double -> Double -> Double
calculateVectorAngle ux uy vx vy
    | tb >= ta
        = tb - ta
    | otherwise
        = pi * 2 - (ta - tb)
    where
        ta = atan2 uy ux
        tb = atan2 vy vx
        
-- ported from: https://github.com/vvvv/SVG/blob/master/Source/Paths/SvgArcSegment.cs
convertSvgArc :: Point -> Double -> Double -> Double -> Bool -> Bool -> Point -> [DrawOp]
convertSvgArc (x0,y0) radiusX radiusY angle largeArcFlag sweepFlag (x,y)
    | x0 == x && y0 == y0
        = []
    | radiusX == 0.0 && radiusY == 0.0
        = [DLineTo (x,y)]
    | otherwise 
        = calcSegments x0 y0 theta1 segments
    where
        sinPhi = sin (angle * radiansPerDegree)
        cosPhi = cos (angle * radiansPerDegree)

        x1dash = cosPhi * (x0 - x) / 2.0 + sinPhi * (y0 - y) / 2.0
        y1dash = -sinPhi * (x0 - x) / 2.0 + cosPhi * (y0 - y) / 2.0

        numerator = radiusX * radiusX * radiusY * radiusY - radiusX * radiusX * y1dash * y1dash - radiusY * radiusY * x1dash * x1dash

        s = sqrt(1.0 - numerator / (radiusX * radiusX * radiusY * radiusY))
        rx   = iif (numerator < 0.0) (radiusX * s) radiusX
        ry   = iif (numerator < 0.0) (radiusY * s) radiusY
        root = iif (numerator < 0.0) 
                   (0.0) 
                   ((iif ((largeArcFlag && sweepFlag) || (not largeArcFlag && not sweepFlag)) (-1.0) 1.0) * 
                        sqrt(numerator / (radiusX * radiusX * y1dash * y1dash + radiusY * radiusY * x1dash * x1dash)))
  
        cxdash = root * rx * y1dash / ry
        cydash = -root * ry * x1dash / rx

        cx = cosPhi * cxdash - sinPhi * cydash + (x0 + x) / 2.0
        cy = sinPhi * cxdash + cosPhi * cydash + (y0 + y) / 2.0
        
        theta1  = calculateVectorAngle 1.0 0.0 ((x1dash - cxdash) / rx) ((y1dash - cydash) / ry)
        dtheta' = calculateVectorAngle ((x1dash - cxdash) / rx) ((y1dash - cydash) / ry) ((-x1dash - cxdash) / rx) ((-y1dash - cydash) / ry)
        dtheta  = iif (not sweepFlag && dtheta' > 0) 
                      (dtheta' - 2 * pi)
                      (iif (sweepFlag && dtheta' < 0) (dtheta' + 2 * pi) dtheta')
  
        segments = ceiling (abs (dtheta / (pi / 2.0)))
        delta = dtheta / fromInteger segments
        t = 8.0 / 3.0 * sin(delta / 4.0) * sin(delta / 4.0) / sin(delta / 2.0)
  
        calcSegments startX startY theta1 segments 
            | segments == 0
                = []
            | otherwise
                = (DBezierTo (startX + dx1, startY + dy1) (endpointX + dxe, endpointY + dye) (endpointX, endpointY) : calcSegments endpointX endpointY theta2 (segments - 1))
            where
                cosTheta1 = cos theta1
                sinTheta1 = sin theta1
                theta2 = theta1 + delta
                cosTheta2 = cos theta2
                sinTheta2 = sin theta2

                endpointX = cosPhi * rx * cosTheta2 - sinPhi * ry * sinTheta2 + cx
                endpointY = sinPhi * rx * cosTheta2 + cosPhi * ry * sinTheta2 + cy

                dx1 = t * (-cosPhi * rx * sinTheta1 - sinPhi * ry * cosTheta1)
                dy1 = t * (-sinPhi * rx * sinTheta1 + cosPhi * ry * cosTheta1)

                dxe = t * (cosPhi * rx * sinTheta2 + sinPhi * ry * cosTheta2)
                dye = t * (sinPhi * rx * sinTheta2 - cosPhi * ry * cosTheta2)

{-                
-- ported from: http://www.java2s.com/Code/Java/2D-Graphics-GUI/AgeometricpathconstructedfromstraightlinesquadraticandcubicBeziercurvesandellipticalarc.htm   
-- works without angle and with circle segments only             
convertArc :: Double -> Double -> Double -> Bool -> Bool -> Double -> Double -> Arc
convertArc x0 y0 radius largeArcFlag sweepFlag x y = Arc (x0,y0) (x,y) (cx,cy) dir
    where
        x1 = (x0 - x) / 2.0
        y1 = (y0 - y) / 2.0
                
        pr' = radius * radius
        px1 = x1 * x1
        py1 = y1 * y1

        radiiCheck = px1 / pr' + py1 / pr'
        
        r = iif (radiiCheck > 1) (sqrt radiiCheck * abs radius) (abs radius)
        pr = r * r
        
        sign = iif (largeArcFlag == sweepFlag) (-1) 1
        sq' = ((pr * pr) - (pr * py1) - (pr * px1)) / ((pr * py1) + (pr * px1))
        coef = sign * sqrt (max 0.0 sq')
        cx1 = coef * y1
        cy1 = coef * (-x1)
        
        sx2 = (x0 + x) / 2.0
        sy2 = (y0 + y) / 2.0            
        cx = sx2 + cx1
        cy = sy2 + cy1
        
        ux = (x1 - cx1) / r
        uy = (y1 - cy1) / r
        vx = (-x1 - cx1) / r
        vy = (-y1 - cy1) / r
        
        -- compute direction. True -> Clockwise
        dir' = ux * vy - uy * vx >= 0
        dir = iif (not sweepFlag && dir') 
                  False 
                  (iif (sweepFlag && not dir') True dir')
-}  
  