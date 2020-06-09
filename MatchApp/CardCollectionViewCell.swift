//
//  CardCollectionViewCell.swift
//  MatchApp
//
//  Created by Sean Low
//  From: https://www.youtube.com/user/CodeWithChris
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var frontImageView: UIImageView!
    
    @IBOutlet weak var backImageView: UIImageView!
    
    var card: Card?
    
    func configureCell(card: Card) {
    
        // Keep track of the card this cell represents
        self.card = card
        
        // Set the front image view to the image that represents the card
        frontImageView.image = UIImage(named: card.imageName)
        
        // Check if card is Matched
        if (card.isMatched) {
            
            // Ensure that it is invisible
            backImageView.alpha = 0
            frontImageView.alpha = 0
            return
        } else {
            
            backImageView.alpha = 1
            frontImageView.alpha = 1
        }
        
        
        // Reset the state of the cell by checking the flipped status of the card and then showing the front or the back image
        if (card.isFlipped) {
            // Show the front image view
            flipUp(speed: 0);
        } else {
            // Show the back image view
            flipDown(speed: 0, delay: 0);
        }
    }
    
    // Sets default as 0.3 if nothing is specified
    func flipUp(speed: TimeInterval = 0.3) {
        
        // Flip Up Animation
        UIView.transition(from: backImageView, to: frontImageView, duration: speed, options: [.showHideTransitionViews, .transitionFlipFromLeft], completion: nil)
        
        // Set the status of the card
        card?.isFlipped = true;
    }
    
    func flipDown(speed: TimeInterval = 0.3, delay: TimeInterval = 0.5) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            UIView.transition(from: self.frontImageView, to: self.backImageView, duration: speed, options: [.showHideTransitionViews, .transitionFlipFromLeft], completion: nil)
            
            // Set the status of the card
            self.card?.isFlipped = false;
        }
    }
    
    func remove() {
        
        // Make the image views invisible
        // Property that sets the opacity of the element
        // If its 0 it is invisible
        
        backImageView.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveEaseOut, animations: {
            
            // Animates the alpha property from the current value (1) to 0
            self.frontImageView.alpha = 0
            
        }, completion: nil)
    }
}
