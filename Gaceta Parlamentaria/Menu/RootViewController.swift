//
//  RootViewController.swift
//  votaciones
//
//  Created by Armando Trujillo on 27/02/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit

class RootViewController: REFrostedViewController {

    override func awakeFromNib() {
        //self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationView"];
        //self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuView"];
        self.contentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NavigationViewController") as! UIViewController
        self.menuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MenuTableViewController") as! UITableViewController
        
    }
    
    func changeContentView(viewController : NavigationViewController) {
        self.contentViewController = viewController
    }
}
