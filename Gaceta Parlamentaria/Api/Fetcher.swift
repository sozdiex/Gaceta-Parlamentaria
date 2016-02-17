//
//  Fetcher.swift
//  Gaceta Parlamentaria
//
//  Created by Armando Trujillo on 04/03/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit

//let kAppKey : String = "/prueba"
let kAppKey : String = "/votaciones"
let kAppUrl:String = "http://198.12.150.208"

class Fetcher: NSObject {

    class func setNotification() {
        let localNotification = UILocalNotification()
        localNotification.fireDate = NSDate()
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.applicationIconBadgeNumber = 1
        //localNotification.userInfo = //Cualquier Object (Dic)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    class func validateUsuer(user : String, andPassword pass : String) -> NSDictionary {
        let servicePost : callService = callService()
        servicePost.httpMethod = "POST"
        servicePost.url = kAppUrl + kAppKey + "/api_rest/validarusuario.cfm"
        servicePost.addParamPOSTWithKey("nb_usuario", andValue: user)
        servicePost.addParamPOSTWithKey("cl_contrasena", andValue: pass)
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("token") != nil) {
            let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
            servicePost.addParamPOSTWithKey("token", andValue: token)
        }
        
        
        let dic : NSDictionary = servicePost.callService()
        return dic
    }
    
    
    class func getTitles(date : String) -> NSDictionary {
        let serviceGet : callService = callService()
        serviceGet.httpMethod = "GET"
        serviceGet.url = kAppUrl +  kAppKey + "/api_rest/obtenertemasdocumentos.cfm"
        serviceGet.addParamGETWithKey("fh_sesion", andValue: date)
        let dic : NSDictionary = serviceGet.callService()
        return dic
    }
    
    class func getGacetasAnteriores() -> NSDictionary {
        let serviceGet : callService = callService()
        serviceGet.httpMethod = "GET"
        serviceGet.url = kAppUrl +  kAppKey + "/api_rest/obtenersesiones.cfm"
        let dic: NSDictionary = serviceGet.callService()
        return dic
    }
    
    class func changePassword(user : String, passwordOld passOld : String, andPasswordNew passNew : String) -> NSDictionary {
        let servicePost : callService = callService()
        servicePost.httpMethod = "POST"
        servicePost.url = kAppUrl +  kAppKey + "/api_rest/cambiarcontrasena.cfm"
        servicePost.addParamPOSTWithKey("nb_usuario", andValue: user)
        servicePost.addParamPOSTWithKey("cl_contrasenaVieja", andValue: passOld)
        servicePost.addParamPOSTWithKey("cl_contrasenaNueva", andValue: passNew)
        let dic : NSDictionary = servicePost.callService()
        return dic
    }
    
    class func getDocuments(id_sesion : String, withTema tema : String, orSubTema subTema : String, andDate fecha : String) -> NSDictionary {
        let serviceGet : callService = callService()
        serviceGet.httpMethod = "GET"
        serviceGet.url = kAppUrl +  kAppKey + "/api_rest/obtenerdocstemassubtemas.cfm"
        serviceGet.addParamGETWithKey("id_Sesion", andValue: id_sesion)
        serviceGet.addParamGETWithKey("id_tema", andValue: tema)
        serviceGet.addParamGETWithKey("fh_sesion", andValue: fecha)
        
        if subTema != "" {
            serviceGet.addParamGETWithKey("id_subtema", andValue: subTema)
        }
        
        let dic : NSDictionary = serviceGet.callService()
        return dic
    }
    
    class func registrarAsistencia() -> NSDictionary {
        let servicePost : callService = callService()
        servicePost.httpMethod = "POST"
        servicePost.url = kAppUrl +  kAppKey + "/api_rest/registrarasistenciadiputados.cfm"
        let id_diputado = (NSUserDefaults.standardUserDefaults().objectForKey("id_diputado") as! NSNumber).stringValue
        let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
        servicePost.addParamPOSTWithKey("id_diputado", andValue: id_diputado)
        servicePost.addParamPOSTWithKey("token", andValue:token)
        let dic : NSDictionary = servicePost.callService()
        return dic
    }
    
    class func registrarTokenGrafica() -> NSDictionary {
        let servicePost : callService = callService()
        servicePost.httpMethod = "POST"
        servicePost.url = kAppUrl + kAppKey + "/api_rest/guardarToken.cfm"
        let id_usuario = (NSUserDefaults.standardUserDefaults().objectForKey("id_usuario") as! NSNumber).stringValue
        let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
        servicePost.addParamPOSTWithKey("id_usuario", andValue: id_usuario)
        servicePost.addParamPOSTWithKey("token", andValue:token)
        let dic : NSDictionary = servicePost.callService()
        return dic
    }
    
    class func getDiputadosActivos() -> NSDictionary {
        let serviceGet : callService = callService()
        serviceGet.httpMethod = "GET"
        serviceGet.url = kAppUrl + kAppKey + "/api_rest/obtenerdiputadosactivos.cfm"

        let dic : NSDictionary = serviceGet.callService()
        return dic
    }
    
    class func iniciarVotacion(id_sesion : String, withTema id_tema : String, andSubTema id_subtema : String) -> NSDictionary {
        let servicePost : callService = callService()
        servicePost.httpMethod = "POST"
        servicePost.url = kAppUrl + kAppKey + "/api_rest/iniciarvotacion.cfm"
        servicePost.addParamPOSTWithKey("id_sesion", andValue: id_sesion)
        servicePost.addParamPOSTWithKey("id_tema", andValue: id_tema)
        servicePost.addParamPOSTWithKey("id_subtema", andValue: id_subtema)
        let dic : NSDictionary = servicePost.callService()
        return dic
    }
    
    class func cerrarVotacion(id_sesion : String, withVotacion id_votacion : String) -> NSDictionary {
        let servicePost : callService = callService()
        servicePost.httpMethod = "POST"
        servicePost.url = kAppUrl + kAppKey + "/api_rest/cerrarvotacion.cfm"
        servicePost.addParamPOSTWithKey("id_sesion", andValue: id_sesion)
        servicePost.addParamPOSTWithKey("id_votacion", andValue: id_votacion)
        let dic : NSDictionary = servicePost.callService()
        return dic
    }
    
    class func registrarVoto(id_votacion : String, withSesion id_sesion : String, withUsuario id_usuario : String, andVoto cl_voto : String) -> NSDictionary {
        let servicePost : callService = callService()
        servicePost.httpMethod = "POST"
        servicePost.url = kAppUrl + kAppKey + "/api_rest/registrarvoto.cfm"
        servicePost.addParamPOSTWithKey("id_votacion", andValue: id_votacion)
        servicePost.addParamPOSTWithKey("id_sesion", andValue: id_sesion)
        servicePost.addParamPOSTWithKey("id_usuario", andValue: id_usuario)
        servicePost.addParamPOSTWithKey("cl_voto", andValue: cl_voto)
        let dic : NSDictionary = servicePost.callService()
        return dic
    }
    
    class func obtenerVotacionActual(id_votacion : String, withSesion id_sesion : String) -> NSDictionary {
        let servicePost : callService = callService()
        servicePost.httpMethod = "GET"
        servicePost.url = kAppUrl + kAppKey + "/api_rest/obtenervotacionactual.cfm"
        servicePost.addParamGETWithKey("id_sesion", andValue: id_sesion)
        servicePost.addParamGETWithKey("id_votacion", andValue: id_votacion)
        let dic : NSDictionary = servicePost.callService()
        return dic
    }
    
    class func iniciarSesion(id_sesion : String) -> NSDictionary {
        let servicePost : callService = callService()
        servicePost.httpMethod = "POST"
        servicePost.url = kAppUrl + kAppKey + "/api_rest/iniciarsesion.cfm"
        servicePost.addParamPOSTWithKey("id_sesion", andValue: id_sesion)
        let dic : NSDictionary = servicePost.callService()
        return dic
    }
    
    class func resetServer() -> NSDictionary {
        let servicePost : callService = callService()
        servicePost.httpMethod = "POST"
        servicePost.url = kAppUrl + kAppKey + "/api_rest/eliminardatosprueba.cfm"
        let dic : NSDictionary = servicePost.callService()
        return dic
    }
    
    class func getIpServidor() -> String {
        let servicePost : callService = callService()
        servicePost.httpMethod = "POST"
        servicePost.url = kAppUrl +  kAppKey + "/api_rest/ObtenerRedActual.cfm"
        let dic : NSDictionary = servicePost.callService()
        
        if dic.objectForKey("sn_error") != nil {
            if !(dic.objectForKey("sn_error") as! Bool) {
                return dic.objectForKey("de_ipactual") as! String!
            }
        }
        return ""
    }
    
    class func obtenerResultados(id_votacion : String, withSesion id_sesion : String) -> NSDictionary {
        let servicePost : callService = callService()
        servicePost.httpMethod = "GET"
        servicePost.url = kAppUrl + kAppKey + "/api_rest/ObtenerVotacionesDetalles.cfm"
        servicePost.addParamGETWithKey("id_sesion", andValue: id_sesion)
        servicePost.addParamGETWithKey("id_votacion", andValue: id_votacion)
        let dic : NSDictionary = servicePost.callService()
        return dic
    }
    
    class func activarRegistroAsistencia() -> NSDictionary {
        let servicePost : callService = callService()
        servicePost.httpMethod = "GET"
        servicePost.url = kAppUrl + kAppKey + "/api_rest/permitirasistencia.cfm"
        let dic : NSDictionary = servicePost.callService()
        return dic
    }
    
    class func msgInternet() -> UIAlertView {
        return UIAlertView(title: "Advertencia", message: "No tienes conexion a internet, favor de revisar su conexion y volver a intentar", delegate: nil, cancelButtonTitle: "Aceptar")
    }
    
    class func getUrlPath() -> String {
        return kAppUrl + kAppKey + "/"
    }
}
