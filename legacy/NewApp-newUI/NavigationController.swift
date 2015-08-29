//
//  MyNavigationController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 30.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

class NavigationController: ENSideMenuNavigationController, ENSideMenuDelegate {

    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        sideMenu = ENSideMenu(sourceView: self.view, menuTableViewController: mainStoryboard.instantiateViewControllerWithIdentifier("ProfileView") as! UITableViewController, menuPosition:.Left)
        //sideMenu?.delegate = self //optional
        sideMenu?.menuWidth = self.view.bounds.width * 3 / 4 // optional, default is 160
        //sideMenu?.bouncingEnabled = false
        
        // make navigation bar showing over side menu
        view.bringSubviewToFront(navigationBar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
