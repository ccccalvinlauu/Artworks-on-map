//
//  CoreArtworksDetails+CoreDataProperties.swift
//  COMP327.Assignment.2.u6tcl
//
//  Created by lau tszchung on 5/12/2018.
//  Copyright © 2018 lau tszchung. All rights reserved.
//
//

import Foundation
import CoreData


extension CoreArtworksDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreArtworksDetails> {
        return NSFetchRequest<CoreArtworksDetails>(entityName: "CoreArtworksDetails")
    }

    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var artist: String?
    @NSManaged public var yearOfWork: String?
    @NSManaged public var lat: String?
    @NSManaged public var information: String?
    @NSManaged public var long: String?
    @NSManaged public var location: String?
    @NSManaged public var locationNotes: String?
    @NSManaged public var fileName: String?
    @NSManaged public var lastModified: String?
    @NSManaged public var enabled: String?

}
