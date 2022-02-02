//
//  HistoryViewModel.swift
//  CodingChallenge
//
//  Created by José Jacobo Contreras Trejo on 31/01/22.
//

import Foundation
import CoreData
import UIKit

class HistoryViewModel {
    
    var history = [Searched]()
    
    func numberOfSections() -> Int {
        
        
//        var dates = history.map { searched in
//            return searched.date
//        }
//        
//        dates = dates.sorted(by: { $0!.compare($1!) == .orderedDescending } )
//        
        //let 
        
        return 1
    }
    
    func numberOfRows() -> Int {
        return history.count
    }
    
    func item(indexPath: IndexPath) -> Searched {
        return history[indexPath.row]
    }
    
    func connection() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    func loadData(completionHandler:  @escaping (Error?) -> (Void)){
        let context = connection()
        let fetchRequest : NSFetchRequest<Searched> = Searched.fetchRequest()        
        do {
            let history = try context.fetch(fetchRequest)
            let sortedHistory = history.sorted(by: { $0.date!.compare($1.date!) == .orderedDescending } )
            self.history = sortedHistory
        } catch let error as NSError {
            print("Error getting data", error)
        }
    }
    
    func saveInHistory(text: String, date: Date) {
        let context = connection()
        let entity = NSEntityDescription.entity(forEntityName: "Searched", in: context)!

        let searched = NSManagedObject(entity: entity, insertInto: context)
        searched.setValue(text, forKeyPath: "text")
        searched.setValue(date, forKeyPath: "date")
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Error saving context\(error), \(error.userInfo)")
        }
    }
    
    func deleteFromHistory(index: Int) {
        let context = connection()
        let fetchRequest : NSFetchRequest<Searched> = Searched.fetchRequest()
        do {
            //self.history = try context.fetch(fetchRequest)
            context.delete(self.history[index])
            try context.save()
        } catch let error as NSError {
            print("Error getting data", error)
        }
    }
    
    func deleteAllHistory(){
        let context = connection()
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Searched")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            try context.save()
            self.history.removeAll()
        } catch let error as NSError {
            print("Error: ", error)
        }
        
    }
    
    
    
    
    
}
