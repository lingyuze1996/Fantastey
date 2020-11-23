//
//  LocationSearchTableVC.swift
//  Fantastey
//
//  Created by Zoe on 20/11/20.
//  Copyright © 2020 Yuze Ling & Qixin He. All rights reserved.
//
//reference:https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/

import UIKit
import MapKit

class LocationSearchTableVC: UITableViewController {
    
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    
    //for dropping the pin mark on map
    var handleMapSearchDelegate:HandleMapSearch? = nil
    
    var didPutWoolworthPins = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    
}
//https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/
extension LocationSearchTableVC : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
//        if didPutWoolworthPins == false {
//            searchController.searchBar.text = "Woolworths"
//        }
        guard let mapView = mapView,
              let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { [self] response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
            
            if didPutWoolworthPins == false {
                self.initialSearchResults(for: searchController)
            }
        }
    }
    
    func initialSearchResults(for searchController: UISearchController){
        //        guard let mapView = mapView,
        //              let searchBarText = searchController.searchBar.text else { return }
        //        let request = MKLocalSearch.Request()
        //        request.naturalLanguageQuery = searchBarText
        //        request.region = mapView.region
        //        let search = MKLocalSearch(request: request)
        //        search.start { response, _ in
        //            guard let response = response else {
        //                return
        //            }
        //            self.matchingItems = response.mapItems
        //
        //        }
        
        guard matchingItems.count != 0 else{return}
        var matchingPlacemarks:[MKPlacemark]? = nil
        for matchingItem in matchingItems{
            let thePlacemark = matchingItem.placemark
            if (matchingPlacemarks?.append(thePlacemark)) == nil {
                matchingPlacemarks = [thePlacemark]
            }else{
                matchingPlacemarks!.append(thePlacemark)}
        }
        handleMapSearchDelegate?.dropPinsZoomIn(placemarks: matchingPlacemarks!)
        didPutWoolworthPins = true
    }
    
}
extension LocationSearchTableVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
    
}
//This class extension groups UITableViewDelegate methods together."
extension LocationSearchTableVC {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }
}

