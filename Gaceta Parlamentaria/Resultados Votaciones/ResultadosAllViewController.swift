//
//  ResultadosAllViewController.swift
//  Gaceta Parlamentaria
//
//  Created by Armando Trujillo Zazueta  on 15/04/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit

class ResultadosAllViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collectionView : UICollectionView!
    private var array : NSArray = NSArray()
    private var dicVotar : NSDictionary!
    private var dicImagePartidos : NSMutableDictionary = NSMutableDictionary()
    private var dicImageUsuarios : NSMutableDictionary = NSMutableDictionary()
    private var indexPath = NSIndexPath(forRow: -12, inSection: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            self.dicVotar = NSUserDefaults.standardUserDefaults().objectForKey("dicVotar") as! NSDictionary
            
            let id_votacion = (self.dicVotar.objectForKey("id_votacion") as! NSNumber).stringValue
            let id_sesion = (self.dicVotar.objectForKey("id_sesion") as! NSNumber).stringValue
          
            //let dic = Fetcher.obtenerResultados("1", withSesion : "12")
            let dic = Fetcher.obtenerResultados(id_votacion, withSesion : id_sesion)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if (dic.objectForKey("rs") != nil) {
                    self.array = dic.objectForKey("rs") as! NSArray
                    
                    var arrayLogos = NSMutableArray()
                    var arrayUsuario = NSMutableArray()
                    for item1 in self.array {
                        var isInArray = false
                        for item2 in arrayLogos {
                            if (item2 as! String) == item1.objectForKey("ar_imagenpartido") as! String {
                                isInArray = true
                            }
                        }
                        if !isInArray {
                            arrayLogos.addObject(item1.objectForKey("ar_imagenpartido") as! String)
                        }
                        arrayUsuario.addObject(item1.objectForKey("ar_imagendiputado") as! String)
                    }
                    
                    self.downloandImagesPartidos(arrayLogos)
                    self.downloandImageUsuarios(arrayUsuario)
                    self.collectionView.dataSource = self
                    self.collectionView.delegate = self
                    self.collectionView.reloadData()
                    let timer = NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: Selector("changePageCollectionView"), userInfo: nil, repeats: false)
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
        
        if dicImageUsuarios.objectForKey(dic.objectForKey("ar_imagendiputado") as! String) != nil {
            cell.imageUsuario.image = dicImageUsuarios.objectForKey(dic.objectForKey("ar_imagendiputado") as! String) as? UIImage
        } else {
            // poner Spinner
        }
        
        if dicImagePartidos.objectForKey(dic.objectForKey("ar_imagenpartido") as! String) != nil {
            cell.imagePartido.image = dicImagePartidos.objectForKey(dic.objectForKey("ar_imagenpartido") as! String) as? UIImage
        } else {
            // poner Spinner
        }
        
        let nombre = ((dic.objectForKey("nb_nombre") as? NSString)! as String) + " " + ((dic.objectForKey("nb_apellidopaterno") as? NSString)! as String) + " " + ((dic.objectForKey("nb_apellidomaterno") as? NSString)! as String)
        
        cell.lblNombre.text = nombre
        
       /* if dic.objectForKey("id_distrito") as Int == 0 {
            cell.lblDistrito.text = dic.objectForKey("cl_voto") as? String
            cell.lblMunicipio.text = dic.objectForKey("nb_municipio") as? String
        } else {
            let numDistrito = (dic.objectForKey("id_distrito") as NSNumber).stringValue
            cell.lblDistrito.text = "Distrito \(numDistrito) "
            cell.lblMunicipio.text = dic.objectForKey("nb_distrito") as? String
        }
        */
        
        cell.lblAsistencia.hidden = false
        let voto = dic.objectForKey("cl_voto") as? Int
        
        if voto == 1 {
            cell.lblAsistencia.text = "A FAVOR"
            cell.lblAsistencia.textColor = Colors.verde()
        } else if voto == 2 {
            cell.lblAsistencia.text = "ENCONTRA"
            cell.lblAsistencia.textColor = Colors.rojoNaranja()
        } else if voto == 3 {
            cell.lblAsistencia.text = "ABSTENCIÓN"
            cell.lblAsistencia.textColor = Colors.amarillo()
        }
        
        cell.layer.borderWidth = 1
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //return CGSize(width: 370, height: 177)
        return CGSize(width: 320, height: 150)
    }
    
    
    //MARK: - Donwlonad Images
    func downloandImagesPartidos(arrayPartidos : NSArray) {
        for item in arrayPartidos {
            if item as! String != ""  {
                var url : NSString = kAppUrl + "/votaciones/" + (item as! String)
                url = url.stringByReplacingOccurrencesOfString("..", withString: "")
                url = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
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
                
                var url = kAppUrl + "/votaciones/" + (item as! String)
                url = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
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
    
    func changePageCollectionView() {
        println("cambiando pagina")
        let row = indexPath.row
        if row + 12 > array.count {
            indexPath = NSIndexPath(forRow: -12, inSection: 0)
           //viewDidAppear(false)
            println("ocultar view ")
            touchTerminar()
            return
        } else {
            indexPath = NSIndexPath(forRow: indexPath.row + 12 , inSection: 0)
        }
    
        collectionView .scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: true)
        let timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("changePageCollectionView"), userInfo: nil, repeats: false)
    }
    
    @IBAction func touchTerminar() {
        if NSUserDefaults.standardUserDefaults().objectForKey("sn_grafica") as! Bool {
            let RootController = self.storyboard?.instantiateViewControllerWithIdentifier("graficaNavigation") as! UINavigationController
            self.presentViewController(RootController, animated: true, completion: nil)
        } else {
            var RootController = self.storyboard?.instantiateViewControllerWithIdentifier("RootViewController") as! RootViewController
            self.presentViewController(RootController, animated: true, completion: nil)
        }
    }
}
