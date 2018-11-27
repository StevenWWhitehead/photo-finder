//
//  SearchVC.swift
//  photo-finder
//
//  Created by Steve Whitehead on 11/19/18.
//  Copyright © 2018 Greenhouse Labs. All rights reserved.
//

import UIKit
import SVProgressHUD

class SearchVC: UIViewController, UISearchBarDelegate {
    
    let imgurAPI = ImgurAPI()
    var displayData = [DisplayData]()
    var isWaiting = false
    var pageNumber = 0
    var searchText: String?
    var isNewSearch = true

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var newSearchButton: UIButton!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var alertImageView: UIImageView!
    
    let searchImage = UIImage(named: "Search Image")
    let noImages = UIImage(named: "No Image")
    
    var selectedImage: DisplayData!
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    let debouncer = Debouncer(timeInterval: 0.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        searchBar.delegate = self
        
        if searchText == nil {
            imageCollectionView.isHidden = true
            searchBar.becomeFirstResponder()
            alertImageView.image = searchImage
        } else {
            imageCollectionView.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        SearchVC.imageCache.removeAllObjects()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imageCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchText != searchBar.text {
            isNewSearch = true
            performImageSearch()
            searchText = searchBar.text ?? ""
        }
        searchBar.text = nil
        searchBar.endEditing(true)
        searchBar.isHidden = true
        newSearchButton.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        if searchText != nil {
            searchBar.isHidden = true
            newSearchButton.isHidden = false
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.isNewSearch = true
        self.searchText = searchText
        
        debouncer.handler =  {
            self.performImageSearch()
        }
        
        debouncer.renewInterval()
        
    }
    
    @IBAction func newSearchBtnTapped(_ sender: Any) {
        searchBar.text = ""
        searchBar.isHidden = false
        newSearchButton.isHidden = true
        searchBar.becomeFirstResponder()
    }
    
    
    func performImageSearch() {
        
        guard let text = searchText else {return}
        if isNewSearch {
            pageNumber = 0
        }
        
        self.navigationItem.title = "Searching..."
    
        imgurAPI.getPhotos(pageNumber: pageNumber, searchParamater: text) { (root) in
        
            if self.isNewSearch {
                self.displayData.removeAll()
                self.imageCollectionView.reloadData()
                self.navigationItem.title = text
                SearchVC.imageCache.removeAllObjects()
            }
            
            self.isWaiting = true
            if let rootData = root?.data {
                if rootData.count == 0 {
                    self.isWaiting = false
                    self.alertImageView.image = self.noImages
                    self.imageCollectionView.isHidden = true
                } else {
                    for data in rootData {
                        let title = data.title ?? ""
                        if let images = data.images {
                            for image in images {
                                if image.type == "image/jpeg" || image.type == "image/png" {
                                    let imageURL = image.link ?? ""
                                    let displayData = DisplayData(imageUrl: imageURL, title: title)
                                    self.displayData.append(displayData)
                                }
                            }
                        } else {
                            if data.type == "image/jpeg" || data.type == "image/png" {
                                let imageURL = data.link ?? ""
                                let displayData = DisplayData(imageUrl: imageURL, title: title)
                                self.displayData.append(displayData)
                            }
                        }
                        
                    }
                    
                    if self.pageNumber == 0 {
                        self.imageCollectionView.setContentOffset(.zero, animated: false)
                    }
                    self.imageCollectionView.isHidden = false
                    self.imageCollectionView.reloadData()
                    self.isWaiting = false
                }
            }
        }
    }
    
   
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imageVC = segue.destination as? ImageVC {
            imageVC.imageToDisplay = selectedImage
        }
    }
    
}

extension SearchVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DisplayCell", for: indexPath) as? DisplayCell {
            cell.imageView.image = nil
            let cellData = displayData[indexPath.item]
            cell.configureCell(cellData: cellData)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.endEditing(true)
        searchBar.isHidden = true
        newSearchButton.isHidden = false
        selectedImage = displayData[indexPath.item]
        self.performSegue(withIdentifier: "toImageVC", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastSectionIndex = collectionView.numberOfSections - 1
        let lastItemIndex = collectionView.numberOfItems(inSection: lastSectionIndex) - 1
        if indexPath.section == lastSectionIndex && indexPath.item == lastItemIndex && !isWaiting {
            
            self.isNewSearch = false
            self.pageNumber += 1
            self.performImageSearch()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionFooter", for: indexPath) as! CollectionFooter
        
        if displayData.count > 0 {
            view.activityIndicator.isHidden = false
            view.activityIndicator.startAnimating()
        } else {
            view.activityIndicator.stopAnimating()
        }
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.orientation == .portrait {
            let size = collectionView.bounds.size.width / 2
            return CGSize(width: size - 10, height: size - 10)
        } else if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            let size = collectionView.bounds.size.width / 3
            return CGSize(width: size - 15, height: size - 5)
        }
        
        let size = collectionView.bounds.size.width / 2
        return CGSize(width: size - 10, height: size - 10)
    }
    
}

extension String {
    func appendSuffixBeforeExtension(suffix: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: "(\\.\\w+$)", options: [])
            return regex.stringByReplacingMatches(in: self, options: [], range: NSMakeRange(0, self.count), withTemplate: "\(suffix)$1")
        } catch {
            debugPrint(error.localizedDescription)
            return ""
        }
    }
}
