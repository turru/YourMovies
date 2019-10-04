//
//  CellTableViewCell.swift
//  YourMovies
//
//  Created by Francisco José Gonzlález Egea on 04/10/2019.
//  Copyright © 2019 Francisco José Gonzlález Egea. All rights reserved.
//

import UIKit

class CellTableViewCell: UITableViewCell {

    @IBOutlet weak var m_titleTitle: UILabel!
    @IBOutlet weak var m_yearTitle: UILabel!
    @IBOutlet weak var m_imageView: UIImageView!
    @IBOutlet weak var m_titleLabel: UILabel!
    @IBOutlet weak var m_year: UILabel!

    public var IdMovie: String? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        m_titleTitle.text = NSLocalizedString("Title", comment: "")
        m_yearTitle.text = NSLocalizedString("Year", comment: "")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
