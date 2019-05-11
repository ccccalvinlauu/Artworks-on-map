//
//  Artworks.swift
//  COMP327.Assignment.2.u6tcl
//
//  Created by lau tszchung on 5/12/2018.
//  Copyright © 2018 lau tszchung. All rights reserved.
//


import Foundation
import CoreData

struct artwork: Decodable{
    
    let id: String
    let title: String
    let artist: String
    let yearOfWork: String
    let Information: String
    let lat: String
    let long: String
    let location: String
    let locationNotes: String
    let fileName: String
    let lastModified: String
    let enabled: String
    var distance: Double?
    
}

struct artworksdetails: Decodable {
    let artworks2: [artwork]
    static func details (completion: @escaping([artwork]) -> ()){
        let url = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP327/artworksOnCampus/data.php?class=artworks2&lastUpdate=2017-11-01"

        let request = URLRequest(url: URL(string:url)!)
        
        //URL Session
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            var artworksarray = [artwork]()

            
            
            if let datefrom = UserDefaults.standard.object(forKey: "lastUpdate"){
                print("No new update : \(datefrom)")
                do{
                    let fetchRequest: NSFetchRequest<CoreArtworksDetails> = CoreArtworksDetails.fetchRequest()
                    let array = try PersistenceService.context.fetch(fetchRequest)
                    for item in array{
                        let obj = artwork.init(id: item.id!, title: item.title!, artist: item.artist!, yearOfWork: item.yearOfWork!, Information: item.information!, lat: item.lat!, long: item.long!, location: item.location!, locationNotes: item.locationNotes!, fileName: item.fileName!, lastModified: item.lastModified!, enabled: item.enabled!, distance: nil)
                        artworksarray.append(obj)
                    }
                    
                }catch{
                    print(error)
                }
            }else{
                
                if let data = data{
                    
                    do{
                        let urlResponse = response?.url
                        guard let lastUpdate = urlResponse?.valueOf("lastUpdate") else{return}
                        UserDefaults.standard.set(lastUpdate, forKey: "lastUpdate")
                        print("new update")
                        
                        let report = try JSONDecoder().decode(artworksdetails.self, from: data)
                        
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreArtworksDetails")
                        do {
                            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                            try PersistenceService.context.execute(batchDeleteRequest)
                            
                        } catch {
                            print(error.localizedDescription)
                        }
                        for item in report.artworks2{
                            let saving = CoreArtworksDetails(context: PersistenceService.context)
                            saving.artist = item.artist
                            saving.enabled = item.enabled
                            saving.fileName = item.fileName
                            saving.id = item.id
                            saving.information = item.Information
                            saving.lastModified = item.lastModified
                            saving.lat = item.lat
                            saving.location = item.location
                            saving.locationNotes = item.locationNotes
                            saving.long = item.long
                            saving.title = item.title
                            saving.yearOfWork = item.yearOfWork
                            PersistenceService.saveContext()
                            
                            artworksarray.append(item)
                            
                        }
                    }catch{
                        print(error.localizedDescription)
                    }
                    
                }
            }
            completion(artworksarray)

        }
        task.resume()
    }
}


extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}

