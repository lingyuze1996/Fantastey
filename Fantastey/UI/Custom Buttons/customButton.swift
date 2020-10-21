//
//  RoundButton.swift
//  Fantastey
//
//  Created by Yuze Ling on 21/10/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    func setupButton() {
        setStyle()
    }
    
    func setStyle() {
        //setShadow()
        setTitleColor(UIColor.white, for: .normal)
        
        backgroundColor = UIColor.systemTeal
        titleLabel?.font = UIFont(name: "ArialMT", size: 18)
        layer.cornerRadius = 14
        //layer.borderWidth = 3
        //layer.borderColor = UIColor.systemGray2.cgColor
    }
    
    private func setShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.5
        clipsToBounds = true
        layer.masksToBounds = false
    }
    
    func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
    }
}
