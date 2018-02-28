//
//  GameViewController.swift
//  CookieCrunch
//
//  Created by Razeware on 13/04/16.
//  Copyright (c) 2016 Razeware LLC. All rights reserved.
//

import UIKit
import SpriteKit
import SwiftyTimer
import Bond
import ReactiveKit
import BAFluidView

class GameViewController: UIViewController {
  
  // MARK: Properties
  var score = 0
    
    var progressLength: CGFloat = 0
    
    @IBOutlet weak var gameOverView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scoreLabel: UILabel!
    // The scene draws the tiles and cookie sprites, and handles swipes.
    @IBOutlet weak var timerLabel: UILabel!
    var scene: GameScene!

    @IBOutlet weak var progressBorderView: UIView!
    // The level contains the tiles, the cookies, and most of the gameplay logic.
  // Needs to be ! because it's not set in init() but in viewDidLoad().
  var level: Level!
    
  
  // MARK: View Controller Functions
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait, .portraitUpsideDown]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    gameOverView.isHidden = true
    progressBorderView.layer.masksToBounds = true
    setupProgress()
    progressLength = progressBorderView.frame.width
    
    let property = Property<Int>(120)
    let timer = Timer.new(every: 1.second) {
        property.next(property.value - 1)
    }
    
    timer.start()
    
    property.observeNext { [unowned self] (time) in
        if time == 0 {
            print("конец игры")
            timer.invalidate()
            self.timerLabel.text = "0:00"
            self.showGameOver()
        } else {
            var strTime = ""
            let minutes = time / 60
            let seconds = time % 60
            strTime = seconds >= 10 ? "\(minutes):\(seconds)" : "\(minutes):0\(seconds)"
            self.timerLabel.text = strTime
        }
    }
    
    // Configure the view.
    let skView = view as! SKView
    skView.isMultipleTouchEnabled = false
    
    // Create and configure the scene.
    scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .aspectFill
    
    // Load the level.
    level = Level(filename: "Level_0")
    scene.level = level
    
    scene.addTiles()
    scene.swipeHandler = handleSwipe
    
    // Present the scene.
    skView.presentScene(scene)
    
    // Start the game.
    beginGame()
  }
  
  
    func setupProgress() {
        progressBorderView.layer.cornerRadius = 5.0
        progressBorderView.layer.borderColor = UIColor.white.cgColor
        progressBorderView.layer.borderWidth = 1.5
        progressBorderView.backgroundColor = .clear
        
    }
    
  // MARK: Game functions
  
  func beginGame() {
    level.score = 0
    updateLabels()
    shuffle()
  }
  
  func shuffle() {
    // Fill up the level with new cookies, and create sprites for them.
    let newCookies = level.shuffle()
    scene.addSprites(for: newCookies)
  }
  
  // This is the swipe handler. MyScene invokes this function whenever it
  // detects that the player performs a swipe.
  func handleSwipe(_ swap: Swap) {
    // While cookies are being matched and new cookies fall down to fill up
    // the holes, we don't want the player to tap on anything.
    view.isUserInteractionEnabled = false
    
    if level.isPossibleSwap(swap) {
      level.performSwap(swap)
      scene.animate(swap: swap, completion: handleMatches)
    } else {
      scene.animateInvalidSwap(swap) {
        self.view.isUserInteractionEnabled = true
      }
    }
  }
  
  func beginNextTurn() {
    level.detectPossibleSwaps()
    view.isUserInteractionEnabled = true
  }
  
  // This is the main loop that removes any matching cookies and fills up the
  // holes with new cookies. While this happens, the user cannot interact with
  // the app.
  func handleMatches() {
    // Detect if there are any matches left.
    let chains = level.removeMatches()

    // If there are no more matches, then the player gets to move again.
    if chains.count == 0 {
      beginNextTurn()
      return
    }
    
    for chain in chains {
        self.score += chain.score
    }
    updateLabels()
    // First, remove any matches...
    scene.animateMatchedCookies(for: chains) {
      
      // ...then shift down any cookies that have a hole below them...
      let columns = self.level.fillHoles()
      self.scene.animateFallingCookiesFor(columns: columns) {
        
        // ...and finally, add new cookies at the top.
        let columns = self.level.topUpCookies()
        self.scene.animateNewCookies(columns) {
          
          // Keep repeating this cycle until there are no more matches.
          self.handleMatches()
        }
      }
    }
  }
    
    func showGameOver() {
        scene.isUserInteractionEnabled = false
        gameOverView.isHidden = false
//        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideGameOver))
//        self.view.addGestureRecognizer(self.tapGestureRecognizer)
    }
    func updateLabels() {
        scoreLabel.text = String(format: "%ld", score)
        progressWidthConstraint.constant = progressLength - CGFloat(score) * (progressLength / 100)
        UIView.animate(withDuration: 0.2) {
            self.progressView.layoutIfNeeded()
        }
    }
  
}
