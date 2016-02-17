//
//  AsistenciaCollectionViewCell.swift
//  votaciones
//
//  Created by Armando Trujillo on 21/02/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit

class AsistenciaCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet weak var imageUsuario: UIImageView!
    @IBOutlet weak var imagePartido: UIImageView!
    
    @IBOutlet weak var lblNombre: UILabel!
    @IBOutlet weak var lblDistrito: UILabel!
    @IBOutlet weak var lblMunicipio: UILabel!
    
    
    @IBOutlet weak var lblAsistencia: UILabel!
    @IBOutlet weak var btnAsistencia: UIButton!
}
