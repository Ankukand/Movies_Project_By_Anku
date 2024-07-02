//
//  Debouncer.swift
//  Movies_Anku
//
//  Created by Anku on 01/07/24.
//

import Foundation

class Debouncer {
    private let interval: TimeInterval
    private var timer: Timer?
    
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    func debounce(action: @escaping () -> Void) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            action()
        }
    }
    
    func cancel() {
        timer?.invalidate()
    }
}

