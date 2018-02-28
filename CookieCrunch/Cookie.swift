//
//  Cookie.swift
//  CookieCrunch
//
//  Created by Razeware on 13/04/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import SpriteKit

// MARK: - CookieType
var numberCookies = 0

enum CookieType: Int, CustomStringConvertible {
  case unknown = 0, clubLogo, greenBacterium, redBacterium, yellowBacterium, purpleBacterium
  var spriteName: String {
    let spriteNames = [
      "clubLogo",
      "greenBacterium",
      "redBacterium",
      "yellowBacterium",
      "purpleBacterium"]
    
    return spriteNames[rawValue - 1]
  }
  
  var description: String {
    return spriteName
  }
  
  static func random() -> CookieType {
    numberCookies += 1
    if numberCookies % 3 == 0 {
        return CookieType.clubLogo
    } else {
        return CookieType(rawValue: Int(arc4random_uniform(5)) + 1)!
    }
  }
}


// MARK: - Cookie

func ==(lhs: Cookie, rhs: Cookie) -> Bool {
  return lhs.column == rhs.column && lhs.row == rhs.row
}

class Cookie: CustomStringConvertible, Hashable {
  
  var column: Int
  var row: Int
  let cookieType: CookieType
  var sprite: SKSpriteNode?
  
  init(column: Int, row: Int, cookieType: CookieType) {
    self.column = column
    self.row = row
    self.cookieType = cookieType
  }
  
  var description: String {
    return "type:\(cookieType) square:(\(column),\(row))"
  }
  
  var hashValue: Int {
    return row * 10 + column
  }
  
}
