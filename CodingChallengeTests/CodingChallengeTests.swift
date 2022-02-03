//
//  CodingChallengeTests.swift
//  CodingChallengeTests
//
//  Created by José Jacobo Contreras Trejo on 29/01/22.
//

import XCTest
import CoreData
@testable import CodingChallenge

class CodingChallengeTests: XCTestCase {
        
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
        let text = "some text"
        let date = Date()
        historyViewModel.saveInHistory(text: text, date: date)
        
        let context = connection()
        let fetchRequest : NSFetchRequest<Searched> = Searched.fetchRequest()
        do {
            let history = try context.fetch(fetchRequest)
            var exist = false
            if history.contains(where: { $0.text == text && $0.date == date }) {
                exist = true
            }
            XCTAssertTrue(exist)
        } catch let error as NSError {
            print("Error getting data", error)
        }
    }
    
    func test_delete_searched_text_in_coredata(){
        let historyViewModel = HistoryViewModel()
        historyViewModel.saveInHistory(text: "test text", date: Date())
        historyViewModel.loadData { error in
            XCTAssertNil(error)
            
            //delete last element
            let indexPath = IndexPath(row: historyViewModel.numberOfRows() - 1, section: historyViewModel.numberOfSections() - 1)
            let item = historyViewModel.item(indexPath: indexPath)
            historyViewModel.deleteFromHistory(index: indexPath.row)
            
            let context = self.connection()
            let fetchRequest : NSFetchRequest<Searched> = Searched.fetchRequest()
            do {
                let history = try context.fetch(fetchRequest)
                var exist = true
                if !history.contains(where: { $0.text == item.text && $0.date == item.date }) {
                    exist = false
                }
                XCTAssertFalse(exist)
            } catch let error as NSError {
                print("Error getting data", error)
            }
        }
        
    }

    func test_delete_history_in_coredata(){
        let historyViewModel = HistoryViewModel()
        historyViewModel.deleteAllHistory()
                
        let context = connection()
        let fetchRequest : NSFetchRequest<Searched> = Searched.fetchRequest()
        do {
            let history = try context.fetch(fetchRequest)
            XCTAssertTrue(history == [])
        } catch let error as NSError {
            print("Error getting data", error)
        }
    }
    
    func connection() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
}
