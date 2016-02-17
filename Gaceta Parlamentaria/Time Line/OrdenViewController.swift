//
//  OrdenViewController.swift
//  votaciones
//
//  Created by Armando Trujillo on 17/02/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit
import Foundation

class OrdenViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView : UITableView!
    @IBOutlet var labelSesion : UILabel!
    @IBOutlet var btnLeft : UIBarButtonItem!
    @IBOutlet var btnIniciarSesion : UIBarButtonItem!
    @IBOutlet var barTitle : UINavigationItem!
    
    private var array : NSMutableArray = NSMutableArray()
    private var currentDicSelected : NSDictionary!
    private var currentTitle : String!
    private var votoActivado = false
    private var id_rowVotoActivado = -1
    private var id_votacion = -1
    private var rowDesactivar = 0
    private var isDesactivar = false
    var nameSesion = ""
    var isFromCalendario = false
    var isReloadButton = false
    
    //MARK: - load
    override func viewDidLoad() {
        self.frostedViewController.presentMenuViewController()
        
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
       
        if NSUserDefaults.standardUserDefaults().objectForKey("id_rowVotoActivado") as! Int >= 0 {
            rowActivada()
        }
        
        tableView.tableHeaderView = ({
            var view = UIView(frame: CGRectMake(0, 0, 2, 195))
            
            var imageView = UIImageView(frame: CGRectMake(0, 0, 500, 190))
            imageView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | .FlexibleRightMargin;
            imageView.image =  UIImage(named: "logo")
            imageView.layer.masksToBounds = true;
            imageView.layer.rasterizationScale = UIScreen.mainScreen().scale;
            imageView.layer.shouldRasterize = true;
            imageView.clipsToBounds = true;
            
            view.addSubview(imageView)
            return view
        })()
        println(NSUserDefaults.standardUserDefaults().objectForKey("admin"))
        
        if NSUserDefaults.standardUserDefaults().objectForKey("admin") as! Int == 0 {
            activarBotonReload()
        }
        
        if isFromCalendario {
            btnLeft.image = UIImage(named: "icoAtras")
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let formater = NSDateFormatter()
            formater.dateFormat = "'Sesión 'dd' de 'MMMM' del 'yyyy"
            var fechaText = formater.stringFromDate(dateFormatter.dateFromString(nameSesion)!)
            self.labelSesion.text = fechaText
            btnIniciarSesion.enabled = false;
            btnIniciarSesion.title =  nil;
            barTitle.title = "Orden Anterior"
        } else {
            btnLeft.image = UIImage(named: "icoMenu")
            let formater = NSDateFormatter()
            formater.dateFormat = "'Sesión 'dd' de 'MMMM' del 'yyyy"
            var fechaText = formater.stringFromDate(NSDate())
            self.labelSesion.text = fechaText
            barTitle.title = "Orden del día"
        }
        NSNotificationCenter.defaultCenter().removeObserver("alertAcceptedOrden")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "alertAcceptedOrden", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "alertAcceptedOrden", name: "alertAcceptedOrden", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reloadInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Helpers
    func rowActivada(){
        votoActivado = true
        id_rowVotoActivado = NSUserDefaults.standardUserDefaults().objectForKey("id_rowVotoActivado") as! Int
        id_votacion = NSUserDefaults.standardUserDefaults().objectForKey("id_votacion") as! Int
    }
    
    func activarBotonReload() {
        btnIniciarSesion.title = "Recargar"
        btnIniciarSesion.enabled = true
        isReloadButton = true
    }
    
    func reloadInfo() {
        var downloadQueue :dispatch_queue_t = dispatch_queue_create("callListSesion", nil)
        
        var spinner : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.WhiteLarge)
        spinner.center = CGPointMake(UIScreen.mainScreen().applicationFrame.size.width/2.0, UIScreen.mainScreen().applicationFrame.size.height/2.0)
        spinner.color = UIColor.blackColor()
        self.view.addSubview(spinner)
        spinner.startAnimating()
        
        dispatch_async(downloadQueue, {
            var dic : NSDictionary = NSDictionary()
            
            if self.isFromCalendario {
                dic = Fetcher.getTitles(self.nameSesion)
            } else {
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                println(dateFormatter.stringFromDate(NSDate()))
                
                dic = Fetcher.getTitles(dateFormatter.stringFromDate(NSDate()))
                //dic = Fetcher.getTitles("2015-03-17")
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if dic.objectForKey("rs_temas") != nil {
                    if NSUserDefaults.standardUserDefaults().objectForKey("admin") as! Int == 1 && dic.objectForKey("sn_iniciada") as! Bool {
                       self.activarBotonReload()
                    }
                    
                    self.adjustArray(dic)
                    self.tableView.dataSource = self
                    self.tableView.delegate = self
                    self.tableView.reloadData()
                } else {
                    self.activarBotonReload()
                   // UIAlertView(title: "Votacion", message: "fallo reload", delegate: nil, cancelButtonTitle: "Aceptar").show()
                    let AlertView = CustomAlertViewController()
                    AlertView.text = "No hay sesión el día de hoy"
                    self.presentViewController(AlertView, animated: true, completion: nil)
                    
                }
                
                spinner.stopAnimating()
            })
        })
    }
    
    func adjustArray(dicService : NSDictionary) {
        array = NSMutableArray()
        
        let arrayTemp : NSArray = dicService.objectForKey("rs_temas") as! NSArray
        
        if !isFromCalendario {
            if dicService.objectForKey("sn_iniciada") != nil {
                NSUserDefaults.standardUserDefaults().setObject(dicService.objectForKey("sn_iniciada"), forKey: "sn_iniciada")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
      
        var id_tema = -1
        
        for  i in  0...arrayTemp.count-1  {
            var dic : NSMutableDictionary = NSMutableDictionary()
            let dicAxu =  arrayTemp.objectAtIndex(i) as! NSDictionary
            
            if id_tema != dicAxu.objectForKey("id_tema") as! Int {
                dic.setValue(dicAxu.objectForKey("nb_tema"), forKey: "tema")
                dic.setValue(dicAxu.objectForKey("nu_docs_tema"), forKey: "num_docs")
                dic.setValue(dicAxu.objectForKey("id_tema"), forKey: "id_tema")
                dic.setValue("cell", forKey: "cell")
                dic.setValue(dicAxu.objectForKey("id_sesion"), forKey: "id_sesion")
                dic.setValue(dicAxu.objectForKey("sn_votacion_tema"), forKey: "sn_votacion")
                dic.setValue(dicAxu.objectForKey("sn_votacioniniciadatema"), forKey: "sn_votacionActivada")
                dic.setValue(dicAxu.objectForKey("sn_votacionterminadatema"), forKey: "sn_votacionDesactivada")

                if dicAxu.objectForKey("id_subtema")?.integerValue > 0 {
                    dic.setValue(true, forKey: "temaBool")
                } else {
                    dic.setValue(false, forKey: "temaBool")
                }
                
                array.addObject(dic)
                id_tema = dicAxu.objectForKey("id_tema") as! Int
            }
            
            if dicAxu.objectForKey("id_subtema")?.integerValue > 0 {
                dic = NSMutableDictionary()
                dic.setValue(dicAxu.objectForKey("nb_subtema"), forKey: "tema")
                dic.setValue(dicAxu.objectForKey("nu_docs_subtema"), forKey: "num_docs")
                dic.setValue(dicAxu.objectForKey("id_tema"), forKey: "id_tema")
                dic.setValue(dicAxu.objectForKey("id_subtema"), forKey: "id_subtema")
                dic.setValue(dicAxu.objectForKey("id_sesion"), forKey: "id_sesion")
                dic.setValue("margenCell", forKey: "cell")
                dic.setValue(false, forKey: "temaBool")
                dic.setValue(dicAxu.objectForKey("sn_votacion_subtema"), forKey: "sn_votacion")
                dic.setValue(dicAxu.objectForKey("sn_votacioniniciadasubtema"), forKey: "sn_votacionActivada")
                dic.setValue(dicAxu.objectForKey("sn_votacionterminadasubtema"), forKey: "sn_votacionDesactivada")
                array.addObject(dic)
            }
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey("admin") as! Int == 1 && array.count == 0{
            btnIniciarSesion.enabled = false;
            btnIniciarSesion.title =  nil;
        }
        
        println(array)
    }
    
    func activarVoto(sender : UIButton){
        votoActivado = true
        id_rowVotoActivado = sender.tag
       
        
        println(sender.tag)
        var dic = array.objectAtIndex(sender.tag) as! NSDictionary
        println(dic)
        
        let id_sesion = (dic.objectForKey("id_sesion") as! NSNumber).stringValue
        let id_tema = (dic.objectForKey("id_tema") as! NSNumber).stringValue
        var id_subtema = ""
        
        if dic.objectForKey("id_subtema") != nil {
            id_subtema = (dic.objectForKey("id_subtema") as! NSNumber).stringValue
        }
        
        var downloadQueue :dispatch_queue_t = dispatch_queue_create("activarVotacion", nil)
        
        var spinner : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.WhiteLarge)
        spinner.color = UIColor.blackColor()
        let viewSpinner : UIView = UIView(frame: CGRectMake(0, 0, 2000, 2000))
        viewSpinner.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin
        
        viewSpinner.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        viewSpinner.center = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0)
        spinner.center = CGPointMake(viewSpinner.frame.size.width/2.0, viewSpinner.frame.size.height/2.0)
        viewSpinner.addSubview(spinner)
        
        self.view.addSubview(viewSpinner)
        spinner.startAnimating()
        
        dispatch_async(downloadQueue, {
            
            let dicReturn = Fetcher.iniciarVotacion(id_sesion, withTema: id_tema, andSubTema: id_subtema)
            
            dispatch_async(dispatch_get_main_queue(), {
                if dicReturn.objectForKey("sn_error") != nil {
                    if !(dicReturn.objectForKey("sn_error") as! Bool) {
                        self.id_votacion = dicReturn.objectForKey("id_votacion") as! Int
                        //UIAlertView(title: "Votacion", message: "El sistema de Votacion se activado", delegate: nil, cancelButtonTitle: "Aceptar")
                        let AlertView = CustomAlertViewController()
                        AlertView.text = "El sistema de Votacion se activado"
                        //self.presentViewController(AlertView, animated: true, completion: nil)
                        
                        self.tableView.reloadData()
                        NSUserDefaults.standardUserDefaults().setObject(self.id_rowVotoActivado, forKey: "id_rowVotoActivado")
                        NSUserDefaults.standardUserDefaults().setObject(self.id_votacion, forKey: "id_votacion")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        println(NSUserDefaults.standardUserDefaults().objectForKey("id_rowVotoActivado"))
                    }
                }
                spinner.stopAnimating()
                viewSpinner.removeFromSuperview()
            })
        })
    }
    
    
    func DesactivarVoto(sender : UIButton){
        let AlertView = CustomAlertViewController()
        AlertView.text = "¿desea desactivar la votación actual?"
        AlertView.alertQuestion = true
        AlertView.Selector = "alertAcceptedOrden"
        rowDesactivar = sender.tag
        isDesactivar = true
        self.presentViewController(AlertView, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pushArchivo" {
            var WebController = segue.destinationViewController as! WebViewController
            var id_sesion = currentDicSelected.objectForKey("id_sesion") as! NSNumber
            WebController.id_Sesion = id_sesion.stringValue
            var id_tema = currentDicSelected.objectForKey("id_tema") as! NSNumber
            WebController.id_tema = id_tema.stringValue
            WebController.dateSesion = nameSesion
            WebController.isOneDocument = true
            WebController.titulo = currentDicSelected.objectForKey("tema") as! String
            
            if currentDicSelected.objectForKey("id_subtema") != nil {
                var id_subTema = currentDicSelected.objectForKey("id_subtema") as! NSNumber
                WebController.id_subTema = id_subTema.stringValue
            } else {
                WebController.id_subTema = ""
            }
            
            //WebController.titulo = currentTitle
            
        } else if segue.identifier == "pushMultiArchivos" {
            var WebController = segue.destinationViewController as! MultipleArchivosViewController
            var id_sesion = currentDicSelected.objectForKey("id_sesion") as! NSNumber
            WebController.id_Sesion = id_sesion.stringValue
            var id_tema = currentDicSelected.objectForKey("id_tema") as! NSNumber
            WebController.id_tema = id_tema.stringValue
            WebController.dateSesion = nameSesion
            WebController.titulo = currentDicSelected.objectForKey("tema") as! String
            
            if currentDicSelected.objectForKey("id_subtema") != nil {
                var id_subTema = currentDicSelected.objectForKey("id_subtema") as! NSNumber
                WebController.id_subTema = id_subTema.stringValue
            } else {
                WebController.id_subTema = ""
            }
        }
    }
    
    @IBAction func unWind (segue: UIStoryboardSegue) {
       println("unWind")
    }
    
    @IBAction func unWindToOrden (segue: UIStoryboardSegue) {
        println("unWind on Orden")
    }
    
    // MARK: - UITableView - DataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var dic = array.objectAtIndex(indexPath.row) as! NSDictionary
        
        var identifierCell = ""
        
        var bandera = true
        if votoActivado {
          bandera = false
            if id_rowVotoActivado == indexPath.row {
                bandera = true
            }
        }
        
        if isFromCalendario {
            bandera = false
        }else if dic.objectForKey("sn_votacionDesactivada") as! Bool {
            bandera = false
        }
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("admin") as! Bool) && (dic.objectForKey("sn_votacion") as! Bool && bandera) {
            identifierCell = dic.objectForKey("cell") as! String + "Admin"
            
            var cell = tableView.dequeueReusableCellWithIdentifier(identifierCell) as! ActivarVotoCell

            cell.boton.tag = indexPath.row
            cell.boton.titleLabel?.numberOfLines = 2
            cell.boton.titleLabel?.textAlignment = NSTextAlignment.Center
            if votoActivado {
                cell.boton.removeTarget(self, action: "activarVoto:", forControlEvents: .TouchUpInside)
                cell.boton.addTarget(self, action: "DesactivarVoto:", forControlEvents: .TouchUpInside)
                cell.boton.setTitle("Desactivar\nVotacion", forState: UIControlState.Normal)
                cell.boton.backgroundColor = UIColor.redColor()
            } else {
                cell.boton.removeTarget(self, action: "DesactivarVoto:", forControlEvents: .TouchUpInside)
                cell.boton.addTarget(self, action: "activarVoto:", forControlEvents: .TouchUpInside)
                cell.boton.setTitle("Activar\nVotacion", forState: UIControlState.Normal)
                cell.boton.backgroundColor = Colors.verdPri()
            }

            
            cell.label.text = dic.objectForKey("tema") as? String
            
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.backgroundColor = UIColor.whiteColor()
            cell.label.textColor = UIColor.blackColor()
            
            if dic.objectForKey("temaBool") as! Bool {
                cell.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(0.5)
                cell.label.textColor = UIColor.whiteColor()
            }
            
            if dic.objectForKey("num_docs") as! Int > 0 {
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.selectionStyle = UITableViewCellSelectionStyle.Blue
            }
            cell.bringSubviewToFront(cell.viewSeperator)
            return cell
        } else {
            identifierCell = dic.objectForKey("cell") as! String
            
            var cell = tableView.dequeueReusableCellWithIdentifier(identifierCell) as! unLabelCell
            
            cell.label.text = dic.objectForKey("tema") as? String
            
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.backgroundColor = UIColor.whiteColor()
            cell.label.textColor = UIColor.blackColor()
            
            if dic.objectForKey("temaBool") as! Bool {
                cell.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(0.5)
                cell.label.textColor = UIColor.whiteColor()
            }
            
            if dic.objectForKey("num_docs") as! Int > 0 {
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.selectionStyle = UITableViewCellSelectionStyle.Blue
            }
            cell.bringSubviewToFront(cell.viewSeperator)
            return cell

        }
    }
    
    // MARK: - UITableView - Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var dic = array.objectAtIndex(indexPath.row) as! NSDictionary
        if dic.objectForKey("num_docs") as! Int > 0 {
            currentDicSelected = dic
            if dic.objectForKey("num_docs") as! Int == 1 {
                self.performSegueWithIdentifier("pushArchivo", sender: self)
            } else {
                self.performSegueWithIdentifier("pushMultiArchivos", sender: self)
            }
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var dic : NSDictionary = array.objectAtIndex(indexPath.row) as! NSDictionary
        var height : CGFloat = 30
       
        var width : CGFloat = 969
        if UIDevice.currentDevice().orientation.isPortrait {
            width = 709
        }
        
        //Si el usuario es Admin
        let BUsuario = NSUserDefaults.standardUserDefaults().objectForKey("admin") as! Bool
        let BVoto = dic.objectForKey("sn_votacion") as! Bool
        let bVotoIniciado = dic.objectForKey("sn_votacionActivada") as! Bool
        
        if  BUsuario && BVoto && !isFromCalendario && bVotoIniciado {
            width -= 92
        }
        
        height += getHeightFrom(dic.objectForKey("tema") as! String, font: UIFont(name: "Arial", size: 19.0)!, width: width)
        return height;
    }
    
    func getHeightFrom(texto : String, font: UIFont, width: CGFloat) -> CGFloat{
        var labelTexto : UILabel = UILabel(frame: CGRectMake(0, 0, width, 9999))
        labelTexto.text = texto
        labelTexto.font = font
        labelTexto.numberOfLines = 0
        labelTexto.sizeToFit()
        return labelTexto.bounds.size.height;
    }
    
    // MARK: - Buttons Actions
    @IBAction func touchMenu() {
        if isFromCalendario {
            self.performSegueWithIdentifier("unWind", sender: self)
        } else {
            
            self.frostedViewController.presentMenuViewController()
            
        }
    }
    
    @IBAction func touchLocalNotification(){
        Fetcher.setNotification()
    }
    
    @IBAction func touchIniciarSesion() {
        if !isReloadButton {
            if NSUserDefaults.standardUserDefaults().objectForKey("admin") as! Int == 1 {
                if array.count > 0 {
                    var dic = array.objectAtIndex(0) as! NSDictionary
                    let id_sesion = (dic.objectForKey("id_sesion") as! NSNumber).stringValue
                    
                    var downloadQueue :dispatch_queue_t = dispatch_queue_create("activarVotacion", nil)
                    var spinner : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.WhiteLarge)
                    spinner.color = UIColor.blackColor()
                    let viewSpinner : UIView = UIView(frame: CGRectMake(0, 0, 2000, 2000))
                    viewSpinner.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin
                    
                    viewSpinner.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
                    viewSpinner.center = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0)
                    spinner.center = CGPointMake(viewSpinner.frame.size.width/2.0, viewSpinner.frame.size.height/2.0)
                    viewSpinner.addSubview(spinner)
                    
                    self.view.addSubview(viewSpinner)
                    spinner.startAnimating()
                    
                    dispatch_async(downloadQueue, {
                        
                        let dicReturn = Fetcher.iniciarSesion(id_sesion) as NSDictionary
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            if dicReturn.objectForKey("sn_error") != nil {
                                if !(dicReturn.objectForKey("sn_error") as! Bool) {
                                    //UIAlertView(title: "Gaceta Parlamentaria", message: dicReturn.objectForKey("mensaje") as? String, delegate: nil, cancelButtonTitle: "Aceptar").show()
                                    let AlertView = CustomAlertViewController()
                                    AlertView.text = dicReturn.objectForKey("mensaje") as? String
                                    self.presentViewController(AlertView, animated: true, completion: nil)
                                    NSUserDefaults.standardUserDefaults().setObject(NSNumber(bool: true), forKey: "sn_iniciada")
                                    NSUserDefaults.standardUserDefaults().synchronize()
                                    self.activarBotonReload()
                                }
                            }
                            spinner.stopAnimating()
                            viewSpinner.removeFromSuperview()
                        })
                    })
                }
            }
        } else {
            reloadInfo()
        }
    }
  
    // MARK: - Curstom Alert
    func alertAcceptedOrden() {
        if isDesactivar {
            isDesactivar = false
            var downloadQueue :dispatch_queue_t = dispatch_queue_create("activarVotacion", nil)
            
            var spinner : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.WhiteLarge)
            spinner.color = UIColor.blackColor()
            let viewSpinner : UIView = UIView(frame: CGRectMake(0, 0, 2000, 2000))
            viewSpinner.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin
            
            viewSpinner.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
            viewSpinner.center = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0)
            spinner.center = CGPointMake(viewSpinner.frame.size.width/2.0, viewSpinner.frame.size.height/2.0)
            viewSpinner.addSubview(spinner)
            
            self.view.addSubview(viewSpinner)
            spinner.startAnimating()
            
            dispatch_async(downloadQueue, {
                
                let dic = self.array.objectAtIndex(self.rowDesactivar) as! NSDictionary
                let id_sesion = (dic.objectForKey("id_sesion") as! NSNumber).stringValue
                let dicReturn = Fetcher.cerrarVotacion(id_sesion, withVotacion: (self.id_votacion as NSNumber).stringValue)
                
                dispatch_async(dispatch_get_main_queue(), {
                    if dicReturn.objectForKey("sn_error") != nil {
                        if !(dicReturn.objectForKey("sn_error") as! Bool) {
                            self.votoActivado = false
                            self.id_rowVotoActivado = -1
                            //UIAlertView(title: "Votacion", message: "El sistema de Votacion se desactivado", delegate: nil, cancelButtonTitle: "Aceptar").show()
                            
                            NSUserDefaults.standardUserDefaults().setObject(NSNumber(int: -1), forKey: "id_rowVotoActivado")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            // self.tableView.reloadData()
                            self.reloadInfo()
                            
                            let AlertView = CustomAlertViewController()
                            AlertView.text = "La votación a sido desactivada"
                            self.presentViewController(AlertView, animated: true, completion: nil)
                            //UIAlertView(title: "Votacion", message: "El sistema de Votacion se desactivado", delegate: nil, cancelButtonTitle: "Aceptar").show()
                        }
                    }
                    spinner.stopAnimating()
                    viewSpinner.removeFromSuperview()
                })
            })
        }
    }
}