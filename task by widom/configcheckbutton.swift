//
//  configbutton.swift
//  task by wisdom
//
//  Created by Mani on 23/06/24.
//

import Foundation
import UIKit

class CheckboxButton: UIButton {

    // Images
    let checkedImage = UIImage(named: "checkmark")!
    let uncheckedImage = UIImage(named: "squrebox")! 

    // Bool property
    var isChecked: Bool = false {
        didSet {
            self.updateImage()
        }
    }

    // Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    private func commonInit() {
        self.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        self.updateImage()
    }

    @objc private func buttonClicked() {
        self.isChecked.toggle()
    }

    private func updateImage() {
        self.setImage(self.isChecked ? checkedImage : uncheckedImage, for: .normal)
    }
}
