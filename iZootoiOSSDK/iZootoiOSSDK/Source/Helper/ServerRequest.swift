//
//  ServerRequest.swift
//  ServerRequest
//
//  Created by Amit on 14/09/21.
//

import Foundation

struct Queue<T> {
    var item : [T] = []
    mutating func enqueue(element : T)
    {
        item.append(element)
    }
    mutating func dequeue() -> T?
    
    {
        if(item.isEmpty)
        {
            return nil
        }
        else
        {
            let tempElement = item.first
            item.remove(at: 0)
            return tempElement
        }
    
    }
}
