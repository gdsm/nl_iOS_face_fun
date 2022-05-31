//
//  ViewController.swift
//  FaceFun
//
//  Created by Gagandeep Singh Madan on 15/04/20.
//  Copyright © 2020 Gagandeep Singh Madan. All rights reserved.
//

import UIKit
import NeuralLabs_iOS
import UICircularProgressRing

fileprivate let funImageSegue = "funImageSegue"



class MainViewController: NeuralBaseViewController, NeuralClassifierProtocol {

    weak var delegate: NeuralClassifierObjectProtocol?
    private var animalView: AnimalImageView = AnimalImageView(frame: CGRect(x: 50, y: 50, width: 250 , height: 150))
    private var unseenObjectTimer: Timer?
    private var classifierObject: ClassifierObject?
    private var detectedImage: UIImage!

    @IBOutlet weak var btnPlayPause: NeuralIconButton!
    @IBOutlet weak var timerRing: UICircularTimerRing!
    @IBOutlet weak var viewBase: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let bb = self.backButton {
            self.view.insertSubview(animalView, belowSubview: bb)
        } else {
            self.view.insertSubview(animalView, belowSubview: viewBase)
        }
        animalView.isHidden = true
        animalView.start()
        
        btnPlayPause.setTitle(IconFontCodes.playFill, for: .normal)
        btnPlayPause.setTitle(IconFontCodes.pauseFill, for: .selected)
        
        btnPlayPause.layer.cornerRadius = btnPlayPause.frame.height * 0.5
        
        btnPlayPause.titleLabel?.font = NeuralManager.theme().iconFont(size: 50)
        btnPlayPause.backgroundColor = NeuralManager.theme().backgrounColor()
        btnPlayPause.setTitleColor(NeuralManager.theme().textColor(state: .normal), for: .normal)
        btnPlayPause.setTitleColor(NeuralManager.theme().textColor(state: .selected), for: .selected)
        
        backButton?.backgroundColor = NeuralManager.theme().backgrounColor()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NeuralClassifierManager.sharedInstance.faceCameraClassifier(delegate: self,
                                                                    parentViewRect: view.bounds,
                                                                    boundingBoxColor: nil,
                                                                    id: "MainViewController",
                                                                    isFront: true)
        self.delegate?.startClassifier()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.stopClassifier()
    }
    
    func restartUnseenTimer() {
        unseenObjectTimer?.invalidate()
        unseenObjectTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {[weak self] (t) in
            self?.animalView.isHidden = true
            self?.stopDetector()
            self?.btnPlayPause.isSelected = false
        })
    }
    
    private func stopDetector() {
        timerRing.pauseTimer()
        timerRing.resetTimer()
    }
    
    private func startDetector() {
        timerRing.startTimer(to: 5) {[weak self] (state) in
            switch state {
            case .finished:
                self?.faceDetectionFinished(success: true)
                print("finished")
            case .continued(let time):
                print("continued: \(time)")
            case .paused(let time):
                print("paused: \(time)")
            }
        }
    }
    
    private func faceDetectionFinished(success: Bool) {
        self.btnPlayPause.isSelected = false
        if success {
            if self.unseenObjectTimer?.isValid ?? false{
                self.captureFrame()
            }
        }
        self.unseenObjectTimer?.invalidate()
        self.unseenObjectTimer = nil
        self.stopDetector()
        self.animalView.isHidden = true
    }
    
    private func captureFrame() {
        if let obj = classifierObject,
            let animalImage = animalView.image,
            let img = UIImage.image(pixelBuffer: obj.buffer) {
            
            var images: [UIImage] = [animalImage]
            var frames: [CGRect] = [animalView.frame]
            if let tImg = UIImage.image(text: animalDict[animalView.index-1],
                                        font: NeuralManager.helveticaNeueBold(40)!,
                                        textColor: NeuralManager.theme().textColor(state: .normal),
                                        backgroundColor: .clear, frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60)) {
                
                let tFrame = CGRect(x: (self.view.bounds.width - tImg.size.width) * 0.5,
                                    y: (self.view.bounds.height - tImg.size.height * 0.8),
                                    width: tImg.size.width,
                                    height: tImg.size.height)
                images.append(tImg)
                frames.append(tFrame)
            }
            self.detectedImage = img.imageOverlayingImages(images, frames: frames)
        }
        self.performSegue(withIdentifier: funImageSegue, sender: nil)
    }
    
    private func animalView(classifierRect: CGRect) -> CGRect {
        var imgvRect = animalView.frame
        imgvRect.origin.y = classifierRect.minY - (imgvRect.height * 0.8)
        imgvRect.origin.x = classifierRect.minX - ((imgvRect.width - classifierRect.width) * 0.5)
        if imgvRect.minX < 0 {
           imgvRect.origin.x = 0
        }
        if imgvRect.maxX > self.view.bounds.maxX {
            imgvRect.origin.x = self.view.bounds.maxX - imgvRect.width
        }
        if imgvRect.minY < 0 {
           imgvRect.origin.y = 0
        }
        if imgvRect.minY > self.view.bounds.maxY {
            imgvRect.origin.y = self.view.bounds.maxY - imgvRect.height
        }
        return imgvRect
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FunImageViewController {
            vc.image = detectedImage
        }
    }

    
    //MARK: Action Methods
    @IBAction func onBtn(_ sender: NeuralIconButton) {
        if sender.isSelected {
            stopDetector()
        } else {
            startDetector()
        }
        sender.isSelected = !sender.isSelected
    }
    
    
    //MARK: NeuralClassifierProtocol
    func initialised(objectDelegate: NeuralClassifierObjectProtocol) {
        delegate = objectDelegate
        delegate?.startClassifier()
        if let v = objectDelegate.getView(), !view.subviews.contains(v) {
            view.insertSubview(v, at: 0)
        }
        print("Neural Classifier initialised")
    }
    
    func drawClassifier(object: ClassifierObject) -> Bool {
                
        if let rect = object.viewRects.first, btnPlayPause.isSelected {
            animalView.isHidden = false
            animalView.frame = animalView(classifierRect: rect)
            restartUnseenTimer()
            classifierObject = object
        }
        return false
    }
}
