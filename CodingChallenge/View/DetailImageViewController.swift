//
//  DetailImageViewController.swift
//  CodingChallenge
//
//  Created by José Jacobo Contreras Trejo on 02/02/22.
//

import UIKit

class DetailImageViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var imageSelectedImageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    //var
    var image = UIImage(named: "sap")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 60
        imageSelectedImageView.image = image
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DetailImageViewController: UIImagePickerControllerDelegate, UIScrollViewDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true) {
            
        }
        
        //imageSelectedImageView.image =
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageSelectedImageView
    }
    
}
