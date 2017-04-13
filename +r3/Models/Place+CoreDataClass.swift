//
//  Place+CoreDataClass.swift
//  +r3
//
//  Created by Mobile Dragon on 06/10/2016.
//  Copyright © 2016 Igor Gubanov. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

public class Place: NSManagedObject {
    
    var location: CLLocation? {
        get {
            return CLLocation(latitude: CLLocationDegrees(latitude!)!, longitude: CLLocationDegrees(longitude!)!)
        }
    }
    
}
