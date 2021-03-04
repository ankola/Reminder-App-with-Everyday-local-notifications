//
//  ViewController.swift
//  reminderApp
//
//  Created by Savan Ankola on 03/03/21.
//

import UIKit
import EventKit
import UserNotifications

class ViewController: UIViewController {

    @IBOutlet weak var tblList: UITableView!
    
    var eventStore: EKEventStore!
    var reminders: [EKReminder]!
    var txtDate = UITextField()
    var txtTitle = UITextField()
    var txtDescription = UITextField()
    var datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 216))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if (granted) {
                print("granted swift")
            }else {
                CommonFunctions.shared.showAlertMessage(vc: self, titleStr: "", messageStr: "\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.GetRemindersData()
    }
    
    func GetRemindersData() {
        // 1
        self.eventStore = EKEventStore()
        self.reminders = [EKReminder]()
        self.eventStore.requestAccess(to: .reminder) { (granted, error) in
            
        if granted {
                // 2
            let predicate = self.eventStore.predicateForReminders(in: nil)
            self.eventStore.fetchReminders(matching: predicate, completion: { (reminders: [EKReminder]?) -> Void in

                self.reminders = reminders
                DispatchQueue.main.async {
                    self.tblList.reloadData()
                }
            })
        } else {
            CommonFunctions.shared.showAlertMessage(vc: self, titleStr: "", messageStr: "The app is not permitted to access reminders, make sure to grant permission in the settings and try again")
        }
      }
    }
    
    @objc func txtDateValueChanged() {
        let today = self.datePicker.date
        self.txtDate.text = today.toString(dateFormat: "HH:mm")
    }
    
    //MARK: - ------ UIButton Actions ------------
    @IBAction func TapOnPlusReminderBtn(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Add Reminder", message: "", preferredStyle: .alert)

        alert.addTextField { (textfiled) in
            self.txtTitle = textfiled
            self.txtTitle.autocapitalizationType = .sentences
            textfiled.placeholder = "Enter Title"
        }

        alert.addTextField { (textfiled) in
            self.txtDescription = textfiled
            self.txtDescription.autocapitalizationType = .sentences
            textfiled.placeholder = "Enter Descriptions"
        }

        alert.addTextField { (textfiled) in
            textfiled.placeholder = "Select Time"
            self.txtDate = textfiled
            self.datePicker.datePickerMode = .time
            self.datePicker.preferredDatePickerStyle = .wheels
            self.datePicker.addTarget(self, action: #selector(self.txtDateValueChanged), for: .valueChanged)
            textfiled.inputView = self.datePicker
        }

        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alert) in
            self.saveReminder(remi: nil)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (alert) in

        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - ------ Manage Reminder ------------
    func saveReminder(remi : EKReminder?) {
        
        // 1
        let reminder = (remi != nil) ? remi : EKReminder(eventStore: self.eventStore)
        
        if remi != nil {
            self.removenotifications(remi: remi!)
        }
        
        reminder!.title = self.txtTitle.text ?? ""
        reminder!.notes = self.txtDescription.text ?? ""
        let componentsTwo = Calendar.current.dateComponents([.hour, .minute], from: self.datePicker.date)

        let totalComponents = NSDateComponents()
        totalComponents.year = componentsTwo.year ?? 0
        totalComponents.month = componentsTwo.month ?? 0
        totalComponents.day = componentsTwo.day ?? 0
        totalComponents.hour = componentsTwo.hour ?? 0
        totalComponents.minute = componentsTwo.minute ?? 0
   
        reminder!.dueDateComponents = totalComponents as DateComponents
        reminder!.calendar = self.eventStore.defaultCalendarForNewReminders()
        
        // 2
        do {
            try self.eventStore.save(reminder!, commit: true)
            print("Saved")
            self.GetRemindersData()
            self.SetNotifications(remi: reminder!)
            
        } catch {
            CommonFunctions.shared.showAlertMessage(vc: self, titleStr: "", messageStr: "Error creating and saving new reminder : \(error.localizedDescription)")
        }
    }
    
    @objc func RemoveReminder(sender : UIButton) {
        let reminder: EKReminder = reminders[sender.tag]
           do {
                try eventStore.remove(reminder, commit: true)
                self.reminders.remove(at: sender.tag)
                self.tblList.reloadData()
                self.removenotifications(remi: reminder)
         } catch {
            CommonFunctions.shared.showAlertMessage(vc: self, titleStr: "", messageStr: "An error occurred while removing the reminder from the Calendar database: \(error.localizedDescription)")
         }
    }
    
    @objc func editReminder(sender : UIButton) {
        let alert = UIAlertController(title: "Edit Reminder", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textfiled) in
            self.txtTitle = textfiled
            self.txtTitle.autocapitalizationType = .sentences
        }
        
        alert.addTextField { (textfiled) in
            self.txtDescription = textfiled
            self.txtDescription.autocapitalizationType = .sentences
        }
        
        alert.addTextField { (textfiled) in
            self.txtDate = textfiled
            self.datePicker.datePickerMode = .time
            self.datePicker.preferredDatePickerStyle = .wheels
            self.datePicker.addTarget(self, action: #selector(self.txtDateValueChanged), for: .valueChanged)
            textfiled.inputView = self.datePicker
        }
                
        let reminder: EKReminder = reminders[sender.tag]
        self.txtTitle.text = reminder.title
        self.txtDescription.text = reminder.notes

        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let dueDate = reminder.dueDateComponents?.date{
            self.txtDate.text = formatter.string(from: dueDate)
        } else {
            self.txtDate.placeholder = "Select Time"
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alert) in
            self.saveReminder(remi: reminder)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (alert) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - ------ Manage Notifications ------------
    func SetNotifications(remi : EKReminder) {
        print("button tapped")
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: remi.title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: remi.notes ?? "", arguments: nil)
        
        content.sound = .default
        
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.day, .month, .year, .hour, .minute, .second], from: self.datePicker.date)

        var dateComponent = DateComponents()
        dateComponent.hour = dateComponents.hour
        dateComponent.minute = dateComponents.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        
        // Create the request object.
        let request = UNNotificationRequest(identifier: remi.title, content: content, trigger: trigger)
        
        // Schedule the request.
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    func removenotifications(remi : EKReminder) {
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: [remi.title])
        center.removePendingNotificationRequests(withIdentifiers: [remi.title])
    }
}

