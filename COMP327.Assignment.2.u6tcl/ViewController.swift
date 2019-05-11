//
//  ViewController.swift
//  COMP327.Assignment.2.u6tcl
//
//  Created by lau tszchung on 24/11/2018.
//  Copyright © 2018 lau tszchung. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

//Global fields
var ArtworkData = [artwork]()
var buildingDetails = [buildings]()
let wait = DispatchGroup()
var SelectedBuilding = ""
var SelectedArtwork = ""

//building struct(building name, distance between current lcation and the buidling, all artworks in that building)
struct buildings {
    var building: String
    var distance: Double
    var titlelist = [String]()
}

class ViewController: UIViewController {
    
    //fields
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var Map: MKMapView!
    var manager = CLLocationManager()
    var searchBuilding = [buildings]()
    var search = [[String]]()
    
    //function that set up the array in the building struct, array contains all artwork in the building
    func setListInBuildingDetails() {
        print("set up list")
        for list in buildingDetails{
            var array = [String]()
            for item in ArtworkData{
                if item.location == list.building{
                    array.append(item.title)
                }
            }
            guard let myindex = buildingDetails.index(where : {$0.building == list.building}) else {return}
            buildingDetails[myindex].titlelist = array
        }
        //sort by distance
        buildingDetails = buildingDetails.sorted(by: {$0.distance < $1.distance})
        print("Distance")
        self.TableView.reloadData()
        //initialized the searching building to all buildings
        searchBuilding = buildingDetails
    }
    
    //function that set up the building and distance in the building struct
    func AddvalueToBuildingDetails(){
        print("set up buildings")
        for item in ArtworkData{
            if let distance = item.distance{
                if(buildingDetails.isEmpty){
                    let object = buildings.init(building: item.location, distance: distance, titlelist: [])
                    buildingDetails.append(object)
                }else{
                    var repeated = false
                    for n in buildingDetails{
                        if(n.building == item.location){
                            repeated = true
                        }
                    }
                    if(!repeated){
                        let object = buildings.init(building: item.location, distance: distance, titlelist: [])
                        buildingDetails.append(object)
                    }
                }
                
                
            }

        }
        self.setListInBuildingDetails()
    }
    
    //function that set up all annotations according to building
    func addannotation(){
        print("add annotation")
        for item in buildingDetails{
            guard let myindex = ArtworkData.index(where : {$0.title == item.titlelist[0]}) else {return}
            let annotation = MKPointAnnotation()
            if let latitude = Double(ArtworkData[myindex].lat) {
                if let longitude = Double(ArtworkData[myindex].long) {
                    annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                    annotation.title = item.building
                    annotation.subtitle = "\(item.titlelist.count) artworks found here"
                    self.Map.addAnnotation(annotation)
                }
            }
        }
    }
    
    //action of a single tap
    @objc func singleTap(sender: UITapGestureRecognizer) {
        self.SearchBar.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //a single tap gesture recognizer
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTap(sender:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(singleTapGestureRecognizer)
        
        
        Map.showsUserLocation = true
        
        
        //Data from JSON store in Artwrok struct
        artworksdetails.details { (results:[artwork]?) in
            if let Data = results{
                ArtworkData = Data
                //get access of user's location
                if CLLocationManager.locationServicesEnabled() == true {
                    if CLLocationManager.authorizationStatus() == .restricted ||
                        CLLocationManager.authorizationStatus() == .denied ||
                        CLLocationManager.authorizationStatus() == . notDetermined {
                        self.manager.requestWhenInUseAuthorization()
                    }
                    
                    self.manager.desiredAccuracy = kCLLocationAccuracyBest
                    self.manager.delegate = self
                    let workItem = DispatchWorkItem {
                        print("Location")
                        //updating location
                        self.manager.startUpdatingLocation()
                    }
                    
                    let queue = DispatchQueue.global()
                    queue.async {
                        workItem.perform()
                    }
                    
                }else{
                    //cannot get access to user's location
                    print("NOT ENABLED")
                }
            }
        }
    }
}

//Location Manager
extension ViewController: CLLocationManagerDelegate{
    
