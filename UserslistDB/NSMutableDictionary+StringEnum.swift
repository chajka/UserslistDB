//
//  NSMutableDictionary+StringEnum.swift
//  UserslistDB
//
//  Created by Чайка on 2018/07/07.
//  Copyright © 2018 Чайка. All rights reserved.
//

import Foundation

public protocol StringEnum {
	var rawValue: String { get }
}

public extension NSMutableDictionary {
	subscript(enumKey: StringEnum) -> Value? {
		get {
			return self.object(forKey: enumKey.rawValue)
		}// end computed property get
		set {
			if let voiceName: String = newValue as? String {
				self.setObject(voiceName, forKey: enumKey.rawValue as NSCopying)
			} else {
				self.removeObject(forKey: enumKey.rawValue as NSCopying)
			}
		}// end computed property set
	}// end override subscript
}// end extension Dictionary
