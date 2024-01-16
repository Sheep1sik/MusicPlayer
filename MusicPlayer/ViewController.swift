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
    var musicOnOff = false
    var musicPlayList = ["Drama.mp3", "Spicy.mp3", "ZOOM-ZOOM.mp3"]
    var musicNumber = 0
    
    // MARK: - IBOutlets
    @IBOutlet var musicPlay: UIButton!
    @IBOutlet var musicNext: UIButton!
    @IBOutlet var musicBack: UIButton!
    @IBOutlet var musicProgressBar: UISlider!
    // MARK: - Methods
    // MARK: - Custom Method
    
    // MARK: - 음악 초기화
    private func prepareSound() {
        if let path = Bundle.main.path(forResource: musicPlayList[musicNumber], ofType: nil) {
            let url = URL(fileURLWithPath: path)
            
            do {
                musicPlayer = try AVAudioPlayer(contentsOf: url)
                musicPlayer?.prepareToPlay()
            } catch {
                print("음악 파일을 로드할 수 없습니다.")
            }
        } else {
            print("음악 파일 경로를 찾을 수 없습니다.")
        }
    }

    
    // MARK: - 음악 다음,이전 기능
    private func playListNumberCheck() {
        playListNumberMax()
        playListNumberMin()
        prepareSound()
        musicPlayer?.play()
        musicOnOff = true
    }
    private func playListNumberMax() {
        if musicNumber >= musicPlayList.count { musicNumber = 0 }
    }
    private func playListNumberMin() {
        if musicNumber < 0 { musicNumber = musicPlayList.count - 1 }
    }
    
    // MARK: - 음악 재생 여부 체크
    private func musicPlayCheck() {
        musicOnOff ? musicOff() : musicOn()
    }
    private func musicOff() {
        musicPlayer?.stop()
        musicOnOff = false
    }
    private func musicOn() {
        musicPlayer?.play()
        musicOnOff = true
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSound()
        musicProgressBar.setThumbImage(UIImage(), for: .normal)
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func touchUpPlayPauseButton(_ sender: UIButton) {
        print("플레이 버튼 터치")
        print(musicPlayList.count)
        musicPlayCheck()
    }
    @IBAction func touchUpNextPauseButton(_ sender: UIButton) {
        print("다음 버튼 터치 / 변경 전 musicNumber값 : \(musicNumber)")
        musicNumber += 1
        playListNumberCheck()
        print("다음 버튼 터치 / 변경 후 musicNumber값 : \(musicNumber)")
    }
    @IBAction func touchUpBackPauseButton(_ sender: UIButton) {
        print("이전 버튼 터치/ 변경 전 musicNumber값 : \(musicNumber)")
        musicNumber -= 1
        playListNumberCheck()
        print("이전 버튼 터치/ 변경 후 musicNumber값 : \(musicNumber)")
    }
    
    

}