    //update location function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        print("location manager")
        
        let span:MKCoordinateSpan =  MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
        let mylocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: mylocation,span: span)
        self.Map.setRegion(region, animated: true)
        wait.enter()
        for n in 0...ArtworkData.count-1{
            //calculate distance
            if let latitude = Double(ArtworkData[n].lat) {
                if let longitude = Double(ArtworkData[n].long) {
                    let place = CLLocation(latitude: latitude, longitude: longitude)
                    let distance = place.distance(from: location)
                    ArtworkData[n].distance = distance
                }
            }

        }
        wait.leave()
        
        wait.wait()
        DispatchQueue.main.async {
            self.AddvalueToBuildingDetails()
            self.TableView.reloadData()
            self.addannotation()
        }
        
        
    }
    
    //Error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

//Table View
extension ViewController: UITableViewDataSource, UITableViewDelegate{
    
    //Zoom in to the selected place of the annotation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let building = searchBuilding.filter { (result) -> Bool in
            return !result.titlelist.isEmpty
        }[indexPath.section].building
        
        for item in ArtworkData{
            if item.location == building{
                if let latitude = Double(item.lat) {
                    if let longitude = Double(item.long) {
                        let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(latitude, longitude), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
                        self.Map.setRegion(region, animated: true)
                        break
                    }
                }
            }
        }
    }
    
    //Set cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //get the non-empty artwork array
        let list = searchBuilding.filter { (result) -> Bool in
            return !result.titlelist.isEmpty
        }
        
        cell.textLabel?.text = list[indexPath.section].titlelist[indexPath.row]
        
        cell.detailTextLabel?.text = "Distance : \(Double(round(1000*list[indexPath.section].distance)/1000))m"
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return searchBuilding.filter { (result) -> Bool in
            return !result.titlelist.isEmpty
            }.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let list = searchBuilding.filter { (result) -> Bool in
            return !result.titlelist.isEmpty
        }
        
        return list[section].titlelist.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchBuilding.filter { (result) -> Bool in
            return !result.titlelist.isEmpty
            }[section].building
        
    }
    
}


//MKMapView
extension ViewController: MKMapViewDelegate{
    
    //Clicked an annotations
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        if let annotationTitle = view.annotation?.title
        {
            SelectedBuilding = annotationTitle!
            //Mylocation
            if SelectedBuilding == "My Location"{
                return
            }else{
                guard let info = buildingDetails.index(where : {$0.building == SelectedBuilding}) else{return}
                if (buildingDetails[info].titlelist.count == 1){
                    //if there is only 1 artwork
                    performSegue(withIdentifier: "SingleSeuge", sender: self)
                    
                }else{
                    //if there are multiple artworks
                    performSegue(withIdentifier: "showlist", sender: self)
                    
                }
            }
        }
    }
    
}

//SearchBar
extension ViewController: UISearchBarDelegate{
    
    //text changed in searchbar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //search
        
        //if search bar is empty
        guard !searchText.isEmpty else {
            searchBuilding = buildingDetails
            self.TableView.reloadData()
            return
            
        }
        
        //change the artwork list in struct building
        for n in 0...buildingDetails.count-1{
            let test = buildingDetails[n].titlelist.filter { (result) -> Bool in
                //filter the array if its contains the searchText
                return result.contains(searchText)
            }
            searchBuilding[n].titlelist = test
        }
        self.TableView.reloadData()
    }
    
    //Search Button
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.SearchBar.endEditing(true)
    }
    
    //Cancel Button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.SearchBar.text = nil
        searchBuilding = buildingDetails
        self.SearchBar.endEditing(true)
        self.TableView.reloadData()
        
    }
    
    
}



