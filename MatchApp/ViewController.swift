//
//  ViewController.swift
//  MatchApp
//
//  Created by Sean Low
//  From: https://www.youtube.com/user/CodeWithChris
//

import UIKit

// UICollectionViewDelegate has no required methods
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    let model = CardModel()
    var cardsArray = [Card]()
    
    var timer: Timer?
    var milliseconds: Int = 0
    
    var firstFlippedCardIndex: IndexPath?
    
    var soundPlayer: SoundManager = SoundManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.loadData()
        
        // Set the view controller as the datasource and delegate of the collection view
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func loadData() {
        cardsArray = model.getCards()
        
        // Adding a value to milliseconds
        milliseconds = 10 * 1000
        
        // Setting FirstFlippedCardIndex to nil
        firstFlippedCardIndex = nil
        
        timerLabel.textColor = UIColor.black
        
        self.view.setNeedsDisplay()
        
        // Initialize the timer
        
        // This function allows you to select a method on a target upon finishing the timer
        // A timer gets scheduled into a runloop. Gets scheduled into the main runloop
        // However, in the main runloop, the task that is updating the UI View is also in the main runloop, which blocks the timer from executing and running
        timer = Timer.scheduledTimer(timeInterval: 0.001 , target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        
        RunLoop.main.add(timer!, forMode: .common)
        
        self.viewWillAppear(false)
    }
    
    // Happens the moment the UI appears for the User
    override func viewDidAppear(_ animated: Bool) {
        
        // Play shuffle sounds
        soundPlayer.playSound(effect: .shuffle)
    }
    
    // MARK: - Timer Methods
    
    // @objc allows the selector to select the function (objc) is objective c - allows swift to play nice with selector perhaps due to legacy code
    @objc func timerFired() {
        
        // Decrement the counter
        milliseconds -= 1
        
        // Update the label
        let seconds: Double = Double(milliseconds) / 1000.0
        timerLabel.text = String(format: "Time Remaining: %.2f", seconds)
        
        // Stop the timer if it reaches zero
        if milliseconds == 0 {
            
            timerLabel.textColor = UIColor.red
            timer?.invalidate()
            
            // TODO: Check if the user has cleared all the pairs
            checkForGameEnd()
        }
    }
    
    
    // MARK: - Collection View Delegate Methods
    
    // CollectionView asking the ViewController how many items to display
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return number of cards
        return cardsArray.count
        
    }
    
    // CollectionView asking the ViewController what to show at each index
    // Gets called when the collectionView wants to create a cell for that partiuclar index
    func collectionView(_ collectionView: UICollectionView,  cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get a cell
        // Creates a new cell or gets a cell to be reused
        // We need to typecast it as for now XCode only assumes the cell to be a UICollectionViewCell and not the subclass of the cell that we created
        // Hence if we do not typecast it we will be unable to access the internal methods
        
        // Is a required method
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        
        // Return it
        return cell
        
    }
    
    // Called right before the cell gets displayed and allows you to modify that cell
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // Configure the state of the cell based on the properties of the card that is represents
        
        // Casting the cell that is about to be displayed as a CardCollectionViewCell
        let cardCell = cell as? CardCollectionViewCell
        
        // Get the card from the card array
        let currentCard = cardsArray[indexPath.row]
        
        // TODO: Configure it
        cardCell?.configureCell(card: currentCard)
    }
    
    // Happens when you select a card
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Check if theres any time remaining. DOnt let the user interact if the time is 0
        if milliseconds <= 0 {
            return
        }
        
        // Get a reference to the cell that was tapped
        let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell
        
        if cell?.card?.isFlipped == false && cell?.card?.isMatched == false {
            // Optional chaining: calls flip up only if object isnt nil
            // Flip card up
            cell?.flipUp()
            
            // Play flip sounds
            soundPlayer.playSound(effect: .flip)
        }
        
        if (firstFlippedCardIndex == nil) {
            
            // This is the first card flipped over
            firstFlippedCardIndex = indexPath
        } else {
            
            // This is the second card that is flipped
            
            // Run the comparison logic
            
            checkForMatch(indexPath)
            
        }
    }
    
    func resetCards() {
        for card in cardsArray {
            card.isFlipped = false;
            card.isMatched = false;
        }
    }
    
    // MARK: - Game Logic Methods
    
    func checkForMatch(_ secondFlippedCardIndex: IndexPath) {
        
        let cardTwo = cardsArray[secondFlippedCardIndex.row]
        let cardOne = cardsArray[firstFlippedCardIndex!.row]
        
        // Get the 2 collection view cells that represent cardOne and cardTwo
        
        let cardOneCell = collectionView.cellForItem(at: firstFlippedCardIndex!) as? CardCollectionViewCell
        let cardTwoCell = collectionView.cellForItem(at: secondFlippedCardIndex) as? CardCollectionViewCell
        
        if cardTwo.imageName == cardOne.imageName {
            
            // Its a match
            
            // Play match sounds
            soundPlayer.playSound(effect: .match)
            
            // Set status and remove them
            cardOne.isMatched = true;
            cardTwo.isMatched = true;
            
            // Optional chaining (if cardOneCell is nil then it wont call the method)
            cardOneCell?.remove()
            cardTwoCell?.remove()
            
            // TODO: Check for game end

        } else {
            
            // Its not a match
            
            // Play nomatch sounds
            soundPlayer.playSound(effect: .nomatch)
            
            
            cardOne.isFlipped = false
            cardTwo.isFlipped = false
            
            // Flip them back over
            cardOneCell?.flipDown()
            cardTwoCell?.flipDown()
        }
        
        // Reset the firstFippledCardIndex property
        firstFlippedCardIndex = nil
    }
    
    
    func checkForGameEnd() {
        
        // Check if there is any unmatched card
        var hasWon = true
        
        for card in cardsArray {
            if card.isMatched == false {
                // We found a card that is unmatched
                hasWon = false
                break
            }
        }
        
        if hasWon {
            // User has won, show an alert
            showAlert(title: "Congrats", message: "You won!")
        } else {
            // User hasnt won yet, check if there's any time left
            if milliseconds <= 0 {
                showAlert(title: "Times up", message: "You lost!")
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        // UIAlert Method to make a pop up alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        // UIAlertAction to make a button that appears in the pop up alert
        // Add a button for the user to dismiss it
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        // https://stackoverflow.com/questions/24190277/writing-handler-for-uialertaction
        let playAgainAction = UIAlertAction(title: "Play again", style: .default, handler: {
            _ in
            self.loadData()
        })
        
        alert.addAction(okAction)
        alert.addAction(playAgainAction)
        
        // To present the alert
        present(alert, animated: true, completion: nil)
    }

}

