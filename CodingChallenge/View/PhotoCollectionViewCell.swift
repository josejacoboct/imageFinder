//
//  PhotoCollectionViewCell.swift
//  CodingChallenge
//
//  Created by José Jacobo Contreras Trejo on 30/01/22.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    //Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    
    //Var
    var id: String = String()
    var image: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.photoImageView.image = self.image
            }
        }
    }
    
    override func awakeFromNib() {
        
        //cutomizing cell
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        photoImageView.layer.cornerRadius = 10
        photoImageView.clipsToBounds = true
        self.sizeToFit()
    }
}
