//
//  MultipleArchivosViewController.swift
//  Gaceta Parlamentaria
//
//  Created by Armando Trujillo on 27/03/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit

class MultipleArchivosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView : UITableView!
    private var array = NSMutableArray()
    var id_Sesion : String!
    var id_tema : String!
    var id_subTema : String!
    var dateSesion : String!
    var titulo : String!
    
    private var urlDocumento : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadDocuments()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helpers
    func loadDocuments() {
        var downloadQueue :dispatch_queue_t = dispatch_queue_create("callDocuments", nil)
        dispatch_async(downloadQueue, {
            let dic = Fetcher.getDocuments(self.id_Sesion, withTema: self.id_tema, orSubTema: self.id_subTema, andDate: self.dateSesion) as NSDictionary
            dispatch_async(dispatch_get_main_queue(), {
                
                if dic.objectForKey("rs") != nil {
                    self.array = dic.objectForKey("rs") as! NSMutableArray
                    self.tableView.dataSource = self
                    self.tableView.delegate = self
                    self.tableView.reloadData()
                }
            })
        })
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pushDocumentoLista" {
            var WebController = segue.destinationViewController as! WebViewController
            WebController.isOneDocument = false
            WebController.nameFile = urlDocumento
            WebController.titulo = titulo
        }
    }
    
    @IBAction func unWind (segue: UIStoryboardSegue) {
        println("unWind")
    }
    
    // MARK: - TableView DataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        let dic = array.objectAtIndex(indexPath.row) as! NSDictionary
        cell.textLabel?.text = dic.objectForKey("nb_documento") as? String
        return cell
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dicAux = array.objectAtIndex(indexPath.row) as! NSDictionary
        urlDocumento = kAppUrl + "/votaciones" + (dicAux.objectForKey("ar_documento") as! String)
        self.performSegueWithIdentifier("pushDocumentoLista", sender: self)
    }
    
}
