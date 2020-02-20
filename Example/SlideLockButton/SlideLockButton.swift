//
//  SlideLockButton.swift
//  SlideLockButton
//
//  Created by Mohamed Maail on 6/7/16.
//  Copyright © 2020 Bosco Domingo. All rights reserved.
//

import Foundation
import UIKit

protocol SlideLockButtonDelegate {
    func statusUpdated(status: SlideLockButton.Status, sender: SlideLockButton)
}

@IBDesignable class SlideLockButton: UIView {
    enum Status: String {
        case Locked = "Locked"
        case Unlocked = "Unlocked"
        //case Sliding = "Sliding" //not fully tested
    }

    var delegate: SlideLockButtonDelegate?

    ///The View that slides. It is twice as big as the button's frame.
    var dragView = UIView()
    var mainLabel = UILabel()
    var dragViewLabel = UILabel() //disable to not show any text while sliding
    var imageView = UIImageView()
    var unlocked = false
    var layoutSet = false

    @IBInspectable var buttonLockedColor: UIColor = .gray {
        didSet {
            setStyle()
        }
    }

    @IBInspectable var buttonUnlockedColor: UIColor = .black

    @IBInspectable var buttonCornerRadius: CGFloat = 30 {
        didSet {
            setStyle()
        }
    }

    @IBInspectable var dragViewColor: UIColor = .darkGray {
        didSet {
            setStyle()
        }
    }

    @IBInspectable var dragPointWidth: CGFloat = 60 {
        didSet {
            setStyle()
        }
    }

    @IBInspectable var dragPointCornerRadius: CGFloat = 30 { //Set as half of dragPointWidth to round dragPoint to a circle
        didSet {
            setStyle()
        }
    }

    @IBInspectable var dragPointImage: UIImage = UIImage() {
        didSet {
            setStyle()
        }
    }

    var buttonFont = UIFont.systemFont(ofSize: 16.0) //add aditional fonts if desired

    //Use the .ttf, .otf, etc. filename. E.g. "Roboto-Light" if you added Roboto-Light.ttf
    @IBInspectable var fontName: String = "" {
        didSet {
            setFont()
        }
    }

    @IBInspectable var fontSize: CGFloat = 16.0 {
        didSet {
            setFont()
        }
    }

    @IBInspectable var buttonLockedText: String = NSLocalizedString("UNLOCK", comment: "") {
        didSet {
            setStyle()
        }
    }

    @IBInspectable var buttonLockedTextColor: UIColor = .white {
        didSet {
            setStyle()
        }
    }

    @IBInspectable var dragViewText: String = NSLocalizedString("UNLOCKING", comment: "") {
        didSet {
            setStyle()
        }
    }

    @IBInspectable var dragViewTextColor: UIColor = .white {
        didSet {
            setStyle()
        }
    }

    @IBInspectable var buttonUnlockedText: String = NSLocalizedString("UNLOCKED", comment: "")

    @IBInspectable var buttonUnlockedTextColor: UIColor = .white


