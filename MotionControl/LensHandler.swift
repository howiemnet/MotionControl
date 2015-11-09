//
//
//      LensHandler class
//
//      (C)2015 Howard Matthews
//
//          Provides lens-specific (focus-related) functions
//
//

import Foundation

class LensHandler {
    
    //
    // Lens: 18-55mm cheapo
    //   let lookupArrayDistances =  [240.0, 255.0,  275.0,  300.0,  338.0,  380.0,  452.0,  545.0,  705.0,  1030.0, 1950.0]
    //   let lookupArraySteps =      [0,     100,    200,    300,    400,    500,    600,    700,    800,    900,    1000]
   
    // Lens: 17-55mm f2.8 with 12mm macro tube
 /*   let lookupArrayDistances =  [193.0,198.0,   203.0,    209.0,    216.0,    224.0,    232.0,    241.0,    250.0,    261.0,    273.0,    285.0,    298.0,    314.0,    330.0,    347.0]
    let lookupArraySteps =      [0,     100,    200,    300,    400,    500,    600,    700,    800,    900,    1000,   1100,   1200,   1300,   1400,   1491]
   */
    
    // lens: 17-55mm no macro tube!
    let lookupArrayDistances = [172.0,179.0,185.0,192.0,201.0,208.0,217.0,225.0,
                                239.0,259.0,261.0,276.0,286.0,307,318,337.0,
                                357,378,397,418,446,476,502,539,
                                579,613,650,703,758,795,867,944,
                                1029,1129,1240,1400,1570,1780,2075,2500,
                                3040,3600]
    
    let lookupArraySteps =     [0,  30, 60, 90, 120,150,180,210,
                                240,270,300,330,360,390,420,450,
                                480,510,540,570,600,630,660,690,
                                720,750,780,810,840,860,890,920,
                                950,980,1010,1040,1070,1100,1130,1160,
                                1190,1220]
    
    
    
    // *****************************************************************************
    //
    //  Function:   getLensStepsFromDistance(focusDistance: Double) -> Int
    //
    //              Interpolates (crudely, linearly) a lens steps value
    //              from a focus distance, based on an array of measured
    //              samples.
    //
    // *****************************************************************************
    
    
    func getLensStepsFromDistance(focusDistance: Double) -> Int {
        
        //
        //      Check requested distance is
        //      within our lens's range of
        //      sampled distances
        //
        
        if focusDistance <= lookupArrayDistances[0] {
            
            //
            //      too close, so return nearest
            //      steps value
            //
            
            return lookupArraySteps[0]
        }
        
        if focusDistance >= lookupArrayDistances[lookupArrayDistances.count-1] {
            
            //
            //      too far, so return furthest
            //      steps value
            //
            
            return lookupArraySteps[lookupArraySteps.count-1]
        }
        
        //
        //      find the nearest sample above our
        //      focus distance
        //
        
        var nearestArrayEntryAbove = 0
        
        for (index, entry) in lookupArrayDistances.enumerate() {
            if focusDistance < entry {
                nearestArrayEntryAbove = index
                break
            }
        }
        
        //
        //      Now do linear interpolation between step values
        //
        
        let distanceDelta = lookupArrayDistances[nearestArrayEntryAbove] - lookupArrayDistances[nearestArrayEntryAbove - 1]
        let myDistanceDelta = focusDistance - lookupArrayDistances[nearestArrayEntryAbove - 1]
        
        let myDistanceProportion = myDistanceDelta / distanceDelta
        
        //
        
        let stepsDelta = Double(lookupArraySteps[nearestArrayEntryAbove] - lookupArraySteps[nearestArrayEntryAbove - 1])
        let myInterpolatedSteps = lookupArraySteps[nearestArrayEntryAbove-1] + Int(myDistanceProportion * stepsDelta)
        
        //
        
        return  myInterpolatedSteps
    }
    
    
}

