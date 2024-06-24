//
//  splashingViewController.swift
//  task by wisdom
//
//  Created by Mani on 23/06/24.
//

import UIKit

class splashingViewController: UIViewController {
    
    @IBOutlet weak var splashimageview: UIImageView!
     
    var walkingimages: [UIImage] = []
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
   
    func navigatehomecontroller() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let desitantionvc = storyboard.instantiateViewController(withIdentifier: "home") as? PhotolibraryViewController {
            navigationController?.pushViewController(desitantionvc, animated: true)
        }
        
    }

   

}