    //MARK: Inits
    override init (frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override func layoutSubviews() {
        if !layoutSet {
            self.setUpButton()
            self.layoutSet = true
        }
    }


    //MARK: setStyle
    func setStyle() {
        self.mainLabel.text = NSLocalizedString(self.buttonLockedText, comment: "")
        self.dragViewLabel.text = NSLocalizedString(self.dragViewText, comment: "")
        self.dragView.frame.size.width = self.dragPointWidth
        self.dragView.backgroundColor = self.dragViewColor
        self.backgroundColor = self.buttonLockedColor
        self.imageView.image = dragPointImage
        self.mainLabel.textColor = self.buttonLockedTextColor
        self.dragViewLabel.textColor = self.dragViewTextColor

        self.dragView.layer.cornerRadius = dragPointCornerRadius
        self.layer.cornerRadius = buttonCornerRadius
    }

    func setFont(){
        guard let font = UIFont(name: self.fontName, size: self.fontSize) else { return }
        self.buttonFont = font
        self.mainLabel.font = font
        self.dragViewLabel.font = font
    }

    //MARK: setUpButton
    func setUpButton() {
        self.backgroundColor = self.buttonLockedColor

        self.dragView = UIView(frame: CGRect(x: dragPointWidth - self.frame.size.width * 2, y: 0, width: self.frame.size.width * 2, height: self.frame.size.height))
        self.dragView.backgroundColor = dragViewColor
        self.dragView.layer.cornerRadius = dragPointCornerRadius
        self.addSubview(self.dragView)

        //Labels
        if !self.buttonLockedText.isEmpty {
            self.mainLabel = UILabel(frame: CGRect(x: self.dragPointWidth, y: 0, width: self.frame.size.width - self.dragPointWidth, height: self.frame.size.height))
            self.mainLabel.textAlignment = .center
            self.mainLabel.text = NSLocalizedString(self.buttonLockedText, comment: "")
            self.mainLabel.textColor = .white
            self.mainLabel.font = self.buttonFont
            self.mainLabel.textColor = self.buttonLockedTextColor
            self.addSubview(self.mainLabel)

            self.dragViewLabel = UILabel(frame: CGRect(x: self.frame.size.width, y: 0, width: self.frame.size.width, height: self.frame.size.height))
            self.dragViewLabel.textAlignment = .center
            self.dragViewLabel.text = NSLocalizedString(self.dragViewText, comment: "")
            self.dragViewLabel.textColor = .white
            self.dragViewLabel.font = self.buttonFont
            self.dragViewLabel.textColor = self.dragViewTextColor
            self.dragView.addSubview(self.dragViewLabel)
        }
        self.bringSubviewToFront(self.dragView)

        //Image
        if self.dragPointImage != UIImage() { //user chose a custom image to display on top of the slider
            self.imageView = UIImageView(frame: CGRect(x: self.frame.size.width * 2 - dragPointWidth, y: 0, width: self.dragPointWidth, height: self.frame.size.height))
            self.imageView.contentMode = .center
            self.imageView.image = self.dragPointImage
            self.dragView.addSubview(self.imageView)
        }

        self.layer.masksToBounds = true

        // Pan gesture recognition
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panDetected(sender:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        self.dragView.addGestureRecognizer(panGestureRecognizer)
    }

    //MARK: panDetected
    @objc func panDetected(sender: UIPanGestureRecognizer) {
        //Call delegate?.statusUpdated(status: .Sliding, sender: self) if desired
        var translatedPoint = sender.translation(in: self)
        translatedPoint = CGPoint(x: translatedPoint.x, y: self.frame.size.height / 2)
        sender.view?.frame.origin.x = (dragPointWidth - self.frame.size.width * 2) + translatedPoint.x
        if sender.state == .ended {
            let velocityX = sender.velocity(in: self).x * 0.2
            var finalX = translatedPoint.x + velocityX
            finalX = max(finalX, 0) //avoiding negative values
            if finalX + self.dragPointWidth > (self.frame.size.width - dragPointWidth / 2) {
                self.unlocked = true
                self.unlock()
            }

            let animationDuration: Double = abs(Double(velocityX) * 0.0002) + 0.2
            UIView.transition(with: self, duration: animationDuration, options: .curveEaseOut, animations: {
            }, completion: { status in
                    if status {
                        self.animationFinished()
                    }
                })
        }
    }

    //MARK: Animations
    func animationFinished() {
        if !unlocked {
            self.reset()
        }
    }

    ///Unlock animation, when the slider reaches the end of the button
    func unlock() {
        UIView.transition(with: self, duration: 0.2, options: .curveEaseOut, animations: {
            self.dragView.frame = CGRect(x: self.frame.size.width - self.dragView.frame.size.width, y: 0, width: self.dragView.frame.size.width, height: self.dragView.frame.size.height)
        }) { status in
            if status {
                self.dragView.backgroundColor = self.buttonUnlockedColor
                self.imageView.isHidden = true
                self.dragViewLabel.text = NSLocalizedString(self.buttonUnlockedText, comment: "")
                self.dragViewLabel.textColor = self.buttonUnlockedTextColor
                self.delegate?.statusUpdated(status: .Unlocked, sender: self)
            }
        }
    }

    ///Resets the button
    func reset() {
        UIView.transition(with: self, duration: 0.2, options: .curveEaseOut, animations: {
            self.dragView.frame = CGRect(x: self.dragPointWidth - self.frame.size.width * 2, y: 0, width: self.dragView.frame.size.width, height: self.dragView.frame.size.height)
        }) { status in
            if status {
                self.dragView.backgroundColor = self.dragViewColor
                self.imageView.isHidden = false
                self.dragViewLabel.text = NSLocalizedString(self.dragViewText, comment: "")
                self.dragViewLabel.textColor = self.dragViewTextColor
                self.unlocked = false
                self.delegate?.statusUpdated(status: .Locked, sender: self)
            }
        }
    }

}
