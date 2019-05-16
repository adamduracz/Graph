/*
 * The MIT License (MIT)
 *
 * Copyright (C) 2019, CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import XCTest
@testable import Graph

class EntityPropertyTests: XCTestCase, GraphEntityDelegate {
  var saveExpectation: XCTestExpectation?
  
  var propertyInsertExpception: XCTestExpectation?
  var propertyUpdateExpception: XCTestExpectation?
  var propertyDeleteExpception: XCTestExpectation?
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testPropertyInsert() {
    saveExpectation = expectation(description: "[EntityTests Error: Graph save test failed.]")
    propertyInsertExpception = expectation(description: "[EntityTests Error: Property insert test failed.]")
    
    let graph = Graph()
    let watch = Watch<Entity>(graph: graph).where(.exists("P1"))
    watch.delegate = self
    
    let entity = Entity("T")
    entity["P1"] = "V1"
    
    XCTAssertEqual("V1", entity["P1"] as? String)
    
    graph.async { [weak self] (success, error) in
      XCTAssertTrue(success)
      XCTAssertNil(error)
      self?.saveExpectation?.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testPropertyUpdate() {
    saveExpectation = expectation(description: "[EntityTests Error: Graph save test failed.]")
    
    let graph = Graph()
    
    let entity = Entity("T")
    entity["P1"] = "V1"
    
    graph.async { [weak self] (success, error) in
      XCTAssertTrue(success)
      XCTAssertNil(error)
      self?.saveExpectation?.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
    
    saveExpectation = expectation(description: "[EntityTests Error: Graph save test failed.]")
    propertyUpdateExpception = expectation(description: "[EntityTests Error: Property update test failed.]")
    
    let watch = Watch<Entity>(graph: graph).where(.exists("P1"))
    watch.delegate = self
    
    entity["P1"] = "V2"
    
    XCTAssertEqual("V2", entity["P1"] as? String)
    
    graph.async { [weak self] (success, error) in
      XCTAssertTrue(success)
      XCTAssertNil(error)
      self?.saveExpectation?.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testPropertyDelete() {
    saveExpectation = expectation(description: "[EntityTests Error: Graph save test failed.]")
    
    let graph = Graph()
    
    let entity = Entity("T")
    entity["P1"] = "V1"
    
    graph.async { [weak self] (success, error) in
      XCTAssertTrue(success)
      XCTAssertNil(error)
      self?.saveExpectation?.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
    
    saveExpectation = expectation(description: "[EntityTests Error: Graph save test failed.]")
    propertyDeleteExpception = expectation(description: "[EntityTests Error: Property delete test failed.]")
    
    let watch = Watch<Entity>(graph: graph).where(.exists("P1"))
    watch.delegate = self
    
    entity["P1"] = nil
    
    XCTAssertNil(entity["P1"])
    
    graph.async { [weak self] (success, error) in
      XCTAssertTrue(success)
      XCTAssertNil(error)
      self?.saveExpectation?.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func graph(_ graph: Graph, entity: Entity, added property: String, with value: Any, source: GraphSource) {
    XCTAssertTrue("T" == entity.type)
    XCTAssertTrue(0 < entity.id.count)
    
    XCTAssertEqual("P1", property)
    XCTAssertEqual("V1", value as? String)
    XCTAssertEqual(value as? String, entity[property] as? String)
    
    propertyInsertExpception?.fulfill()
  }
  
  func graph(_ graph: Graph, entity: Entity, updated property: String, with value: Any, source: GraphSource) {
    XCTAssertTrue("T" == entity.type)
    XCTAssertTrue(0 < entity.id.count)
    
    XCTAssertEqual("P1", property)
    XCTAssertEqual("V2", value as? String)
    XCTAssertEqual(value as? String, entity[property] as? String)
    
    propertyUpdateExpception?.fulfill()
  }
  
  func graph(_ graph: Graph, entity: Entity, removed property: String, with value: Any, source: GraphSource) {
    XCTAssertTrue("T" == entity.type)
    XCTAssertTrue(0 < entity.id.count)
    
    XCTAssertEqual("P1", property)
    XCTAssertEqual("V1", value as? String)
    XCTAssertNil(entity[property])
    
    propertyDeleteExpception?.fulfill()
  }
}