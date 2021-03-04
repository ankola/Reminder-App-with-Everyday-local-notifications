//
//  Extension.swift
//  reminderApp
//
//  Created by Savan Ankola on 03/03/21.
//

import Foundation

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
