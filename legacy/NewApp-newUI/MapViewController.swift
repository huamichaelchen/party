//
//  ViewController.swift
//  NewApp-newUI
//
//  Created by Hua Chen on 2015-03-12.
//  Copyright (c) 2015 Hua Chen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,
ENSideMenuDelegate {

    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!
    @IBOutlet weak var edgeView: UIView!
    
    var locationManager: CLLocationManager!
    var manager: OneShotLocationManager?
    var currentLocation: CLLocationCoordinate2D?
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    // MARK: ViewController Lifecycle

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        manager = OneShotLocationManager()
        manager?.fetchWithCompletion {
            location, error in
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: location!.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
        }
        
        let annotation1 = MKPointAnnotation()
        annotation1.coordinate.latitude = 45.091565
        annotation1.coordinate.longitude = -64.362743
        annotation1.title = "JustUs Cafe"
        annotation1.subtitle = "Cafe"
        mapView.addAnnotation(annotation1)
        

        let annotation2 = MKPointAnnotation()
        annotation2.coordinate.latitude = 45.0885655
        annotation2.coordinate.longitude = -64.3649429
        annotation2.title = "Acadia University"
        annotation2.subtitle = "Universities"
        mapView.addAnnotation(annotation2)
        
        let annotation3 = MKPointAnnotation()
        annotation3.coordinate.latitude = 45.092747
        annotation3.coordinate.longitude = -64.365254
        annotation3.title = "Farmer's Market"
        annotation3.subtitle = "Shopping"
        mapView.addAnnotation(annotation3)

        let annotation4 = MKPointAnnotation()
        annotation4.coordinate.latitude = 45.0914651
        annotation4.coordinate.longitude = -64.3630392
        annotation4.title = "Paddy's Pub"
        annotation4.subtitle = "Restaurant"
        mapView.addAnnotation(annotation4)
        
        let annotation5 = MKPointAnnotation()
        annotation5.coordinate.latitude = 45.0915258
        annotation5.coordinate.longitude = -64.3618742
        annotation5.title = "Privet House"
        annotation5.subtitle = "Restaurant"
        mapView.addAnnotation(annotation5)
        
        let annotation6 = MKPointAnnotation()
        annotation6.coordinate.latitude = 45.0916488
        annotation6.coordinate.longitude = -64.3602121
        annotation6.title = "Tan Coffee"
        annotation6.subtitle = "Cafe"
        mapView.addAnnotation(annotation6)
        
    }
    
    // MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("mapview")
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "mapview")
            view!.canShowCallout = true
        } else {
            view!.annotation = annotation
        }
        
        view!.leftCalloutAccessoryView = nil
        view!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
        
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegueWithIdentifier("mapCallout", sender: view)
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    // MARK: Side Menu Animation
    func slideout(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .Ended {
            toggleSideMenuView()
        }
    }
    
    func setupSideMenu() {
        self.sideMenuController()?.sideMenu?.delegate = self
        screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "slideout:")
        screenEdgeRecognizer.edges = .Right
        view.addGestureRecognizer(screenEdgeRecognizer)
    }
    
}

