//
//  PhotoViewModel.swift
//  CodingChallenge
//
//  Created by José Jacobo Contreras Trejo on 30/01/22.
//

import Foundation
import UIKit

class PhotosViewModel{
    
    //Vars
    private let networker = ApiManager()
    private var photos = [Photo]()
    
    //get data from flickr
    func loadData(text: String, completionHandler: @escaping (Error?) -> Void
    ){
        networker.getPhotosByText(text: text) { photos, error in
            guard error == nil, let photos = photos else {
                completionHandler(error)
                return
            }
            
            self.photos = photos
            completionHandler(nil)
        }
    }
    
    func cancelLoadData(){
        networker.cancelLoadData()
    }
    
    //get image from internet
    func loadImage(photo: Photo, completionHandler: @escaping (UIImage) -> (Void)){
        //create URL with photo values
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "farm\(photo.farm).static.flickr.com"
        components.path = "/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
        
        guard let imageURL = components.url else {
            let img = self.image(data: nil)
            completionHandler(img!)
            return
        }
        
        networker.downloadImage(imageURL: imageURL) { data, error  in
            let img = self.image(data: data)
            completionHandler(img!)
        }
    }
    
    private func image(data: Data?) -> UIImage! {
        guard let data = data, let image = UIImage(data: data) else {
            //default value
            return UIImage()
        }
        
        return image
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRows() -> Int {
        return photos.count
    }
    
    func item(indexPath: IndexPath) -> Photo {
        return photos[indexPath.row]
    }
}
