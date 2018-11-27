//
//  ImgurAPI.swift
//  photo-finder
//
//  Created by Steve Whitehead on 11/19/18.
//  Copyright © 2018 Greenhouse Labs. All rights reserved.
//

import Foundation
import Alamofire

class ImgurAPI {
    
    func getPhotos(pageNumber: Int, searchParamater: String, completion: @escaping ImgurRequestCompletion) {
        
        guard let url = URL(string: "\(BASE_URL)\(pageNumber)\(SEARCH_URL)" + searchParamater) else { return }
        
        let headers: HTTPHeaders = [
            "Authorization": "Client-ID 126701cd8332f32"
        ]
        
        Alamofire.request(url, headers: headers).responseJSON { (response) in
            if let error = response.result.error {
                debugPrint("The Almofire request error is " + error.localizedDescription)
                completion(nil)
                return
            }

            guard let data = response.data else {return}
            
            let jsonDecoder = JSONDecoder()
            do {
                let root = try jsonDecoder.decode(Root.self, from: data)
                completion(root)
            } catch {
                debugPrint(error.localizedDescription)
                completion(nil)
            }
        }
        
    }
}
