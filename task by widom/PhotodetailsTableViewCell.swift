//
//  PhotodetailsTableViewCell.swift
//  task by wisdom
//
//  Created by Mani on 23/06/24.
//

import UIKit

class PhotodetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellimage: UIImageView!
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var checkboxbutton: CheckboxButton!
    @IBOutlet weak var descriptionlabel: UILabel!
    @IBOutlet weak var customview: UIView!
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        customviewssetup()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    
        cellimage.image = nil
        titlelabel.text = nil
        descriptionlabel.text = nil
        checkboxbutton.isChecked = false
    }
    
    // customview setup
    func customviewssetup() {
        customview.layer.masksToBounds = true
        customview.clipsToBounds =  true
        customview.layer.cornerRadius =  15
        cellimage.layer.masksToBounds = true
        cellimage.clipsToBounds = true
        cellimage.layer.cornerRadius = 10
        descriptionlabel.sizeToFit()
    
        
    }
    
    // get the data from api
    func configdata(library: downloadedphotos, index: Int){
        let serialnumber = index + 1
        titlelabel.text = "\(serialnumber): \(library.author ?? "NO Author")"
        let descriptionText = "Description: \(library.customDescription)"
        let attributedString = NSMutableAttributedString(string: descriptionText)
        attributedString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ], range: NSRange(location: 0, length: 12))
        
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.black
        ], range: NSRange(location: 12, length: descriptionText.count - 12))
        
        descriptionlabel.attributedText = attributedString
        
        checkboxbutton.isChecked = library.ifcheckboxclicked
        cellimage.image = library.imagetoshow
        
    }
    
}
