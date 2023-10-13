//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Юрий Клеймёнов on 13/10/2023.
//

import Foundation
import XCTest
@testable import MovieQuiz 

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws { // successful index
        // Given
        let array = [1, 1, 2, 3, 5]
        
        // When
        let value = array[safe: 2]
        
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws { // wrong index
        // Given
        let array = [1, 1, 2, 3, 5]
        
        // When
        let value = array[safe: 20]
        
        // Then
        XCTAssertNil(value)
    }
}

