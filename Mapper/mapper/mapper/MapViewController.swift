//
//  ViewController.swift
//  ml_lab4
//
//  Created by ML on 12/9/14.
//  Copyright (c) 2014 ML. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController:
UIViewController,
MKMapViewDelegate,
CLLocationManagerDelegate,
UITableViewDelegate,
UITableViewDataSource
{

    @IBOutlet var mapView:MKMapView!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var directionsText:UITextView!
    
    private var locMgr_:CLLocationManager!
    private var currentPlacemark:CLPlacemark!
    private var dataSrc_:DataSource<Place>!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // handlers
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
        initLocMgr_()
        initMapView_()
        initDataSource_()
        
        mapCoord_()
    }
    
    private func mapCoord_() {
        let len:Int = dataSrc_.count
        for (var i = 0; i < len; i++) {
            geocode_(dataSrc_.getAtIndex(i))
        }
    }
    
    private func initDataSource_() {
        
        dataSrc_ = DataSource<Place>()
        
        dataSrc_.save(Place(
            name: "The Vaults Restaurant",
            address: "1340 Scott Street San Francisco, CA"))
        dataSrc_.save(Place(
            name: "The Safe Restaurant",
            address: "1000 Scott Street San Francisco, CA"))
        dataSrc_.save(Place(
            name: "The Lockbox Restaurant",
            address: "1200 Scott Street San Francisco, CA"))
    }
    
    private func geocode_(place:Place) {
        
        CLGeocoder()
            .geocodeAddressString(
                place.address,
                completionHandler: {
                    (placemarks: [AnyObject]!, error: NSError!) -> Void in
                    
                    if error != nil {
                        println("Geocode failed with error: \(error.description)")
                        return
                    }
                    
                    if (placemarks != nil && placemarks.count > 0) {
                        
                        let coord = (placemarks[0] as CLPlacemark).location.coordinate
                        
                        let annotation = self.createMKPointAnnotation(
                            place.name,
                            subTitle: place.address,
                            coordinate: coord)
                        
                        place.placemark = (placemarks[0] as CLPlacemark)
                        
                        self.mapView
                            .addAnnotation(annotation, select:false)
                    }
            })

    }

    private func createMKPointAnnotation(
        title:NSString,
        subTitle:NSString,
        coordinate: CLLocationCoordinate2D) -> MKPointAnnotation {
        
        var annotation : MKPointAnnotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subTitle
        annotation.coordinate = coordinate
        return annotation
    }
    
    private func initLocMgr_() {
        
        locMgr_ = CLLocationManager()
        var status = CLLocationManager.authorizationStatus()
        
        switch (status) {
        case .Authorized:
            break
        case .AuthorizedWhenInUse:
            break
        case .NotDetermined:
            break
        default:
            return
        }
        
        locMgr_.delegate = self
        locMgr_.requestAlwaysAuthorization()
    }
    
    private func initMapView_() {
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
    }
    
    private func showRoute_(origin: MKMapItem!, destination: MKMapItem!) {
        
        var directionRequest : MKDirectionsRequest = MKDirectionsRequest()
        directionRequest.setSource(origin)
        directionRequest.setDestination(destination)
        
        // TODO: the following is $$$ and very chatty -> cache results
        // TODO: asynch UI updates
        var direction : MKDirections = MKDirections(request: directionRequest)
        
        direction.calculateDirectionsWithCompletionHandler({
            
            (response:MKDirectionsResponse!, routeError:NSError!) -> Void in
            
            if (routeError != nil) {
                println("[ERROR]: \(routeError)")
                return
            } else if (response.routes.isEmpty) {
                return
            } else {
                
                // clear previous route directions & overlays
                self.directionsText.text.removeAll(keepCapacity: true)
                if (self.mapView.overlays != nil) {
                    self.mapView.removeOverlays(self.mapView.overlays)
                }
                
                // a long journey begins with a single step...
                let route: MKRoute = response.routes[0] as MKRoute
                
                // new directions... the band
                for step in route.steps {
                    self.directionsText.text = NSString(
                        format: "%@ %@ \r\n\r\n",
                        self.directionsText.text,
                        step.instructions)
                }
                
                // new map route
                self.mapView.addOverlay(route.polyline!)
                
                // adjust view
                var rect : MKMapRect = route.polyline.boundingMapRect as MKMapRect
                let spanX = 0.08
                let spanY = 0.08
                var newRegion = MKCoordinateRegion(
                    center: self.mapView.userLocation.coordinate,
                    span: MKCoordinateSpanMake(spanX, spanY))
                self.mapView.setRegion(newRegion, animated: true)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let route: MKPolyline = overlay as MKPolyline
        let routeRenderer = MKPolylineRenderer(polyline:route)
        routeRenderer.lineWidth = 3.0
        routeRenderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
        return routeRenderer
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager:CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        //println("update locs...")
        
        CLGeocoder().reverseGeocodeLocation(
            manager.location,
            completionHandler: {
                (placemarks, error) -> Void in
                if (error != nil) {
                    println(error.localizedDescription)
                }
            })
    }
    
    func locationManager(manager:CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == .Authorized
            || status == .AuthorizedWhenInUse) {
            locMgr_.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locMgr_.startUpdatingLocation()
        }
    }
    
    func locationManager(manager:CLLocationManager!, didFailWithError error:NSError!) {
        println("[ERROR]: \(error)")
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var place:Place = dataSrc_.getAtIndex(indexPath.row)
        
        self.showRoute_(
            MKMapItem.mapItemForCurrentLocation(),
            destination: MKMapItem(
                placemark: MKPlacemark(placemark: place.placemark)))
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSrc_.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:MyTableViewCell = tableView
            .dequeueReusableCellWithIdentifier(
                "tableCell",
                forIndexPath: indexPath) as MyTableViewCell
        
        var place:Place = dataSrc_.getAtIndex(indexPath.row)
        
        cell.title.text = place.name
        cell.detail.text = place.address
        return cell
        
    }
}

