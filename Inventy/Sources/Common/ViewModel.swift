//
//  ViewModel.swift
//  Inventy
//
//  Created by v.ternovskyi on 7/24/19.
//  Copyright © 2019 inventy. All rights reserved.
//

class ViewModel<Input, Output> {
    
    public let input: Input
    public let output: Output
    
    public init(_ input: Input, _ output: Output) {
        self.input = input
        self.output = output
    }
}
