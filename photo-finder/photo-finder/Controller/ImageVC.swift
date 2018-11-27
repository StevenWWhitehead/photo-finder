//
//  ImageVC.swift
//  photo-finder
//
//  Created by Steve Whitehead on 11/26/18.
//  Copyright © 2018 Greenhouse Labs. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class ImageVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var imageToDisplay: DisplayData!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        self.navigationItem.title = imageToDisplay.title ?? ""
        
        guard let imageURL = imageToDisplay.imageUrl else { return }
        
        showLoader(with: "loading image...")
        
        if let image = SearchVC.imageCache.object(forKey: imageURL as NSString) {
            imageView.image = image
            self.hideLoader()
        } else {
            getImageFromURL(imageURL) { (image) in
                if image != nil {
                    self.imageView.image = image
                    SearchVC.imageCache.setObject(image!, forKey: imageURL as NSString)
                    self.hideLoader()
                } else {
                    self.imageView.image = DEFAULT_IMAGE
                    self.hideLoader()
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if SVProgressHUD.isVisible() {
            self.hideLoader()
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
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
    
    func showLoader(with text: String) {
        SVProgressHUD.show(withStatus: text)
        scrollView.isUserInteractionEnabled = false
    }
    
    func hideLoader() {
        SVProgressHUD.dismiss()
        scrollView.isUserInteractionEnabled = true
    }
}
