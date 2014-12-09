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
        dataSrc_.save(Place(name: "Cafe Rouge at the Strand", address: "9 Villiers St London WC2N 6NA United Kingdom"))
        dataSrc_.save(Place(name: "Theodore Bullfrog", address: "26 John Adam St London WC2N 6HL, United Kingdom"))
        dataSrc_.save(Place(name: "Lupita", address: "13 Villiers St London WC2N 6ND United Kingdom"))
        dataSrc_.save(Place(name: "The Ship and Shovell", address: "1-3 Craven Passage London WC2N 5PH United Kingdom"))
        dataSrc_.save(Place(name: "The Vaults Restaurant", address: "The RSA 8 John Adam St WC2N 6EZ, United Kingdom"))
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
                        
                        place.annotation = annotation
                        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager:CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        println("update locs...")
        
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
        println(error)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var place:Place = dataSrc_.getAtIndex(indexPath.row)
        self.mapView
            .zoomToCoordinate(place.annotation!.coordinate)
            .selectAnnotation(place.annotation, animated: true)
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

