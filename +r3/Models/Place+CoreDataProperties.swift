//
//  Place+CoreDataProperties.swift
//  +r3
//
//  Created by Mobile Dragon on 06/10/2016.
//  Copyright © 2016 Igor Gubanov. All rights reserved.
//

import Foundation
import CoreData


extension Place {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Place> {
        return NSFetchRequest<Place>(entityName: "Place");
    }

    @NSManaged public var id: String?
    @NSManaged public var insertedDate: String?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var shortInfo: String?
    @NSManaged public var longInfo: String?

}
