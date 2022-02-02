//
//  CodingChallengeTests.swift
//  CodingChallengeTests
//
//  Created by José Jacobo Contreras Trejo on 29/01/22.
//

import XCTest
@testable import CodingChallenge

class CodingChallengeTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
//    func test_get_photos_data(){
//        let photoViewModel = PhotosViewModel()
//        let textToFind = "Testing"
//        photoViewModel.loadData(text: textToFind) { error in
//            XCTAssertNil(error)
//        }
//    }
    
    
    func test_get_photo(){
        let photoViewModel = PhotosViewModel()
        let photo = Photo(id: "15466557554", owner: "62865715", secret: "20d54da463", server: "7583", farm: 8, title: "test", isfriend: 0, isfamily: 0)
        photoViewModel.loadImage(photo: photo) { image in

            XCTAssertNotNil(image)
        }
    }
    
    func test_get_photos(){
        let api = ApiManager()
        let textToSearch = "testing"
        api.getPhotosByText(text: textToSearch) { photos, error in
            XCTAssertNil(error)
            XCTAssertNotNil(photos)
        }
    }
    
    func test_save_text_searched(){
        let historyViewModel = HistoryViewModel()
        let searched = "some text"
        let date = Date()
        historyViewModel.save(text: searched, date: date)
    }
    

}
