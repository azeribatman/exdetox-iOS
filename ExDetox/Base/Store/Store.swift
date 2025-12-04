//
//  Store.swift
//  Kabinetim
//
//  Created by Aykhan Safarli on 10.09.25.
//

import Foundation

@MainActor
@Observable
open class Store<State: StoreState> {
    var state: State
    
    init(state: State) {
        self.state = state
    }
}
