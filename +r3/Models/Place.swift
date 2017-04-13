//
//  Place.swift
//  +r3
//
//  Created by Xin Hua on 9/22/16.
//  Copyright © 2016 Igor Gubanov. All rights reserved.
//

import CoreLocation
import UIKit

class Place: NSObject {
    
    var id: String = ""
    var insertedDate: String = ""
    var location: CLLocation! = nil
    var shortInfo: String = ""
    var longInfo: String = ""
}
