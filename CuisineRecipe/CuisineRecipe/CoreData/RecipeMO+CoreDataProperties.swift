//
//  RecipeMO+CoreDataProperties.swift
//  CuisineRecipe
//
//  Created by mac on 5/6/19.
//  Copyright © 2019 sunasterisk. All rights reserved.
//
//

import Foundation
import CoreData

extension RecipeMO {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<RecipeMO> {
        return NSFetchRequest<RecipeMO>(entityName: "Recipe")
    }

    @NSManaged public var id: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var numOfServings: Int32
    @NSManaged public var recipeName: String?
    @NSManaged public var ingredients: NSSet?

}

// MARK: Generated accessors for ingredients
extension RecipeMO {
    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: IngredientMO)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: IngredientMO)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)
    
    static func insertNewRecipe(id: String, recipeName: String, imageUrl: String, numOfServings: Int32) -> RecipeMO? {
        guard let moc = AppDelegate.managedObjectContext else { return nil }
        let recipe = NSEntityDescription.insertNewObject(forEntityName: "Recipe",
                                                               into: moc) as! RecipeMO
        
        recipe.id = id
        recipe.recipeName = recipeName
        recipe.imageUrl = imageUrl
        recipe.numOfServings = numOfServings
        
        do {
            try moc.save()
        } catch {
            let nserror = error as NSError
            print("Cannot insert new recipe. Error is \(nserror) ,\(nserror.userInfo)")
            return nil
        }
        
        print("Insert new recipe successful with name: \(recipe.recipeName ?? "" )")
        return recipe
    }
    
    static func getAllRecipes() -> [RecipeMO] {
        var result: [RecipeMO] = []
        guard let moc = AppDelegate.managedObjectContext else { return result }
        
        do {
            result = try moc.fetch(RecipeMO.fetchRequest()) as! [RecipeMO]
        } catch {
            print("Cannot fetch recipes. Error \(error)")
            return result
        }
        return result
    }
    
    static func recipeExists(recipeId: String?) -> Bool {
        guard let moc = AppDelegate.managedObjectContext else { return false }
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RecipeMO.fetchRequest()
        var subPredicates = [NSPredicate]()
        
        if let recipeId = recipeId {
            let predicate = NSPredicate(format: "id == %@", recipeId)
            subPredicates.append(predicate)
        }
        
        if !subPredicates.isEmpty {
            let compoundPredicates = NSCompoundPredicate.init(type: .and, subpredicates: subPredicates)
            fetchRequest.predicate = compoundPredicates
        }
        
        guard let result = try? moc.fetch(fetchRequest) else { return false }
        guard let resultData = result as? [RecipeMO] else { return false }

        return resultData.isEmpty ? false : true
    }
    
    static func deleteRecipe(recipeId: String) -> Bool {
        guard let moc = AppDelegate.managedObjectContext else { return false }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipe")
        
        request.predicate = NSPredicate(format: "id == %@", recipeId)
        
        guard let result = try? moc.fetch(request) else { return false }
        guard let resultData = result as? [NSManagedObject] else { return false }
            
        for object in resultData {
            moc.delete(object)
        }

        do {
            try moc.save()
        } catch {
            let nserror = error as NSError
            print("Delete all employees unsuccessful. Error is: \(nserror), \(nserror.userInfo)")
            return false
        }
        print("Delete recipe successful")
        return true
    }
}
