//
//  InitViewcontroller.swift
//  FaceFun
//
//  Created by Gagandeep Singh Madan on 19/04/20.
//  Copyright © 2020 Gagandeep Singh Madan. All rights reserved.
//

import UIKit
import NeuralLabs_iOS


class InitViewcontroller: NeuralInitialViewController {

    private let mainSegue = "InitToMainSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func loadMainView() {
        self.performSegue(withIdentifier: mainSegue, sender: nil)
    }

    open override func getAppImage() -> UIImage? {
        return UIImage(named: "launch")
    }
}
