//
//  AsistenciaViewController.swift
//  votaciones
//
//  Created by Armando Trujillo on 21/02/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit

class AsistenciaViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var collectionView : UICollectionView!
    @IBOutlet var btnReload : UIBarButtonItem!
    
    private var array : NSArray = NSArray()
    private var id_diputado = NSUserDefaults.standardUserDefaults().objectForKey("id_diputado") as! Int
    private var estatus_diputado = false
    private var dicImagePartidos : NSMutableDictionary = NSMutableDictionary()
    private var dicImageUsuarios : NSMutableDictionary = NSMutableDictionary()
    private var isFristReload = true
    private var sn_permitirasistencia = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
       // array = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("lista", ofType: "plist")!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var downloadQueue :dispatch_queue_t = dispatch_queue_create("callListSesion", nil)
        
        var spinner : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.WhiteLarge)
        spinner.color = UIColor.blackColor()
        let viewSpinner : UIView = UIView(frame: CGRectMake(0, 0, 2000, 2000))
        viewSpinner.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin
        
        viewSpinner.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        spinner.center = CGPointMake(viewSpinner.frame.size.width/2.0, viewSpinner.frame.size.height/2.0)
        viewSpinner.addSubview(spinner)
        viewSpinner.center = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0)
        
        self.view.addSubview(viewSpinner)
        spinner.startAnimating()
        
        dispatch_async(downloadQueue, {
            
            let dic = Fetcher.getDiputadosActivos()
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if (dic.objectForKey("sn_permitirasistencia") != nil){
                    self.sn_permitirasistencia = dic.objectForKey("sn_permitirasistencia") as! Bool
                }
                self.actualizarBoton()
                
                if (dic.objectForKey("rs") != nil) {
                    self.array = dic.objectForKey("rs") as! NSArray
                    
                    var arrayLogos = NSMutableArray()
                    var arrayUsuario = NSMutableArray()
                    for item1 in self.array {
                        var isInArray = false
                        for item2 in arrayLogos {
                            if (item2 as! String) == item1.objectForKey("img_partido") as! String {
                                isInArray = true
                            }
                        }
                        if !isInArray {
                            arrayLogos.addObject(item1.objectForKey("img_partido") as! String)
                        }
                        arrayUsuario.addObject(item1.objectForKey("de_imagen") as! String)
                    }
                    
                    self.downloandImagesPartidos(arrayLogos)
                    self.downloandImageUsuarios(arrayUsuario)
                    
                    self.collectionView.reloadData()
                }else {
                    if dic.objectForKey("sn_error") != nil {
                        if dic.objectForKey("sn_error") as! Bool {
                            //UIAlertView(title: "Advertencia", message: dic.objectForKey("mensaje") as? String, delegate: nil, cancelButtonTitle: "Aceptar").show()
                            let AlertView = CustomAlertViewController()
                            AlertView.text = dic.objectForKey("mensaje") as? String
                            self.presentViewController(AlertView, animated: true, completion: nil)
                        }
                    } else {
                        //UIAlertView(title: "Advertencia", message: "No se pudo conectar en este momento con el servidor, vuelva a intentar mas tarde", delegate: nil, cancelButtonTitle: "Aceptar").show()
                        let AlertView = CustomAlertViewController()
                        AlertView.text = "No se pudo conectar en este momento con el servidor, vuelva a intentar mas tarde"
                        self.presentViewController(AlertView, animated: true, completion: nil)
                    }
                }
                
                spinner.stopAnimating()
                viewSpinner.removeFromSuperview()
            })
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - CollectionView - DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("AsistenciaCollectionViewCell", forIndexPath: indexPath) as! AsistenciaCollectionViewCell
        
        var dic = array.objectAtIndex(indexPath.row) as! NSDictionary
        
        cell.imageUsuario.image = UIImage(named: "usuario")
        cell.imagePartido.image = UIImage(named: "icoMenu")

        if dicImageUsuarios.objectForKey(dic.objectForKey("de_imagen") as! String) != nil {
            cell.imageUsuario.image = dicImageUsuarios.objectForKey(dic.objectForKey("de_imagen") as! String) as? UIImage
        } else {
            // poner Spinner
        }
        
        if dicImagePartidos.objectForKey(dic.objectForKey("img_partido") as! String) != nil {
            cell.imagePartido.image = dicImagePartidos.objectForKey(dic.objectForKey("img_partido") as! String) as? UIImage
        } else {
            // poner Spinner
        }
        
        let nombre = ((dic.objectForKey("nb_nombre") as! NSString) as String) + " " + ((dic.objectForKey("nb_apellidopaterno") as! NSString) as String) + " " + ((dic.objectForKey("nb_apellidomaterno") as! NSString) as String)
        
        cell.lblNombre.text = nombre
        
        if dic.objectForKey("id_distrito") as! Int == 0 {
            cell.lblDistrito.text = dic.objectForKey("nb_distrito") as? String
            cell.lblMunicipio.text = dic.objectForKey("nb_municipio") as? String
        } else {
            let numDistrito = (dic.objectForKey("id_distrito") as! NSNumber).stringValue
            cell.lblDistrito.text = "Distrito \(numDistrito) "
            cell.lblMunicipio.text = dic.objectForKey("nb_distrito") as? String
        }
        
        
        if id_diputado == dic.objectForKey("id_diputado") as! Int {
            
            if isFristReload {
                estatus_diputado = dic.objectForKey("sn_asistencia") as! Bool
                isFristReload = false
            }
            
            if estatus_diputado {
                cell.btnAsistencia.hidden = true
                cell.lblAsistencia.hidden = false
                cell.lblAsistencia.text = "Presente"
                cell.lblAsistencia.textColor = Colors.verde()
            } else if !sn_permitirasistencia {
                cell.btnAsistencia.hidden = true
                cell.lblAsistencia.hidden = false
                cell.lblAsistencia.text = "Ausente"
                cell.lblAsistencia.textColor = Colors.rojoNaranja()
            } else {
                cell.btnAsistencia.hidden = false
                cell.lblAsistencia.hidden = true
                
                cell.btnAsistencia.addTarget(self, action: "Asistencia:", forControlEvents: .TouchUpInside)
                
                cell.btnAsistencia.layer.borderWidth = 1
                cell.btnAsistencia.layer.borderColor = UIColor.darkGrayColor().CGColor
                cell.btnAsistencia.layer.cornerRadius = 5
                cell.btnAsistencia.tintColor = UIColor.blackColor()
            }
        } else {
            
            cell.btnAsistencia.hidden = true
            cell.lblAsistencia.hidden = false
            
            if dic.objectForKey("sn_asistencia") as! Bool {
                cell.lblAsistencia.text = "Presente"
                cell.lblAsistencia.textColor = Colors.verde()
            } else {
                cell.lblAsistencia.text = "Ausente"
                cell.lblAsistencia.textColor = Colors.rojoNaranja()
            }
        }
        
        cell.layer.borderWidth = 1
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 370, height: 177)
    }
    
    // MARK : Buttons Actions 
    func Asistencia(sender: UIButton!) {
        var downloadQueue :dispatch_queue_t = dispatch_queue_create("registrarAsistencia", nil)
        
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
            
            let ipServidor = Fetcher.getIpServidor()
            var dic = NSDictionary()
            if ipServidor == SystemServices().wiFiRouterAddress {
                dic = Fetcher.registrarAsistencia()
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                if ipServidor == SystemServices().wiFiRouterAddress {
                    if (dic.objectForKey("sn_error") != nil) {
                        if !(dic.objectForKey("sn_error") as! Bool) {
                            self.estatus_diputado = true
                            NSUserDefaults.standardUserDefaults().setObject(true, forKey: "sn_asistenciahoy")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            self.collectionView.reloadData()
                        } else {
                            //UIAlertView(title: "Advertencia", message: dic.objectForKey("mensaje") as? String, delegate: nil, cancelButtonTitle: "Aceptar").show()
                            let AlertView = CustomAlertViewController()
                            AlertView.text = dic.objectForKey("mensaje") as? String
                            self.presentViewController(AlertView, animated: true, completion: nil)
                            
                        }
                    }else {
                        //UIAlertView(title: "Advertencia", message: "No se pudo conectar en este momento con el servidor, vuelva a intentar mas tarde", delegate: nil, cancelButtonTitle: "Aceptar").show()
                        let AlertView = CustomAlertViewController()
                        AlertView.text = "No se pudo conectar en este momento con el servidor, vuelva a intentar mas tarde"
                        self.presentViewController(AlertView, animated: true, completion: nil)
                    }
                } else {
                    let AlertView = CustomAlertViewController()
                    AlertView.text = "no se encuentra conectado a la red oficial del pleno"
                    self.presentViewController(AlertView, animated: true, completion: nil)
                }
                spinner.stopAnimating()
                viewSpinner.removeFromSuperview()
            })
        })
    }
    //MARK: - IBActions Buttons
    
    @IBAction func touchMenu() {
        frostedViewController.presentMenuViewController()
    }
    
    @IBAction func touchReload(){
        let sn_presidente = NSUserDefaults.standardUserDefaults().objectForKey("admin") as! Bool
        if sn_presidente {
            if !sn_permitirasistencia {

                var downloadQueue :dispatch_queue_t = dispatch_queue_create("callListSesion", nil)
                
                var spinner : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.WhiteLarge)
                spinner.color = UIColor.blackColor()
                let viewSpinner : UIView = UIView(frame: CGRectMake(0, 0, 2000, 2000))
                viewSpinner.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin
                
                viewSpinner.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
                spinner.center = CGPointMake(viewSpinner.frame.size.width/2.0, viewSpinner.frame.size.height/2.0)
                viewSpinner.addSubview(spinner)
                viewSpinner.center = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0)
                
                self.view.addSubview(viewSpinner)
                spinner.startAnimating()
                
                dispatch_async(downloadQueue, {
                    
                    let dic = Fetcher.activarRegistroAsistencia()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        println(dic)
                        if dic.objectForKey("sn_error") != nil {
                            if !(dic.objectForKey("sn_error") as! Bool) {
                                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "sn_iniciada")
                                NSUserDefaults.standardUserDefaults().synchronize()
                                self.viewDidAppear(true)
                            }
                        }
                        
                        spinner.stopAnimating()
                        viewSpinner.removeFromSuperview()
                    })
                })

            } else {
                viewDidAppear(true)
            }
        } else {
            viewDidAppear(true)
        }
    }
    
    //MARK: - Donwlonad Images
    func downloandImagesPartidos(arrayPartidos : NSArray) {
        for item in arrayPartidos {
            if item as! String != ""  {
                var url : NSString = Fetcher.getUrlPath()  + (item as! String)
                url = url.stringByReplacingOccurrencesOfString("..", withString: "")
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    var image : UIImage = UIImage()
                    
                    var imgData = NSData(contentsOfURL: NSURL(string: url as String)!)
                    if imgData != nil {
                        image = UIImage(data: imgData!)!
                    }
                    dispatch_sync(dispatch_get_main_queue(), {
                        if image != UIImage() {
                            self.dicImagePartidos.setObject(image, forKey: item as! String)
                            self.collectionView.reloadData()
                        }
                    })
                })
            }
        }
    }
    
    func downloandImageUsuarios(arrayUsuario : NSArray) {
        for item in arrayUsuario {
            if item as! String != ""  {
                let url = Fetcher.getUrlPath() + (item as! String)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    var image : UIImage = UIImage()
                    
                    var imgData = NSData(contentsOfURL: NSURL(string: url)!)
                    if imgData != nil {
                        image = UIImage(data: imgData!)!
                    }
                    dispatch_sync(dispatch_get_main_queue(), {
                        if image != UIImage() {
                            self.dicImageUsuarios.setObject(image, forKey: item as! String)
                            self.collectionView.reloadData()
                        }
                    })
                })
            }
        }
        
    }
    
    //MARK: - Utils
    func actualizarBoton(){
        let sn_presidente = NSUserDefaults.standardUserDefaults().objectForKey("admin") as! Bool
        if sn_presidente {
            if !sn_permitirasistencia {
                btnReload.title = "Iniciar Asistencia"
            } else {
                btnReload.title = "Recargar"
            }
        } else {
            btnReload.title = "Recargar"
        }
    }
}