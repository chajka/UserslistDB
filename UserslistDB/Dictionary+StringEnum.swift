//
//  Dictionary+StringEnum.swift
//  UserslistDB
//
//  Created by Чайка on 2018/07/11.
//  Copyright © 2018 Чайка. All rights reserved.
//

import Foundation

public extension Dictionary {
	subscript(enumKey: StringEnum) -> Value? {
		get {
			if let key = enumKey.rawValue as? Key {
				return self[key]
			}// end if let key
			return nil
		}// end computed property get
		set {
			if let key = enumKey.rawValue as? Key {
				self[key] = newValue
			}// end if let
		}// end computed property set
	}// end override subscript
}// end extension Dictionary
