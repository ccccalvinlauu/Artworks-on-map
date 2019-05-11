//
//  DetailsViewController.swift
//  COMP327.Assignment.2.u6tcl
//
//  Created by lau tszchung on 28/11/2018.
//  Copyright © 2018 lau tszchung. All rights reserved.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController {
    
    //fields
    var SelectedArtwork = ""
    var SelectedIndex = 0
    var SavedContext = [SavedArtwork]()
    //base path of images
    let Basepath = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP327/artwork_images/"
    
    
    //Labels
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var navigationitem: UINavigationItem!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationNoteLabel: UILabel!
    
    //actions for back button
    @IBAction func Back(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "Back", sender: self)
        
    }
    
    //function that run the URL session(para: url), completion handler(data, urlResponse, error))
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    //function to down laod images from url(para:url)
    func downloadImage(from url: URL) {
        print("Download Started")
        //start URL session
        getData(from: url) { data, response, error in
            
            guard let data = data, error == nil else { return }
            print("Download Finished")
            
            DispatchQueue.main.async() {
                //set image
                self.imageview.image = UIImage(data: data)
                //convert to NSData
                let imageData: NSData = data as NSData
                //Saving to Core Data with title and NSData of the image
                let saving = SavedArtwork(context: PersistenceService.context)
                saving.title = self.SelectedArtwork
                saving.image = imageData
                PersistenceService.saveContext()
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var savedbefore = false
        //fetch Data from Core Data
        do{
            let fetchRequest: NSFetchRequest<SavedArtwork> = SavedArtwork.fetchRequest()
            SavedContext = try PersistenceService.context.fetch(fetchRequest)
        }catch{
            print(error)
        }
        
        //check if there is selected artwork
        if(SelectedArtwork == ""){
            guard let index = buildingDetails.index(where : {$0.building == SelectedBuilding}) else {return}
            SelectedArtwork = buildingDetails[index].titlelist[0]
            
        }
        //check if core data contains the image needed
        for item in SavedContext{
            if item.title! == SelectedArtwork{
                savedbefore = true
                print("from Core Data")
                self.imageview.image = UIImage(data: item.image! as Data)
            }
        }
        
        guard let index = ArtworkData.index(where: {$0.title == SelectedArtwork}) else {return}
        SelectedIndex = index
        //if there is no exist image in Core Data
        if savedbefore == false{
            //creating the url path
            let urlpath = Basepath + ArtworkData[index].fileName.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            if let url = URL(string: urlpath){
                downloadImage(from: url)
                
            }
            
        }
        //Set Labels
        navigationitem.title = SelectedArtwork
        TitleLabel.text = SelectedArtwork
        yearLabel.text = "Artist : \(ArtworkData[index].artist)(\(ArtworkData[index].yearOfWork))"
        infoLabel.numberOfLines = 0
        infoLabel.lineBreakMode = .byWordWrapping
        infoLabel.text = ArtworkData[index].Information
        locationLabel.text = "Location : \(ArtworkData[index].location)"
        locationNoteLabel.text = "Note : \(ArtworkData[index].locationNotes)"
        
    }
    
    
}
