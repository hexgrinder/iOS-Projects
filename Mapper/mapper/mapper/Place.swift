//
//  Restaurant.swift
//  ml_lab4
//
//  Created by ML on 12/9/14.
//  Copyright (c) 2014 ML. All rights reserved.
//

import MapKit

class Place {
    
    init(name:NSString, address:NSString, annotation:MKAnnotation? = nil) {
        self.name = name
        self.address = address
        self.annotation = annotation
    }
    var name:NSString
    var address:NSString
    var annotation:MKAnnotation?
}