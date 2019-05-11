//
//  SavedArtwork+CoreDataProperties.swift
//  COMP327.Assignment.2.u6tcl
//
//  Created by lau tszchung on 2/12/2018.
//  Copyright © 2018 lau tszchung. All rights reserved.
//
//

import Foundation
import CoreData


extension SavedArtwork {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedArtwork> {
        return NSFetchRequest<SavedArtwork>(entityName: "SavedArtwork")
    }

    @NSManaged public var title: String?
    @NSManaged public var image: NSData?

}
