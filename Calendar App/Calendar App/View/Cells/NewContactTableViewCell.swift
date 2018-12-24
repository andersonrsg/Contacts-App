//
//  NewContactTableViewCell.swift
//  Calendar App
//
//  Created by Anderson Gralha on 20/12/18.
//  Copyright © 2018 andersongralha. All rights reserved.
//

import UIKit

protocol NewContactTableViewDelegate: class {
    func didFinishFillingData(data: EnumDataField?, value: Any?)
    func didPressRemoveItem(at indexPath: IndexPath)
    func didPressAddItem(at indexPath: IndexPath)
}

class NewContactTableViewCell: BaseTableViewCell {
    
    // MARK: - Properties
    
    lazy var viewModel = NewContactTableViewCellViewModel()
    
    weak var delegate: NewContactTableViewDelegate?
    
    private var birthdayPickerView: UIDatePicker?
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    class var mainInformation: String {
        return "NewContactTableViewCellMainInformation"
    }
    
    class var listInformation: String {
        return "NewContactTableViewCellListInformation"
    }
    
    class var mainInformationSize: CGFloat {
        return 150
    }
    
    class var listInformationSize: CGFloat {
        return 60
    }
    
    // Section separator size
    class var separatorSize: CGFloat {
        return 20
    }
    
    override var indexPath: IndexPath? {
        didSet {
            if let indexPath = indexPath {
                currentDataType = EnumContactDataSection(rawValue: indexPath.section)
                switch indexPath.section {
                case 1:
                    currentDataField = .phone(index: indexPath.row)
                case 2:
                    currentDataField = .email(index: indexPath.row)
                case 3:
                    currentDataField = .address(index: indexPath.row)
                default:
                    break
                }
            }
        }
        
    }
    
    // Used for better management of sections and current data being worked
    var currentDataType: EnumContactDataSection!
    var currentDataField: EnumDataField!
    
    // MARK: - Outlets
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var birthDayTextField: UITextField!
    
    @IBOutlet weak var dataTextField: UITextField!
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupMainInformation(defaultValue: Contact?) {
        super.setup()
        
        guard let contact = defaultValue else {
            return
        }
        
        firstNameTextField.text = contact.firstName
        lastNameTextField.text = contact.lastName
        birthDayTextField.text = contact.dateOfBirth?.formatDateUS()
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        birthDayTextField.delegate = self
        
        setupPicker()
    }
    
    // MARK: - UI
    private func setupPicker() {
        birthdayPickerView = UIDatePicker()
        birthdayPickerView?.datePickerMode = .date
        birthDayTextField.inputView = birthdayPickerView
        birthdayPickerView?.addTarget(self,
                                      action: #selector(pickerDateDidChange),
                                      for: .valueChanged)
        
    }
    
    // MARK: - Actions
    @objc fileprivate func pickerDateDidChange(sender: UIDatePicker?) {
        birthDayTextField.text = sender?.date.formatDateUS()
    }
    
    func setupDefaultValue(value: String) {
        self.dataTextField.text = value
    }
    
    func setupListCell(isLastItem: Bool) {
        super.setup()
        
        guard let indexPath = indexPath else {
            return
        }
        
        dataTextField.delegate = self
        
        // Setup gesture for add and remove icons
        
        if isLastItem {
            dataTextField.addLeftView(image: viewModel.iconAdd)
            (dataTextField.leftView as? UIImageView)?.tintColor = UIColor.green
            
            tapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(addItem(tapGestureRecognizer:)))
            
        } else {
            dataTextField.addLeftView(image: viewModel.iconRemove)
            (dataTextField.leftView as? UIImageView)?.tintColor = UIColor.red
            
            tapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(removeItem(tapGestureRecognizer:)))
            
        }
        dataTextField.leftView?.isUserInteractionEnabled = true
        dataTextField.leftView?.addGestureRecognizer(tapGestureRecognizer)
        
        // Setup current data text field
        dataTextField.placeholder = viewModel.placeHolderList[indexPath.section]
        dataTextField.keyboardType = viewModel.keyboardTypeList[indexPath.section]
        dataTextField.textContentType = viewModel.keyboardContentTypeList[indexPath.section]
    }
    
    @objc func removeItem(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let indexPath = indexPath else {
            return
        }
        // Pauses gesture recognizer action to avoid crashing
        tapGestureRecognizer.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            tapGestureRecognizer.isEnabled = true
        }
        
        self.dataTextField.resignFirstResponder()
        delegate?.didPressRemoveItem(at: indexPath)
        
    }
    
    @objc func addItem(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let indexPath = indexPath else {
            return
        }
        delegate?.didPressAddItem(at: indexPath)
    }
}

extension NewContactTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        guard let text = textField.text, let indexPath = indexPath else {
            return
        }
        
        if text != "" {
            
            if indexPath.section == 0 {
                switch textField.tag {
                case 0:
                    currentDataField = .firstName
                case 1:
                    currentDataField = .lastName
                case 2:
                    currentDataField = .birthday
                    delegate?.didFinishFillingData(data: self.currentDataField, value: birthdayPickerView?.date)
                    return
                default:
                    break
                }
                delegate?.didFinishFillingData(data: self.currentDataField, value: text)
            } else {
                delegate?.didFinishFillingData(data: self.currentDataField, value: text)
            }
            
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        guard let indexPath = indexPath else {
            return
        }
        
        delegate?.didPressAddItem(at: indexPath)
    }
    
}
