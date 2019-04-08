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
    
    let shapeLayer = CAShapeLayer()
    let gradientLayer = CAGradientLayer()
    
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
    
    var buttonStartY: CGFloat {
        return swipableButton.center.y
    }
    
    var buttonSwipeLimitYPosition: CGFloat {
        return UIScreen.main.bounds.height/4
    }
    
    var buttonInitialYPosition: CGFloat = 0.0
    
    let progressiveBackgroundColor: UIColor = UIColor(red: 97/255.0, green: 154/255.0, blue: 242/255.0, alpha: 1)
    let initialBackgroundColor: UIColor = UIColor(red: 203/255.0, green: 217/255.0, blue: 239/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureShapeLayer()
        
        configureGesture()
        
        buttonInitialYPosition = screenHeight - swipableButton.bounds.height - 20
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
    
    private func configureShapeLayer() {
        shapeLayer.lineWidth = 1.0
        shapeLayer.fillColor = UIColor.blue.cgColor
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.actions = ["strokeEnd" : NSNull(), "transform" : NSNull()]
        shapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.layer.addSublayer(gradientLayer)
    }
    
    private func configureGesture() {
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))
        swipableButton.isUserInteractionEnabled = true
        swipableButton.addGestureRecognizer(swipeGesture)
    }
    
    private func handleBeginAction() {
        // reset button to initial identity
        swipableButton.transform = .identity
        
        // reset autolayout constraints
        swipableButton.translatesAutoresizingMaskIntoConstraints = true
        lastLocation = swipableButton.center
        view.layer.addSublayer(gradientLayer)
    }
    
    private func handleChangeAction(sender: UIPanGestureRecognizer) {
        guard let location = lastLocation else { return }
        let translation = sender.translation(in: swipableButton)

        let newY = location.y + translation.y
        
        // move button on dragging
        swipableButton.center = CGPoint(x: location.x, y: newY)
        
        // change background alpha based on dragging
        let alphaValue = newY * (1/buttonInitialYPosition)
        view.backgroundColor = progressiveBackgroundColor.withAlphaComponent(alphaValue)
        
        // animate button
        animateView()
        addDampingAnimation()
        
        // add gradient color
        addGradientColor()
    }
    
    private func arrangeOptionsView() {
        optionsView.isHidden = false
        
        optionsView.frame = CGRect(x: optionsView.frame.origin.x, y: swipableButton.frame.origin.y + swipableButton.bounds.height + 5, width: optionsView.bounds.width, height: optionsView.bounds.height)
        view.layoutIfNeeded()
    }
    
    private func handleGestureEndedAction() {
        gradientLayer.removeFromSuperlayer()
        
        // rotate button animation
        rotateButton()

        // check if button is dragged beyond the required position
        if buttonBottom > Int(buttonSwipeLimitYPosition) {
            UIView.animate(withDuration: 0.1, animations: { [weak self] in
                guard let welf = self else { return }
                
                // move button to new position
                welf.swipableButton.center = CGPoint(x: welf.swipableButton.center.x, y: welf.screenHeight - welf.buttonSwipeLimitYPosition)
                
                // draw path
                welf.animateView()
                
                // add spring animation
                welf.addDampingAnimation()
                
                // change color
                welf.changeBackgroundColor()
                
                // show options view
                welf.arrangeOptionsView()
            }) { [weak self] (completed) in
                // change button image
                self?.swipableButton.setImage(UIImage(named: "close"), for: .normal)
            }
        }
        else {
            resetToInitialPostions()
        }
    }
    
    private func resetToInitialPostions() {
        
        // hide options view
        optionsView.isHidden = true
        
        // animate button down, and change background color
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let welf = self else { return }
            
            // reset button position
            welf.swipableButton.frame = CGRect(x: welf.swipableButton.frame.origin.x, y: welf.buttonInitialYPosition, width: welf.swipableButton.bounds.width, height: welf.swipableButton.bounds.height)
        }) { [weak self] (completed) in
            
            // reset background color
            self?.view.backgroundColor = self?.initialBackgroundColor ?? .white
            
            // reset button image
            self?.swipableButton.setImage(UIImage(named: "arrow"), for: .normal)
        }
    }
    
    private func animateView() {
        
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
    
    private func addDampingAnimation() {
        let spring = CASpringAnimation(keyPath: "position.y")
        spring.damping = 5
        spring.fromValue = shapeLayer.position.y
        spring.toValue = shapeLayer.position.y + 10.0
        spring.duration = spring.settlingDuration
        shapeLayer.add(spring, forKey: nil)
        
    }
    
    private func addGradientColor() {
        gradientLayer.frame = shapeLayer.frame
        gradientLayer.colors = [UIColor.blue.cgColor,
                                UIColor.red.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.mask = shapeLayer
    }
    
    private func rotateButton() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.swipableButton.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
        }
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        resetToInitialPostions()
    }
}

