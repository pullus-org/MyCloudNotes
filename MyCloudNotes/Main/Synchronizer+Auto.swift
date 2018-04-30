import CoreData
import os.log

///
/// Extension to support automatic synchronizations in intervals.
///
extension Synchronizer {
	
	///
	/// Adds an observer to the user defaults for the 'synchronize period' to
	/// control the autosynchronization timer.
	///
	func addObserverForSynchronizePeriod() {
		// Observe 'synchronize period' of user defaults to control timer for automatic synchronization.
		// FIXME: Don't send two notifcations for one event
		UserDefaults.standard.addObserver(self, forKeyPath: UserDefaults.MyCloudNotes.Key.synchronizePeriod, options: [.new], context: nil)
	}
	
	///
	/// Removes the observer of the user defaults for the 'synchronize period'.
	///
	func removeObserverForSynchronizePeriod() {
		UserDefaults.standard.removeObserver(self, forKeyPath: UserDefaults.MyCloudNotes.Key.synchronizePeriod)
	}
	
	///
	/// Updates the timer for automatic synchronization with the values from
	/// the user defaults.
	///
	func synchronizePeriodHasChanged(of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		guard let tag = change?[NSKeyValueChangeKey.newKey] as? NSNumber else { return }
		
		switch tag {
			
		// Don't accept negative intervals. Stop automatic synchronization
		case _ where tag.intValue < 0:
			updateTimer()
			
		// Stop automatic synchronization
		case UserDefaults.MyCloudNotes.Value.manually:
			updateTimer()
			
		// Select standard intervals
		case UserDefaults.MyCloudNotes.Value.everyMinute,
		     UserDefaults.MyCloudNotes.Value.every5Minutes,
		     UserDefaults.MyCloudNotes.Value.every15Minutes,
		     UserDefaults.MyCloudNotes.Value.everyHour:
			updateTimer(interval: tag.doubleValue)
			
		// Allow other intervals. Round min interval to one minute
		default:
			updateTimer(interval: max(tag.doubleValue, UserDefaults.MyCloudNotes.Value.everyMinute.doubleValue))
		}
	}
	
	///
	/// Removes or changes the timer for automatic synchronizations.
	///
	private func updateTimer(interval: TimeInterval? = nil) {
		os_log("Update timer for automatic synchronizations.", type: .info)
		
		guard let interval = interval else {
			if let timer = timer {
				os_log("Stop the timer for automatic synchronizations.", type: .info)
				timer.invalidate()
				self.timer = nil
			} else {
				os_log("Can't stop the timer for automatic synchronizations. The timer is not running.", type: .info)
			}
			return
		}
		
		if let timer = timer {
			if timer.timeInterval == interval {
				os_log("Did not create the timer for automatic synchronization for '%{public}@' seconds. The timer is already running.", type: .info, String(describing: interval))
				return
			} else {
				os_log("Stop the timer for automatic synchronizations.", type: .info)
				timer.invalidate()
			}
		}
		
		os_log("Create the timer for automatic synchronization for '%{public}@' seconds.", type: .info, String(describing: interval))
		
		timer = Timer.scheduledTimer(
			timeInterval: interval,
			target: self, selector: #selector(autoSynchronization),
			userInfo: nil, repeats: true
		)
	}
	
	///
	/// Starts the autosynchronization.
	///
	@objc func autoSynchronization() {
		os_log("Start an automatic synchronization.", type: .info)
		synchronizeNotes()
	}
}
