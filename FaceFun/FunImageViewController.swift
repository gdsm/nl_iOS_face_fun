//
//  FunImageViewController.swift
//  FaceFun
//
//  Created by Gagandeep Singh Madan on 24/04/20.
//  Copyright © 2020 Gagandeep Singh Madan. All rights reserved.
//

import UIKit
import NeuralLabs_iOS

class FunImageViewController: NeuralBaseViewController {

    public var image: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnShare: NeuralIconButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.backgroundColor = .red
        backButton?.backgroundColor = NeuralManager.theme().backgrounColor()
        
        btnShare?.setTitle(IconFontCodes.share, for: .normal)
        btnShare?.backgroundColor = NeuralManager.theme().backgrounColor()
        btnShare?.setTitleColor(.white, for: .normal)
        btnShare?.contentHorizontalAlignment = .center;
        
        imageView.image = image
    }
    
    @IBAction func onBtnShare(_ sender: NeuralIconButton) {
        showHud("Sharing image")
        nlUtils.shared.share(image, on: self) {
            self.hideHud()
        }
    }
    
    override func canLayoutAllowsBannerAds() -> Bool {
        return false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
