//
//  DataSource.swift
//  ml_lab4
//
//  Created by ML on 12/9/14.
//  Copyright (c) 2014 ML. All rights reserved.
//

import Foundation

class DataSource<T> {
    
    private var data_ = [T]()
    
    var count: Int {
        get {
            return data_.count
        }
    }
    func save(elem:T) {
        data_.append(elem)
    }
    
    func getAtIndex(index:Int) -> T {
        return data_[index]
    }
}