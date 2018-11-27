//
//  Debouncer.swift
//  photo-finder
//
//  Created by Steve Whitehead on 11/26/18.
//  Copyright © 2018 Greenhouse Labs. All rights reserved.
//

import Foundation

class Debouncer {
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    var handler: Handler?
    
    private let timeInterval: TimeInterval
    
    private var timer: Timer?

    func renewInterval() {
        
        timer?.invalidate()
    
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { [weak self] timer in
            self?.handleTimer(timer)
        })
    }
    
    private func handleTimer(_ timer: Timer) {
        guard timer.isValid else {
            return
        }
        handler?()
        handler = nil
    }
    
}
