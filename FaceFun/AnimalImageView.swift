//
//  AnimalImages.swift
//  FaceFun
//
//  Created by Gagandeep Singh Madan on 23/04/20.
//  Copyright © 2020 Gagandeep Singh Madan. All rights reserved.
//

import UIKit
import NeuralLabs_iOS


let animalDict: [String] = ["Frog",
"Cow",
"Baby Orangutan",
"Racoon",
"Elephant",
"Hippopotamus",
"Dog"]


class AnimalImageView: NeuralBaseImageView {
    
    private var timer: Timer?
    var index: Int = 0
    private var titleLabel: NeuralBaseLabel? = nil
    
    public func start() {
        self.contentMode = .scaleAspectFit
        
        if titleLabel == nil {
            titleLabel = NeuralBaseLabel()
            titleLabel?.frame = CGRect(x: 20, y: 0, width: self.bounds.width - 40, height: 30)
            titleLabel?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            titleLabel?.textColor = NeuralManager.theme().textColor(state: .normal)
            titleLabel?.textAlignment = .center
            titleLabel?.text = "🧐 Finding best suite 🧐"
            self.addSubview(titleLabel!)
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: {[weak self] (t) in
            self?.nextImage()
        })
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func nextImage() {
        index = ((index + 1) % (animalDict.count) + 1)
        self.image = UIImage(named: "\(index).jpg")
    }
}
