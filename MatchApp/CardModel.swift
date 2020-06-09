//
//  CardModel.swift
//  MatchApp
//
//  Created by Sean Low
//  From: https://www.youtube.com/user/CodeWithChris
//

import Foundation

class CardModel {
    
    func getCards() -> [Card] {
        
        // Declare an empty array
        var generatedCards = [Card]()
        var generatedNumbers = [Int]()
        
        var count = 0
        // Randomly generate 8 pairs of cards
        while count < 8 {
            
            // Generate a random number
            let randomNumber = Int.random(in: 1...13)
            
            // Create two new card objects
            let cardOne = Card()
            let cardTwo = Card()
            
            // Set their image names
            cardOne.imageName = "card\(randomNumber)"
            cardTwo.imageName = "card\(randomNumber)"
            
            if generatedNumbers.contains(where: {$0 == randomNumber}) {
                print("repeated")
                continue
            }
            // Add them to the array
            generatedCards += [cardOne, cardTwo]
            generatedNumbers += [randomNumber]
            count += 1
            
            print(randomNumber)
        }
        
        // Randomize the cards within the array
        generatedCards.shuffle()
        
        // Return the array
        return generatedCards
    }
    
}
