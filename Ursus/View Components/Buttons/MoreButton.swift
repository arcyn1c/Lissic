//
//  MoreButton.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 2/10/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class MoreButton: UrsusButton {
	
	// Only override draw() if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
		// Drawing code
		super.draw(rect)
		
		if !self.glyphOnly && self.changesWithTheme {
			if PreferenceManager.shared.theme == .dark {
				
				StyleKit.drawMoreIcon(frame: rect, resizing: .aspectFit, iconColor: StyleKit.darkIconGlyphColor)
			} else {
				
				StyleKit.drawMoreIcon(frame: rect, resizing: .aspectFit, iconColor: StyleKit.lightIconGlyphColor)
			}
		} else {
			
			StyleKit.drawMoreIcon(frame: rect, resizing: .aspectFit, iconColor: self.tintColor)
		}
	}
	
}
