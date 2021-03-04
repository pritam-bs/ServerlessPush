//
//  AppStep.swift
//  ServerlessPush
//
//  Created by Pritam on 27/2/21.
//

import RxFlow

enum AppStep: Step {
    case initialization
    case completeInitialization(next: NextToInitialization)
    case welcome
    case completeWelcome
    case home
    case logout
}

enum NextToInitialization {
    case home
    case welcome
}
