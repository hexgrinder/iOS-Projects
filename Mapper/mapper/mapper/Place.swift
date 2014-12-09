//
//  Restaurant.swift
//  ml_lab4
//
//  Created by ML on 12/9/14.
//  Copyright (c) 2014 ML. All rights reserved.
//

import MapKit

class Place {
    
    private var annotation_:MKAnnotation? = nil
    
    init(name:NSString, address:NSString, placemark:CLPlacemark? = nil) {
        self.name = name
        self.address = address
        self.placemark = placemark
    }
    
    var name:NSString
    var address:NSString
    var placemark:CLPlacemark?
    var annotation : MKAnnotation? {
        get {
            if (annotation_ == nil) {
                var anno : MKPointAnnotation = MKPointAnnotation()
                anno.title = self.name
                anno.subtitle = self.address
                anno.coordinate = (self.placemark?.location)!.coordinate
                self.annotation_ = anno
            }
            return self.annotation_
        }
    }
}