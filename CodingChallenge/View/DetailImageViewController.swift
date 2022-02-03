//
//  DetailImageViewController.swift
//  CodingChallenge
//
//  Created by José Jacobo Contreras Trejo on 02/02/22.
//

import UIKit

class DetailImageViewController: UIViewController {
    
    //var
    var image = UIImage(named: "default")
    private let detailImageView = UIImageView()
    private var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailImageView.image = image
    }
    
    override func viewDidLayoutSubviews() {
        setDetailSelectedImage()
    }
    
    
    @IBAction func saveInGalleryImage(_ sender: Any) {
        
        guard let selectedImage = detailImageView.image else {
            print("Image not found!")
            return
        }
        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    func setDetailSelectedImage(){
        
        //set scroll view
        let imageScrollView: UIScrollView = UIScrollView()
        imageScrollView.delegate = self
        imageScrollView.alwaysBounceVertical = false
        imageScrollView.alwaysBounceHorizontal = false
        imageScrollView.showsVerticalScrollIndicator = true
        imageScrollView.flashScrollIndicators()
        imageScrollView.minimumZoomScale = 1.0
        imageScrollView.maximumZoomScale = 10.0
        self.view.addSubview(imageScrollView)
        
        //set detail image view
        let navBarHeight = self.view.frame.height - self.view.safeAreaLayoutGuide.layoutFrame.height
        let frameImage = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - navBarHeight)
        detailImageView.contentMode = .scaleAspectFit
        detailImageView.frame = frameImage
        imageScrollView.addSubview(detailImageView)
        
        //set constraints to imageScrollView
        let safeArea = self.view.safeAreaLayoutGuide
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 0).isActive = true
        imageScrollView.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: 0).isActive = true
        imageScrollView.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: 0).isActive = true
        imageScrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 0).isActive = true
    }
}

extension DetailImageViewController: UIImagePickerControllerDelegate, UIScrollViewDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        imagePicker.dismiss(animated: true, completion: nil)
        guard (info[.originalImage] as? UIImage) != nil else {
            print("Image not found")
            return
        }
        detailImageView.image = image
    }
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlertWith(title: "Error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Done!", message: "Your image has been saved to your photos.")
        }
    }
    
    func showAlertWith(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.detailImageView
    }
    
}
