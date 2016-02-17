//
//  MenuTableViewController.swift
//  Culiacan
//
//  Created by Armando Trujillo on 08/12/14.
//  Copyright (c) 2014 RedRabbit. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    var selectedMenuItem = NSIndexPath(forRow: 1, inSection: 0)
    
    var arrayMenu : NSMutableArray = [["Asistencia", "Orden del dia"],["Iniciativas","Dictamenes","Decretos","Acuerdos","Puntos de Acuerdo","Leyes","Diario de los Debates","Gacetas Anteriores"],["Cambiar Contraseña" , "Cerrar Sesión"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSUserDefaults.standardUserDefaults().objectForKey("admin") as! Int == 1 {
            arrayMenu  = [["Asistencia", "Orden del dia"],["Iniciativas","Dictamenes","Decretos","Acuerdos","Puntos de Acuerdo","Leyes","Diario de los Debates","Gacetas Anteriores"],["Cambiar Contraseña" , "Cerrar Sesión"]]
            //arrayMenu  = [["Asistencia", "Orden del dia"],["Iniciativas","Dictamenes","Decretos","Acuerdos","Puntos de Acuerdo","Leyes","Diario de los Debates","Gacetas Anteriores"],["Cambiar Contraseña" , "Cerrar Sesión", "Borrar Datos"]]
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "forzarVoto", name:"forzarVoto" , object: nil)
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = Colors.cafe()
        tableView.scrollsToTop = false
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        tableView.selectRowAtIndexPath(selectedMenuItem, animated: false, scrollPosition: .Middle)
        
        tableView.tableHeaderView = ({
            var view = UIView(frame: CGRectMake(0, 0, 0, 190))

            var imageView = UIImageView(frame: CGRectMake(0, 20, 100, 100))
            imageView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | .FlexibleRightMargin
            imageView.image =  UIImage(named: "usuario.jpg")
            
            if NSUserDefaults.standardUserDefaults().objectForKey("imagenUsuario") == nil {
                let urlImagenUsuario = NSUserDefaults.standardUserDefaults().objectForKey("urlImagenUsuario") as? String
                if urlImagenUsuario != "" {
                    var urlString : NSString = kAppUrl + "/votaciones/" + (NSUserDefaults.standardUserDefaults().objectForKey("urlImagenUsuario") as! String)
                    urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                    //url = url.stringByReplacingOccurrencesOfString(" ", withString: "%")
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                        var image : UIImage = UIImage()
                        let url = NSURL(string: urlString as String)!
                        var imgData = NSData(contentsOfURL: url)
                        if imgData != nil {
                            image = UIImage(data: imgData!)!
                        }
                        dispatch_sync(dispatch_get_main_queue(), {
                            if image != UIImage() {
                                NSUserDefaults.standardUserDefaults().setObject(imgData, forKey: "imagenUsuario")
                                imageView.image = image
                                NSUserDefaults.standardUserDefaults().synchronize()
                            }
                        })
                    })
                }
            } else {
                imageView.image = UIImage(data:NSUserDefaults.standardUserDefaults().objectForKey("imagenUsuario") as! NSData)
            }
            
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 50
            imageView.layer.borderColor = UIColor.whiteColor().CGColor
            imageView.layer.borderWidth = 3.0
            imageView.layer.rasterizationScale = UIScreen.mainScreen().scale
            imageView.layer.shouldRasterize = true
            imageView.clipsToBounds = true
            
            var label = UILabel(frame: CGRectMake(0, 120, 250, 70))
            label.numberOfLines = 2
            label.font = UIFont(name: "HelveticaNeue", size: 21);
            label.backgroundColor = UIColor.clearColor();
            label.textColor = UIColor.whiteColor();
            label.text = NSUserDefaults.standardUserDefaults().objectForKey("nom_Usuario") as? String
            label.textAlignment = NSTextAlignment.Center

           // label.sizeToFit();
            label.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleLeftMargin;
            
            
            var labelLinea = UILabel(frame: CGRectMake(0, 189, 320, 0.5))
            labelLinea.backgroundColor = UIColor.whiteColor();
            labelLinea.text = "";
           
            view.addSubview(imageView)
            view.addSubview(label)
            view.addSubview(labelLinea)
            
            return view
        })()
        

    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
        tableView.selectRowAtIndexPath(selectedMenuItem, animated: false, scrollPosition: .Middle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return arrayMenu.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return arrayMenu[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
       
        //cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
        cell!.backgroundColor = Colors.cafe()
        cell?.contentView.backgroundColor = Colors.cafe()
        cell?.contentView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        cell?.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        cell!.textLabel?.textColor = UIColor.whiteColor()
        
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
        selectedBackgroundView.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(0.5)
        cell!.selectedBackgroundView = selectedBackgroundView
        
        cell!.textLabel?.text = arrayMenu.objectAtIndex(indexPath.section).objectAtIndex(indexPath.row) as? String
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 21
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 190, height: 21))
            headerView.backgroundColor = Colors.cafe()
            let label = UILabel(frame: CGRect(x: 10, y: 0, width: 180, height: 21))
            label.text = "Temas de consulta"
            label.textColor = UIColor.whiteColor()
            
            headerView.addSubview(label)
            return headerView
        } else if section == 2 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 190, height: 21))
            headerView.backgroundColor = Colors.cafe()
            let label = UILabel(frame: CGRect(x: 10, y: 0, width: 180, height: 21))
            label.text = "Configuracion"
            label.textColor = UIColor.whiteColor()
            
            headerView.addSubview(label)
            return headerView
        }
        
        return UIView()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        println("did select row: \(indexPath.row)")
        
        if (indexPath == selectedMenuItem) {
            return
        }
        
        
        //Present new view controller
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController : UIViewController!
        
        if selectedMenuItem == NSIndexPath(forRow: 7, inSection: 1){
            NSNotificationCenter.defaultCenter().postNotificationName("changeView", object: nil)
        }
        
        let navigationView  = self.storyboard?.instantiateViewControllerWithIdentifier("NavigationViewController") as! NavigationViewController
        
        if indexPath.section == 0 {
            switch (indexPath.row) {
            case 0:
                destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AsistenciaViewController") as! UIViewController
                break
            case 1:
                destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("OrdenViewController") as! UIViewController
                break
            default:
                return
            }
            
            navigationView.viewControllers = [destViewController]
            
        } else if indexPath.section == 1{
            switch (indexPath.row) {
            case 0:
                let webController = mainStoryboard.instantiateViewControllerWithIdentifier("Web2ViewController") as! Web2ViewController
                webController.pageUrl = "http://www.congresosinaloa.gob.mx/iniciativas/"
                selectedMenuItem = indexPath
                navigationView.viewControllers = [webController]
            case 1:
                let webController = mainStoryboard.instantiateViewControllerWithIdentifier("Web2ViewController") as! Web2ViewController
                webController.pageUrl = "http://www.congresosinaloa.gob.mx/dictamenes/"
                selectedMenuItem = indexPath
                navigationView.viewControllers = [webController]
            case 2:
                let webController = mainStoryboard.instantiateViewControllerWithIdentifier("Web2ViewController") as! Web2ViewController
                webController.pageUrl = "http://www.congresosinaloa.gob.mx/decretos/"
                selectedMenuItem = indexPath
                navigationView.viewControllers = [webController]
            case 3:
                let webController = mainStoryboard.instantiateViewControllerWithIdentifier("Web2ViewController") as! Web2ViewController
                webController.pageUrl = "http://www.congresosinaloa.gob.mx/acuerdos/"
                selectedMenuItem = indexPath
                navigationView.viewControllers = [webController]
            case 4:
                let webController = mainStoryboard.instantiateViewControllerWithIdentifier("Web2ViewController") as! Web2ViewController
                webController.pageUrl = "http://www.congresosinaloa.gob.mx/puntos-de-acuerdo/"
                selectedMenuItem = indexPath
                navigationView.viewControllers = [webController]
            case 5:
                let webController = mainStoryboard.instantiateViewControllerWithIdentifier("Web2ViewController") as! Web2ViewController
                webController.pageUrl = "http://www.congresosinaloa.gob.mx/leyes-estatales/"
                selectedMenuItem = indexPath
                navigationView.viewControllers = [webController]
            case 6:
                let webController = mainStoryboard.instantiateViewControllerWithIdentifier("Web2ViewController") as! Web2ViewController
                webController.pageUrl = "http://www.congresosinaloa.gob.mx/debates/"
                selectedMenuItem = indexPath
                navigationView.viewControllers = [webController]
            case 7:
                destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("CalendarioViewController") as! UIViewController
                navigationView.viewControllers = [destViewController]
                break
                
            default:
                return
            }

        } else if indexPath.section == 2{
            switch (indexPath.row) {
            case 0:
                destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RecuperarContraViewController") as! UIViewController
                navigationView.viewControllers = [destViewController]
                break
            case 1:
                let LoginView = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                self.presentViewController(LoginView, animated: true, completion: nil)
                return
            case 2:
                if NSUserDefaults.standardUserDefaults().objectForKey("admin") as! Int != 1 {
                    return
                }
                
                let dic = Fetcher.resetServer()
                if dic.objectForKey("sn_error") != nil {
                    if dic.objectForKey("sn_error") as! Bool {
                        //UIAlertView(title: "Gaceta Parlamentaria", message: "Ocurrio un error, vuelve a intentar.", delegate: nil, cancelButtonTitle: "Aceptar").show()
                        let AlertView = CustomAlertViewController()
                        AlertView.text = "Ocurrio un error, vuelve a intentar."
                        self.presentViewController(AlertView, animated: true, completion: nil)
                    } else {
                       //UIAlertView(title: "Gaceta Parlamentaria", message: "Los datos del servidor se han borrado", delegate: nil, cancelButtonTitle: "Aceptar").show()
                        let AlertView = CustomAlertViewController()
                        AlertView.text = "Los datos del servidor se han borrado"
                        self.presentViewController(AlertView, animated: true, completion: nil)
                    }
                }
                frostedViewController.hideMenuViewController()
                return
            default:
                return
            }
        }
        
        selectedMenuItem = indexPath
        //sideMenuController()?.setContentViewController(destViewController)
        frostedViewController.contentViewController = navigationView
        frostedViewController.hideMenuViewController()
    }
    
    func forzarVoto(){
        let indexPath =  NSIndexPath(forRow: 0, inSection: 0)
        /*let indexPath =  NSIndexPath(forRow: 0, inSection: 0)
        if (indexPath == selectedMenuItem) {
            return
        }
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("") == nil {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let navigationView  = mainStoryboard.instantiateViewControllerWithIdentifier("NavigationViewController") as NavigationViewController
            let destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AsistenciaViewController") as UIViewController
            navigationView.viewControllers = [destViewController]
            
            selectedMenuItem = indexPath
            frostedViewController.contentViewController = navigationView
            frostedViewController.hideMenuViewController()
        }
        */
        let rowToSelect:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0);  //slecting 0th row with 0th section
        tableView.selectRowAtIndexPath(rowToSelect, animated: true, scrollPosition: UITableViewScrollPosition.None);
        self.tableView(self.tableView, didSelectRowAtIndexPath: rowToSelect);
        
    }
}
