//
//  MapVC.swift
//  Fantastey
//
//  Created by Zoe on 20/11/20.
//  Copyright © 2020 Yuze Ling & Qixin He. All rights reserved.
//reference https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
    func dropPinsZoomIn(placemarks: [MKPlacemark])
}

class MapVC: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    //for search bar
    var resultSearchController:UISearchController? = nil
    
    //for geofence
    var geofence:CLCircularRegion?
    var locationManager: CLLocationManager = CLLocationManager()
    
    //for dropping the pin marks
    var selectedPin:MKPlacemark? = nil
    var woolworthsPin:[MKPlacemark]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        
        locationManager.delegate = self
        //locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
        
        //mapView.selectAnnotation(annotation, animated: true)
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        let zoomRegion = MKCoordinateRegion(center:locValue, latitudinalMeters: 800,longitudinalMeters:800)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
        
        //for the search bar
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTableVC
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        //searchBar.sizeToFit()
        //searchBar.placeholder = "supermarket name"
        searchBar.text = "supermarket"
        //searchBar.isUserInteractionEnabled = true
       
        
        locationSearchTable.mapView = mapView
        locationSearchTable.updateSearchResults(for: resultSearchController!)
        
        //navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        //locationSearchTable.mapView = mapView
        //for dropping the pin mark
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.definesPresentationContext = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //UIApplication.endBackgroundTask(_:)
        self.definesPresentationContext = false
    }
    
    //    func focusOn(coordinate:CLLocationCoordinate2D)
    //    {
    //        //mapView.selectAnnotation(annotation, animated: true)
    //
    //        let zoomRegion = MKCoordinateRegion(center:coordinate, latitudinalMeters: 1000,longitudinalMeters:1000)
    //        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    //    }
    
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //for creating the button on the pin mark
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}
//https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/
extension MapVC : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.first != nil else{return}
        print("location: \(locations.first!.coordinate)")
    }
    //https://stackoverflow.com/questions/40345170/delegate-must-respond-to-locationmanagerdidupdatelocations-swift-eroor
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
}

extension MapVC: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
           let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        //https://stackoverflow.com/questions/59127876/mkcoordinatespanmake-error-xcode-11-ios-13-2
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func dropPinsZoomIn(placemarks:[MKPlacemark]){
        guard placemarks.first != nil else{return}
        // cache the pin
        woolworthsPin = placemarks
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        for eachPlackmark in placemarks{
            let annotation = MKPointAnnotation()
            annotation.coordinate = eachPlackmark.coordinate
            annotation.title = eachPlackmark.name
            if let city = eachPlackmark.locality,
               let state = eachPlackmark.administrativeArea {
                annotation.subtitle = "\(city) \(state)"
            }
            mapView.addAnnotation(annotation)
        }
        //https://stackoverflow.com/questions/59127876/mkcoordinatespanmake-error-xcode-11-ios-13-2
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: placemarks.first!.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

extension MapVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        //https://stackoverflow.com/questions/37946990/cgrectmake-cgpointmake-cgsizemake-cgrectzero-cgpointzero-is-unavailable-in-s
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        //https://stackoverflow.com/questions/37800342/uicontrolstate-normal-is-unavailable
        //button.setBackgroundImage(UIImage(named: "car"), for: .Normal)
        button.setBackgroundImage(UIImage(named: "car"), for: [])
        
        //button.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        //let theSelectedPinBefore = selectedPin
        var theCoordinate:CLLocationCoordinate2D? = nil
        
        theCoordinate = view.annotation!.coordinate
        //        print(view.annotation!.title)
        //        print(view.annotation!.subtitle)
        //        print(view.annotation!.description)
        //        let thisPlaceMark = MKPlacemark(coordinate: theCoordinate!)
        for thePin in woolworthsPin! {
            if thePin.coordinate.latitude == theCoordinate?.latitude && thePin.coordinate.longitude == theCoordinate?.longitude {
                selectedPin = thePin
            }
        }
        //if theSelectedPinBefore != selectedPin {
            getDirections()
        //}
    }
}
