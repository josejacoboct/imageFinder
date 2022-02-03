//
//  API.swift
//  CodingChallenge
//
//  Created by José Jacobo Contreras Trejo on 29/01/22.
//

import Foundation

class ApiManager {
    
    //var
    private var imagesCache = NSCache<NSString, NSData>()
    private let session: URLSession
    private var loadDataTask: URLSessionTask?
    
    init() {
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }

    func getPhotosByText(text: String, completionHandler: @escaping ([Photo]?, Error?) -> (Void)) {
                
        //creating components to make url
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest/"
        let method = URLQueryItem(name: "method", value: "flickr.photos.search")
        let api_key = URLQueryItem(name: "api_key", value: "37ad288835e4c64fc0cb8af3f3a1a65d")
        let format = URLQueryItem(name: "format", value: "json")
        let nojsoncallback = URLQueryItem(name: "nojsoncallback", value: "1")
        let safe_search = URLQueryItem(name: "safe_search", value: "1")
        let text = URLQueryItem(name: "text", value: text)
        components.queryItems = [method,api_key,format,nojsoncallback,safe_search,text]
                
        //get url
        guard let url = components.url else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : NetworkManagerError.invalidURL.description!])
            completionHandler(nil, error)
            return
        }
        
        let request = URLRequest(url: url)
        
        loadDataTask = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completionHandler(nil, error)
                return
            }
            
            guard let data = data else {
                completionHandler(nil, error)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(Response.self, from: data)
                completionHandler(response.photos.photo, nil)
            } catch let error {
                completionHandler(nil, error)
            }
        }
        
        loadDataTask?.resume()
    }
    
    func cancelLoadData(){
        self.loadDataTask?.cancel()
    }
    
    func downloadImage(imageURL: URL, completionHandler: @escaping (Data?, Error?) -> (Void)) {
        
        //searching if already we have the data from the photo
        if let imageData = imagesCache.object(forKey: imageURL.absoluteString as NSString) {
            completionHandler(imageData as Data, nil)
            return
        }
        
        //get data from url image
        let task = session.downloadTask(with: imageURL) { data, response, error in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completionHandler(nil, error)
                return
            }
            
            guard let imageData = data else {
                completionHandler(nil, error)
                return
            }
            
            do {
                let data = try Data(contentsOf: imageData)
                self.imagesCache.setObject(data as NSData, forKey: imageURL.absoluteString as NSString)
                completionHandler(data, nil)
            } catch let error {
                completionHandler(nil, error)
            }
        }
        
        task.resume()
    }
}

