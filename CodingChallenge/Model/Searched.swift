//
//  History.swift
//  CodingChallenge
//
//  Created by José Jacobo Contreras Trejo on 31/01/22.
//

import Foundation
import UIKit
import CoreData

class SearchedModel {
    
    func connection() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    func recoverData() -> [Searched]{
        let context = connection()
        let fetchRequest : NSFetchRequest<Searched> = Searched.fetchRequest()
        var searchedArray = [Searched]()
        
        
        do {
            searchedArray = try context.fetch(fetchRequest)
            return searchedArray
        } catch let error as NSError {
            print("it is not possible to obtain the stored information: ", error)
        }
        
        return searchedArray
    }
    
    func save(text: String, date: Date) {
        let context = connection()
        let entity = NSEntityDescription.entity(forEntityName: "Searched", in: context)!

        let searched = NSManagedObject(entity: entity, insertInto: context)
        searched.setValue(text, forKeyPath: "text")
        searched.setValue(date, forKeyPath: "date")
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Error saving context: \(error), \(error.userInfo)")
        }
    }
}
