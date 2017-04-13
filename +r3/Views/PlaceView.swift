//
//  PlaceView.swift
//  +r3
//
//  Created by Xin Hua on 9/22/16.
//  Copyright © 2016 Igor Gubanov. All rights reserved.
//

import UIKit

protocol PlaceViewDelegate: NSObjectProtocol {
    func placeView(didTapped place: Place!)
}

class PlaceView: UIView {

    @IBOutlet var lblInfo: UILabel?
    
    var delegate: PlaceViewDelegate! = nil
    var place: Place! = nil {
        didSet {
            lblInfo?.text = place.shortInfo
        }
    }
    
    class func instanceFromNib() -> PlaceView {
        return UINib(nibName: "PlaceView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PlaceView
    }
    
    @IBAction func onBtnTap() {
        delegate?.placeView(didTapped: place)
    }
    
    
}
