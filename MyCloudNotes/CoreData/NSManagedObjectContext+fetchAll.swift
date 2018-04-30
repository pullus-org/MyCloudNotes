import CoreData
import os.log

extension NSManagedObjectContext {
	
	///
	/// Fetches all entities of a class from this context.
	///
	public func fetchAll<Entity: NSManagedObject>(_ entityType: Entity.Type) -> [Entity]? {
		do {
			return try fetch(NSFetchRequest<Entity>(entityName: entityType.className()))
		} catch {
			os_log("Can't fetch all entities of class '%{public}@'.", type: .error, entityType.className())
			return nil
		}
	}
}
