//
//  Root.swift
//  photo-finder
//
//  Created by Steve Whitehead on 11/19/18.
//  Copyright © 2018 Greenhouse Labs. All rights reserved.
//

import Foundation

struct Root: Codable {
    let data: [ImageData]?
}

struct ImageData: Codable {
    let images: [ImageLink]?
    let title: String?
    let link: String?
    let type: String?
}

struct ImageLink: Codable {
    let link: String?
    let type: String?
}

struct DisplayData {
    let imageUrl: String?
    let title: String?
}


