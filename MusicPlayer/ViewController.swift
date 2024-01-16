//
//  ViewController.swift
//  MusicPlayer
//
//  Created by 양원식 on 2024/01/10.
//

import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    // MARK: - Properties
    var musicPlayer: AVAudioPlayer?
    var currentTimer: Timer!
    var remainingTimer: Timer!
    var musicOnOff = false
    var musicPlayList = ["Drama.mp3", "Spicy.mp3", "ZOOM-ZOOM.mp3"]
    var musicNumber = 0
    var totalDuration: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMusic()
        setupTimer()
        musicProgressBar.setThumbImage(UIImage(), for: .normal)
    }
    
    // MARK: - IBOutlets
    @IBOutlet var musicPlay: UIButton!
    @IBOutlet var musicNext: UIButton!
    @IBOutlet var musicBack: UIButton!
    @IBOutlet var musicProgressBar: UISlider!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var remainingTimeLabel: UILabel!
    
    // MARK: - Methods
    // MARK: - Custom Method
    
    // MARK: - 음악 초기화
    private func setMusic() {
        // 음악 파일 경로 설정
        if let path = Bundle.main.path(forResource: musicPlayList[musicNumber], ofType: nil) {
            let url = URL(fileURLWithPath: path)
            
            do {
                // AVAudioPlayer를 사용하여 음악 파일 재생
                musicPlayer = try AVAudioPlayer(contentsOf: url)
                musicPlayer?.prepareToPlay()
                // 총 재생 시간 설정
                totalDuration = musicPlayer?.duration ?? 0
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
        setMusic()
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
    
    // MARK: - 음악 타이머
    func setupTimer() {
    // 타이머를 통해 현재 재생 시간 업데이트
        currentTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
        remainingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRemainingTime), userInfo: nil, repeats: true)
        
        
    }
    
    @objc func updateCurrentTime() {
        if let currentTime = musicPlayer?.currentTime {
        
            // 현재 재생 시간을 분과 초로 변환하여 레이블에 업데이트
            let minutes = Int(currentTime) / 60
            let seconds = Int(currentTime) % 60
            currentTimeLabel?.text = String(format: "%d:%02d", minutes, seconds)
            
        }
    }
    
    @objc func updateRemainingTime() {
        if let currentTime = musicPlayer?.currentTime {
            
            // 남은 시간을 분과 초로 변환하여 레이블에 업데이트
            let remainingTime = totalDuration - currentTime
            let minutes = Int(remainingTime) / 60
            let seconds = Int(remainingTime) % 60
            remainingTimeLabel?.text = String(format: "%d:%02d", minutes, seconds)
            
        }
    }
    
    deinit {
        // 화면이 사라질 때 타이머 해제
        currentTimer?.invalidate()
        remainingTimer?.invalidate()
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
