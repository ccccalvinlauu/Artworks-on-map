//
//  PopUpViewController.swift
//  COMP327.Assignment.2.u6tcl
//
//  Created by lau tszchung on 2/12/2018.
//  Copyright © 2018 lau tszchung. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
    
//fields
    var myindex = 0
    var artworkTitle = ""

//action for Close button
    @IBAction func Close(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let index = buildingDetails.index(where: {$0.building == SelectedBuilding }) else {return}
        self.myindex = index

    }
    

}

//TableView

extension PopUpViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildingDetails[myindex].titlelist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewCell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.text = buildingDetails[myindex].titlelist[indexPath.row]

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        artworkTitle = buildingDetails[myindex].titlelist[indexPath.row]
        performSegue(withIdentifier: "showfromlist", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DetailsViewController
        vc.SelectedArtwork = artworkTitle
    }
    
}
