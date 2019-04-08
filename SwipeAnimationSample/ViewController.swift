//
//  ViewController.swift
//  SwipeAnimationSample
//
//  Created by sajeev Raj on 4/2/19.
//  Copyright © 2019 Sajeev Arya. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var swipableButton: UIButton!{
        didSet {
            swipableButton.layer.cornerRadius = swipableButton.frame.size.width/2
        }
    }
    @IBOutlet weak var optionsView: UIView!
    
    fileprivate let kRotationAnimation = "kRotationAnimation"
    
    fileprivate let shapeLayer = CAShapeLayer()
    fileprivate let gradientLayer = CAGradientLayer()
    
    var lastLocation: CGPoint?
    var buttonBottom: Int {
        return Int(screenHeight) - Int(swipableButton.convert(CGPoint(x: 0, y: 0), to: view).y + swipableButton.bounds.height)
    }
    
    var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    var buttonStartX: CGFloat {
        return (swipableButton.center.x - swipableButton.bounds.width/2)
    }
    
    var buttonEndX: CGFloat {
        return (swipableButton.center.x + swipableButton.bounds.width/2)
    }
    
    var buttonStartY: CGFloat {
        return swipableButton.center.y
    }
    
    var buttonSwipeLimitYPosition: CGFloat {
        return UIScreen.main.bounds.height/4
    }
    
    let progressiveBackgroundColor: UIColor = UIColor(red: 97/255.0, green: 154/255.0, blue: 242/255.0, alpha: 1)
    
    var buttonInitialYPosition: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureShapeLayer()
        
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))
        swipableButton.isUserInteractionEnabled = true
        swipableButton.addGestureRecognizer(swipeGesture)
        
        buttonInitialYPosition = UIScreen.main.bounds.height - swipableButton.bounds.height - 20

    }
    
    override func viewDidLayoutSubviews() {
        shapeLayer.frame = view.bounds
    }

    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        self.view.bringSubviewToFront(swipableButton)
        if sender.state == UIGestureRecognizer.State.began {
            handleBeginAction()
        } else if sender.state == UIGestureRecognizer.State.changed {
            handleChangeAction(sender: sender)
        } else if sender.state == UIGestureRecognizer.State.ended {
            handleGestureEndedAction()
        }
    }
    
    func changeBackgroundColor() {
        view.backgroundColor = progressiveBackgroundColor
    }
    
    func resetView() {
        shapeLayer.removeAllAnimations()
    }
    
    fileprivate func configureShapeLayer() {
        // Do any additional setup after loading the view, typically from a nib.
        
        shapeLayer.lineWidth = 1.0
        shapeLayer.fillColor = UIColor.blue.cgColor
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.actions = ["strokeEnd" : NSNull(), "transform" : NSNull()]
        shapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        view.layer.addSublayer(shapeLayer)
        view.layer.addSublayer(gradientLayer)
        
    }
    
    private func handleBeginAction() {
        swipableButton.transform = .identity
        lastLocation = swipableButton.center
        view.layer.addSublayer(gradientLayer)
    }
    
    private func handleChangeAction(sender: UIPanGestureRecognizer) {
        guard let location = lastLocation, let senderGesture = sender as? UIPanGestureRecognizer else { return }
        let translation = senderGesture.translation(in: swipableButton)

        let newY = location.y + translation.y
        swipableButton.center = CGPoint(x: location.x, y: newY)
        
        //  map to 0 to 1
        let alphaValue = newY * (1/buttonInitialYPosition)
        view.backgroundColor = progressiveBackgroundColor.withAlphaComponent(alphaValue)
        animateView()
        addDampingAnimation()
        addGradientColor()
    }
    
    func arrangeOptionsView() {
        optionsView.isHidden = false
        
        optionsView.frame = CGRect(x: optionsView.frame.origin.x, y: swipableButton.frame.origin.y + swipableButton.bounds.height + 5, width: optionsView.bounds.width, height: optionsView.bounds.height)
        view.layoutIfNeeded()
    }
    
    private func handleGestureEndedAction() {
        gradientLayer.removeFromSuperlayer()
        rotateButton()

        if buttonBottom > Int(buttonSwipeLimitYPosition) {
            UIView.animate(withDuration: 0.1) { [weak self] in
                guard let welf = self else { return }
                welf.swipableButton.center = CGPoint(x: welf.swipableButton.center.x, y: UIScreen.main.bounds.height - welf.buttonSwipeLimitYPosition)
                welf.animateView()
                welf.addDampingAnimation()
                welf.changeBackgroundColor()
                
                // show options view
//                welf.arrangeOptionsView()
                
                // change button image
                welf.swipableButton.setImage(UIImage(named: "close"), for: .normal)
            }
        }
        else {
            resetToInitialPostions()
        }
    }
    
    private func resetToInitialPostions() {
        
        // reset button image
        swipableButton.setImage(UIImage(named: "arrow"), for: .normal)
        
        // hide options view
        optionsView.isHidden = true
        
        // animate button down, and change background color
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let welf = self else { return }
            welf.swipableButton.frame = CGRect(x: welf.swipableButton.frame.origin.x, y: welf.buttonInitialYPosition, width: welf.swipableButton.bounds.width, height: welf.swipableButton.bounds.height)
        }) { [weak self] (completed) in
            self?.view.backgroundColor = .white
        }
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        resetToInitialPostions()
    }
    
    func animateView() {
        
        let buttonCentre = swipableButton.center
        
        let startPoint1 = CGPoint(x: 0.0, y: screenHeight)
        let endPoint1 = CGPoint(x: swipableButton.frame.origin.x, y: buttonStartY)
        let startPoint2 = CGPoint(x: swipableButton.frame.origin.x + swipableButton.bounds.width, y: buttonStartY)
        let endPoint2 =  CGPoint(x: screenWidth, y: screenHeight - 15)
        let curvatureCentre = CGPoint(x: buttonCentre.x, y: screenHeight - (CGFloat(buttonBottom)/3))
        let bezierPath1 = UIBezierPath()
        
        // start from left bottom corner
        bezierPath1.move(to: startPoint1)

        bezierPath1.addLine(
            to: CGPoint(x: 0.0, y: screenHeight - 15)
        )
        // go until the button start x
        bezierPath1.addCurve(
            to: endPoint1,
            controlPoint1: curvatureCentre,
            controlPoint2: endPoint1
        )
        
        // go to button end x
        bezierPath1.addLine(
            to: startPoint2
        )
        
        // go from right bottom corner
        bezierPath1.addCurve(
            to: endPoint2,
            controlPoint1: curvatureCentre,
            controlPoint2: endPoint2
        )
        
        bezierPath1.addLine(
            to: CGPoint(x: screenWidth, y: screenHeight)
        )
        self.shapeLayer.path = bezierPath1.cgPath
        
    }
    
    fileprivate func addScalingANimation() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            let scale = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self?.swipableButton.transform = scale
        }
    }
    
    func addDampingAnimation() {
        let spring = CASpringAnimation(keyPath: "position.y")
        spring.damping = 5
        spring.fromValue = shapeLayer.position.y
        spring.toValue = shapeLayer.position.y + 10.0
        spring.duration = spring.settlingDuration
        shapeLayer.add(spring, forKey: nil)
        
    }
    
    fileprivate func addGradientColor() {
        gradientLayer.frame = shapeLayer.frame
        gradientLayer.colors = [UIColor.blue.cgColor,
                                UIColor.red.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.mask = shapeLayer
    }
    
    fileprivate func rotateButton() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.swipableButton.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
        }
    }
}

