//
//  Hgt.swift
//  FogMachineSearch
//
//  Created by Chris Wasko on 11/17/15.
//  Copyright © 2015 NGA. All rights reserved.
//

import Foundation
import MapKit

class Hgt: NSObject {
    
    //var coordinate:CLLocationCoordinate2D!
    //var elevation:[[Double]]!
    var filename:String!
    
    init(filename: String) {
        self.filename = filename
    }
    
    // Height files have the extension .HGT and are signed two byte integers. The
    // bytes are in Motorola "big-endian" order with the most significant byte first
    // Data voids are assigned the value -32768 and are ignored (no special processing is done)
    // SRTM3 files contain 1201 lines and 1201 samples
    func getElevation() -> [[Double]] {
        
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "hgt")
        let url = NSURL(fileURLWithPath: path!)
        let data = NSData(contentsOfURL: url)!
        
        var elevationMatrix = [[Double]](count:Srtm3.MAX_SIZE, repeatedValue:[Double](count:Srtm3.MAX_SIZE, repeatedValue:0))
        
        let dataRange = NSRange(location: 0, length: data.length)
        var elevation = [Int16](count: data.length, repeatedValue: 0)
        data.getBytes(&elevation, range: dataRange)
        
        
        var row = 0
        var column = 0
        for (var cell = 0; cell < data.length; cell+=1) {
            elevationMatrix[row][column] = Double(elevation[cell].bigEndian)
            
            column++
            
            if column >= Srtm3.MAX_SIZE {
                column = 0
                row++
            }
            
            if row >= Srtm3.MAX_SIZE {
                break
            }
        }
        
        return elevationMatrix
    }
    
    // File names refer to the latitude and longitude of the lower left corner of
    // the tile - e.g. N37W105 has its lower left corner at 37 degrees north
    // latitude and 105 degrees west longitude
    func getCoordinate() -> CLLocationCoordinate2D {
        
        let northSouth = filename.substringWithRange(Range<String.Index>(start: filename.startIndex,end: filename.startIndex.advancedBy(1)))
        let latitudeValue = filename.substringWithRange(Range<String.Index>(start: filename.startIndex.advancedBy(1),end: filename.startIndex.advancedBy(3)))
        let westEast = filename.substringWithRange(Range<String.Index>(start: filename.startIndex.advancedBy(3),end: filename.startIndex.advancedBy(4)))
        let longitudeValue = filename.substringWithRange(Range<String.Index>(start: filename.startIndex.advancedBy(4),end: filename.endIndex))
        
        var latitude:Double = Double(latitudeValue)!
        var longitude:Double = Double(longitudeValue)!
        
        if (northSouth.uppercaseString == "S") {
            latitude = latitude * -1.0
        }
        
        if (westEast.uppercaseString == "W") {
            longitude = longitude * -1.0
        }
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    
    func getCenterLocation() -> CLLocationCoordinate2D {
        let location = getCoordinate()
        return CLLocationCoordinate2DMake(location.latitude + Srtm3.CENTER_OFFSET,
            location.longitude + Srtm3.CENTER_OFFSET)
    }

    
}