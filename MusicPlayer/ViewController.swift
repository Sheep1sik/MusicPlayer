//
//  ViewController.swift
//  MusicPlayer
//
//  Created by 양원식 on 2024/01/10.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    // MARK: - Properties
    var musicPlayer: AVAudioPlayer?
    var timer: Timer!
    
    // MARK: - IBOutlets
    @IBOutlet var musicPlay: UIButton!
    @IBOutlet var musicNext: UIButton!
    @IBOutlet var musicBack: UIButton!
    @IBOutlet var musicProgressBar: UISlider!
    // MARK: - Methods
    // MARK: - Custom Method
    func prepareSound() {
        let path = Bundle.main.path(forResource: "Drama.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)

        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.prepareToPlay()
        } catch {
            // couldn't load file :(
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        musicProgressBar.setThumbImage(UIImage(), for: .normal)
        prepareSound()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func touchUpPlayPauseButton(_ sender: UIButton) {
        print("플레이 버튼 터치")
        musicPlayer?.play()
    }
    @IBAction func touchUpNextPauseButton(_ sender: UIButton) {
        print("다음 버튼 터치")
    }
    @IBAction func touchUpBackPauseButton(_ sender: UIButton) {
        print("이전 버튼 터치")
    }
    
    

}

