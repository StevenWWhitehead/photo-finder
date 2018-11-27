//
//  DisplayCell.swift
//  photo-finder
//
//  Created by Steve Whitehead on 11/19/18.
//  Copyright © 2018 Greenhouse Labs. All rights reserved.
//

import UIKit
import Alamofire

class DisplayCell: UICollectionViewCell {
    
    var originalImageURL: String?
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    func configureCell(cellData: DisplayData ) {
    
        titleLabel.text = cellData.title ?? ""
       
        guard let imageURL = cellData.imageUrl else { self.imageView.image = DEFAULT_IMAGE; return }
        
        self.originalImageURL = imageURL
        
        activityIndicator.startAnimating()
        
        let key = imageURL.appendSuffixBeforeExtension(suffix: "m")
        
        if let image = SearchVC.imageCache.object(forKey: key as NSString) {
            imageView.image = image
            activityIndicator.stopAnimating()
        } else {
            getImageFromURL(key) { (image) in
                if image != nil {
                    if self.originalImageURL == imageURL {
                        self.imageView.image = image
                        SearchVC.imageCache.setObject(image!, forKey: key as NSString)
                        self.activityIndicator.stopAnimating()
                    }
                } else {
                    self.imageView.image = DEFAULT_IMAGE
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func getImageFromURL(_ url: String, completion: @escaping ImageDataCompletion) {
        guard let imageUrl = URL(string: url) else {return}
        
        let queue = DispatchQueue(label: "io.greenhouselabs.response-queue", qos: .utility, attributes: [.concurrent])
        
        Alamofire.request(imageUrl, method: .get).responseData(queue: queue, completionHandler: { (data) in
            guard let imageData = data.data else { return completion(nil) }
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                completion(image)
            }
        })
    }
    
}
