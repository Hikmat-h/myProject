//
//  Utils.swift
//  BoomBoom
//
//  Created by Hikmatillo Habibullaev on 9/9/19.
//  Copyright © 2019 Hikmatillo Habibullaev. All rights reserved.
//

import Foundation
import UIKit

//doesn't allow to copy & paste
class CustomUITextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

extension UINavigationItem{
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        
        /*Changing color*/
        backItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.yellow], for: .normal)
        
        self.backBarButtonItem = backItem
    }
    
}

extension UISearchBar {
    
    private func getViewElement<T>(type: T.Type) -> T? {
        
        let svs = subviews.flatMap { $0.subviews }
        guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
        return element
    }
    
    func getSearchBarTextField() -> UITextField? {
        return getViewElement(type: UITextField.self)
    }
    
    func setTextColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            textField.textColor = color
        }
    }
    
    func setTextFieldColor(color: UIColor) {
        
        if let textField = getViewElement(type: UITextField.self) {
            switch searchBarStyle {
            case .minimal:
                textField.layer.backgroundColor = color.cgColor
                textField.layer.cornerRadius = 6
            case .prominent, .default:
                textField.backgroundColor = color
            @unknown default:
                textField.backgroundColor = color
            }
        }
    }
    
    func setPlaceholderTextColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            textField.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSAttributedString.Key.foregroundColor: color])
        }
    }
}


extension CGRect {
    func dividedIntegral(fraction: CGFloat, from fromEdge: CGRectEdge) -> (first: CGRect, second: CGRect) {
        let dimension: CGFloat
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            dimension = self.size.width
        case .minYEdge, .maxYEdge:
            dimension = self.size.height
        }
        
        let distance = (dimension * fraction).rounded(.up)
        var slices = self.divided(atDistance: distance, from: fromEdge)
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            slices.remainder.origin.x += 1
            slices.remainder.size.width -= 1
        case .minYEdge, .maxYEdge:
            slices.remainder.origin.y += 1
            slices.remainder.size.height -= 1
        }
        
        return (first: slices.slice, second: slices.remainder)
    }
}

class Utils {
    static let current = Utils()
    private init(){}
    
    func getStringErrorByCode(code: String) -> String {
        var stringError = ""
        
        switch code {
        case "100":
            stringError = "Пользователь уже зарегистрирован"
        case "101":
            stringError = "Пользователь не найден"
        case "102":
            stringError = "Не правильный код сброса пароля/почта"
        case "104":
            stringError = "Неправильный логин/пароль"
        case "106":
            stringError = "Аккаунт не найден"
        case "107":
            stringError = "Доступ к ребенку уже есть"
        case "200":
            stringError = "Нет доступа к ребенку"
        case "301":
            stringError = "Нет доступа к элементу"
            
        default:
            stringError = code
        }
        
        return stringError
    }
    
    //converts userInfo object into array and sets lable values
    func comuteAge(_ dateBirth:String)->Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let timeSince = Date().timeIntervalSince(formatter.date(from: dateBirth) ?? Date())
        let age = Int(timeSince/31536000)
        return age
    }
    
    func setButtonStyle(btn: UIButton, cornerRadius: Int = 30) -> UIButton {
        btn.layer.borderWidth = 2
        btn.layer.borderColor = #colorLiteral(red: 0.8980392157, green: 0.1019607843, blue: 0.2941176471, alpha: 1)
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = CGFloat(cornerRadius)
        return btn
    }
    
    func setTextFieldStyle(_ textField: UITextField, placeholder: String = "") -> UITextField {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.size.height))
        textField.leftView = paddingView
        textField.clipsToBounds = true
        textField.leftViewMode = UITextField.ViewMode.always
        textField.layer.cornerRadius = 4
        textField.layer.borderWidth = 1
        textField.layer.borderColor = #colorLiteral(red: 0.6274509804, green: 0.6274509804, blue: 0.6274509804, alpha: 1).cgColor
        let lightGray = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
        textField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                              attributes: [NSAttributedString.Key.foregroundColor: lightGray])
        return textField
    }
}
