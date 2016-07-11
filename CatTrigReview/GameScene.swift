//
//  GameScene.swift
//  CatTrigReview
//
//  Created by Louis Tur on 7/11/16.
//  Copyright (c) 2016 catthoughts. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
  
  let playerSprite = SKSpriteNode(imageNamed: "Player")
  var playerAcceleration = CGVector(dx: 0, dy: 0)
  var playerVelocity = CGVector(dx: 0, dy: 0)
  let MaxPlayerAcceleration: CGFloat = 400
  let MaxPlayerSpeed: CGFloat = 200
  
  var accelerometerX: UIAccelerationValue = 0
  var accelerometerY: UIAccelerationValue = 0
  var lastUpdateTime: CFTimeInterval = 0

  let motionManager = CMMotionManager()
  
  
  // MARK: - Setup
  override func didMoveToView(view: SKView) {
    size = view.bounds.size
    backgroundColor = SKColor(red: 94.0/255, green: 63.0/255, blue: 107.0/255, alpha: 1)
    
    playerSprite.position = CGPoint(x: size.width - 50, y: 60)
    addChild(playerSprite)
    
    startMonitoringAcceleration()
  }
  
  deinit {
    stopMonitoringAcceleration()
  }
  
  
  // MARK: - Update -
  override func update(currentTime: CFTimeInterval) {
    // to compute velocities we need delta time to multiply by points per second
    // SpriteKit returns the currentTime, delta is computed as last called time - currentTime
    let deltaTime = max(1.0/30, currentTime - lastUpdateTime)
    lastUpdateTime = currentTime
    
    updatePlayerAccelerationFromMotionManager()
    updatePlayer(deltaTime)
  }
  
  func updatePlayer(dt: CFTimeInterval) {
    // mutlipled by dt since the update function gets called 60x per second
    playerVelocity.dx = playerVelocity.dx + playerAcceleration.dx * CGFloat(dt)
    playerVelocity.dy = playerVelocity.dy + playerAcceleration.dy * CGFloat(dt)
    
    // makes sure that the value adjustment is between the -max/max player speed
    playerVelocity.dx = max(-MaxPlayerSpeed, min(MaxPlayerSpeed, playerVelocity.dx))
    playerVelocity.dy = max(-MaxPlayerSpeed, min(MaxPlayerSpeed, playerVelocity.dy))
    
    var newX = playerSprite.position.x + playerVelocity.dx * CGFloat(dt)
    var newY = playerSprite.position.y + playerVelocity.dy * CGFloat(dt)
    newX = min(size.width, max(0, newX));
    newY = min(size.height, max(0, newY));
    
    playerSprite.position = CGPoint(x: newX, y: newY)
  }
  
  
  // MARK: - CoreMotion Helpers
  func startMonitoringAcceleration() {
    if motionManager.accelerometerAvailable {
      motionManager.startAccelerometerUpdates()
      NSLog("accelerometer updates on...")
    }
  }
  
  func stopMonitoringAcceleration() {
    if motionManager.accelerometerAvailable && motionManager.accelerometerActive {
      motionManager.stopAccelerometerUpdates()
      NSLog("accelerometer updates off...")
    }
  }
  
  func updatePlayerAccelerationFromMotionManager() {
    if let acceleration = motionManager.accelerometerData?.acceleration {
      let FilterFactor = 0.75
      
      // adds a low-pass filter to the accelerometer data in order to smooth out the acceleration
      accelerometerX = acceleration.x * FilterFactor + accelerometerX * (1 - FilterFactor)
      accelerometerY = acceleration.y * FilterFactor + accelerometerY * (1 - FilterFactor)
      
      // accelerometer data returns a value from -1 to 1 
      // we swap the x and y accelerometer values since the device will be in landscape
      playerAcceleration.dx = CGFloat(accelerometerY) * -MaxPlayerAcceleration
      playerAcceleration.dy = CGFloat(accelerometerX) * MaxPlayerAcceleration
    }
  }
  
  
  // MARK: - Touches Override
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    /* Called when a touch begins */
    
    for touch in touches {
      let location = touch.locationInNode(self)
      
      let sprite = SKSpriteNode(imageNamed:"Spaceship")
      
      sprite.xScale = 0.5
      sprite.yScale = 0.5
      sprite.position = location
      
      let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
      
      sprite.runAction(SKAction.repeatActionForever(action))
      
      self.addChild(sprite)
    }
  }
  
}
