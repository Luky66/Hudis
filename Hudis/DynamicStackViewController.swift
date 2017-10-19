//
//  DynamicStackViewController.swift
//  Hudis
//
//  Created by Lukas Bühler on 19.10.17.
//  Copyright © 2017 Lukas Bühler. All rights reserved.
//

import UIKit

class DynamicStackViewController: UIViewController {
    
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var stackView: UIStackView!
    
    // Method implementations will go here...
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup scrollview
        let insets = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
    }
}
