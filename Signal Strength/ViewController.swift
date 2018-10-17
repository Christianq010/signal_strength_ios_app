//
//  ViewController.swift
//  Signal Strength
//
//  Created by Christiaan Quyn on 10/17/18.
//  Copyright © 2018 Christiaan Quyn. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreTelephony
import Darwin

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    func getSignalStrength()->Int{
        var result : Int = 0
        //int CTGetSignalStrength();
        let libHandle = dlopen ("/System/Library/Frameworks/CoreTelephony.framework/CoreTelephony", RTLD_NOW)
        let CTGetSignalStrength2 = dlsym(libHandle, "CTGetSignalStrength")
        
        typealias CFunction = @convention(c) () -> Int
        
        if (CTGetSignalStrength2 != nil) {
            let fun = unsafeBitCast(CTGetSignalStrength2!, to: CFunction.self)
            let result = fun()
            return result;
        }
        return -1
    }
    
    func getSignalStrength2() -> Int {
        
        let application = UIApplication.shared
        let statusBarView = application.value(forKey: "statusBar") as! UIView
        let foregroundView = statusBarView.value(forKey: "foregroundView") as! UIView
        let foregroundViewSubviews = foregroundView.subviews
        
        var dataNetworkItemView:UIView!
        
        for subview in foregroundViewSubviews {
            if subview.isKind(of: NSClassFromString("UIStatusBarSignalStrengthItemView")!) {
                dataNetworkItemView = subview
                break
            } else {
                return 0 //NO SERVICE
            }
        }
        
        return dataNetworkItemView.value(forKey: "signalStrengthBars") as! Int
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
    }

    @IBAction func sendSignal(_ sender: UIButton) {
        print("signal \(getSignalStrength2())")
        let signal = getSignalStrength2()
        sender.setTitle("Signal: \(signal)", for: .normal)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        mapView.mapType = MKMapType.standard
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
}

