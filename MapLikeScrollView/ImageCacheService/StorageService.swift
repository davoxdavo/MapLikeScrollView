//
//  StorageService.swift
//  XAIApp
//
//  Created by Davit Ghushchyan on 27.01.23.
//

import Foundation
import CoreData

class StorageService {
    static var STORAGENAME = "ImageCacheStorage"
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    private var persistentController = PersistentController(containerName: StorageService.STORAGENAME)
    
    // MARK: - Public
    
    func saveModelFor<T:Codable>(key:String, model: T) {
        let data = try? encoder.encode(model)
        if let object = getFromDB(key: getKeyFor(key)) {
            object.data = data
        } else {
            let context = persistentController.viewContext
            let object = StoredModel(context: context)
            object.key = getKeyFor(key)
            object.data = data
        }
        persistentController.saveViewContext()
    }
    
    func getModelFor<T: Codable>(key: String) -> T? {
        guard let object = getFromDB(key: getKeyFor(key)) else {
            return nil
        }
        if  object.data != nil {
            guard let model = try? decoder.decode(T.self, from: object.data!) else {
                return nil
            }
            return model
        }
        return nil
    }
    
    func eraseDB(force: Bool = false) {
        if force {
            persistentController.eraseEntity(.storedModel)
            return
        }
        let context = persistentController.viewContext
        let request: NSFetchRequest<StoredModel> = StoredModel.fetchRequest()
        
        let data = try? context.fetch(request)
        
        for item in data ?? [] {
            context.delete(item)
        }
        persistentController.saveContext(context)
    }
    
    // MARK: - Public
    
    private func getFromDB(key: String) -> StoredModel? {
        let context = persistentController.viewContext
        let request: NSFetchRequest<StoredModel> = StoredModel.fetchRequest()
        
        request.predicate = NSPredicate(format: "key ==[cd] %@", key)
        let object = try? context.fetch(request)
        return object?.first
    }
    
    private func getKeyFor(_ key: String) -> String {
        key
    }
}
