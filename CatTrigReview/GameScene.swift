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
  let BorderCollisionDamping: CGFloat = 0.4
  
  var accelerometerX: UIAccelerationValue = 0
  var accelerometerY: UIAccelerationValue = 0
  var lastUpdateTime: CFTimeInterval = 0

  let motionManager = CMMotionManager()
  static let Pi = CGFloat(M_PI)
  let DegreesToRadians = Pi / 180
  let RadiansToDegrees = 180 / Pi
  
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
    var collidedWithVerticalBorder = false
    var collidedWithHorizontalBorder = false
    
    if newX < 0 {
      newX = 0
      collidedWithVerticalBorder = true
    } else if newX > size.width {
      newX = size.width
      collidedWithVerticalBorder = true
    }
    
    if newY < 0 {
      newY = 0
      collidedWithHorizontalBorder = true
    } else if newY > size.height {
      newY = size.height
      collidedWithHorizontalBorder = true
    }
    
    if collidedWithVerticalBorder {
      playerAcceleration.dx = -playerAcceleration.dx * BorderCollisionDamping
      playerVelocity.dx = -playerVelocity.dx * BorderCollisionDamping
      playerAcceleration.dy = playerAcceleration.dy * BorderCollisionDamping
      playerVelocity.dy = playerVelocity.dy * BorderCollisionDamping
    }
    
    if collidedWithHorizontalBorder {
      playerAcceleration.dx = playerAcceleration.dx * BorderCollisionDamping
      playerVelocity.dx = playerVelocity.dx * BorderCollisionDamping
      playerAcceleration.dy = -playerAcceleration.dy * BorderCollisionDamping
      playerVelocity.dy = -playerVelocity.dy * BorderCollisionDamping
    }
    
    playerSprite.position = CGPoint(x: newX, y: newY)
    
    let RotationThreshold: CGFloat = 40
    
    let speed = sqrt(playerVelocity.dx * playerVelocity.dx + playerVelocity.dy * playerVelocity.dy)
    if speed > RotationThreshold {
      let angle = atan2(playerVelocity.dy, playerVelocity.dx)
      playerSprite.zRotation = angle - 90 * DegreesToRadians
    }    
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
