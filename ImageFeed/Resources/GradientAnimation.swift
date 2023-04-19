//
//  GradientAnimation.swift
//  ImageFeed
//
//  Created by Джами on 30.03.2023.


import UIKit

extension UIView {

    func setUpGradient(frame: CGRect, cornerRadius: CGFloat) {

        let gradient = CAGradientLayer()

        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.masksToBounds = true
        gradient.frame = frame
        layer.cornerRadius = cornerRadius

        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 2.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]

        gradient.add(gradientChangeAnimation, forKey: "locations")

        layer.addSublayer(gradient)
        layoutSubviews()
    }

    func removeGradient() {
        layer.sublayers?.removeAll()
    }
}
