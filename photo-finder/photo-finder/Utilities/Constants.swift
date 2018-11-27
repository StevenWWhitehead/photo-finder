//
//  Constants.swift
//  photo-finder
//
//  Created by Steve Whitehead on 11/19/18.
//  Copyright © 2018 Greenhouse Labs. All rights reserved.
//

import UIKit

let BASE_URL = "https://api.imgur.com/3/gallery/search/time/"
let SEARCH_URL = "?q="

let DEFAULT_IMAGE = UIImage(named: "Default Image")

typealias ImgurRequestCompletion = (Root?) -> Void

typealias ImageDataCompletion = (UIImage?) -> Void

typealias Handler = () -> Void