//MARK: - ------ UITableView DataSource Methods ------------
extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell : reminderTblCell?

        if cell == nil {
            cell = Bundle.main.loadNibNamed("reminderTblCell", owner: nil, options: nil)?.first as? reminderTblCell
        }

        let reminder:EKReminder! = self.reminders![indexPath.row]
        cell?.lblTitle.text = reminder.title
        cell?.lblDescription.text = reminder.notes ?? ""
        
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let dueDate = reminder.dueDateComponents?.date{
            cell?.lblDate?.text = formatter.string(from: dueDate)
        } else {
            cell?.lblDate?.text = "N/A"
        }
        
        cell?.btnDelete.tag = indexPath.row
        cell?.btnDelete.addTarget(self, action: #selector(self.RemoveReminder(sender:)), for: .touchUpInside)
        
        cell?.btnEdit.tag = indexPath.row
        cell?.btnEdit.addTarget(self, action: #selector(self.editReminder(sender:)), for: .touchUpInside)
        
        return cell!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.reminders.count
    }
}

//MARK: - ------ UNUser Notification Center Delegate ------------
extension ViewController : UNUserNotificationCenterDelegate {
    // UNUserNotificationCenterDelegates
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(notification.request.content.title)
        // Play a sound.
//        completionHandler(UNNotificationPresentationOptions.sound)
        completionHandler([.banner, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.title)
    }
}
