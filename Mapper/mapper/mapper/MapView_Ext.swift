//
//  MapView_Ext.swift
//  ml_lab4
//
//  Created by ML on 12/9/14.
//  Copyright (c) 2014 ML. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

extension MKMapView {
    
    func addAnnotation(annotation:MKPointAnnotation!, select:Bool) -> MKMapView! {
        self.addAnnotation(annotation)
        if (select) {
            self.selectAnnotation(annotation, animated: true)
        }
        return self
    }
    
    func zoomToCoordinate(
        coordinate: CLLocationCoordinate2D,
        latitudinalMeters: CLLocationDistance = 500,
        longitudinalMeters: CLLocationDistance = 500) -> MKMapView! {
        var region : MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(
            coordinate,
            latitudinalMeters,
            longitudinalMeters)
        self.setRegion(region, animated: true)
        return self
    }
}

