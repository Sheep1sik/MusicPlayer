//
//  ViewController.swift
//  MusicPlayer
//
//  Created by 양원식 on 2024/01/10.
//

import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController, AVAudioPlayerDelegate{
    
    // MARK: - Properties
    var musicPlayer: AVAudioPlayer?
    var currentTimer: Timer!
    var remainingTimer: Timer!
    var sliderTimer: Timer!
    var musicPlayList = ["Drama.mp3", "Spicy.mp3", "ZOOM-ZOOM.mp3"]
    var musicImageList = ["Drama.jpeg", "Spicy.jpeg", "ZOOM-ZOOM.jpeg"]
    var musicNumber = 0
    var totalDuration: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMusicImage()
        setMusic()
        setupTimer()
        musicProgressBar.setThumbImage(UIImage(), for: .normal)
        setView()
        setSlider()
    }
    
    // MARK: - IBOutlets
    @IBOutlet var musicPlay: UIButton!
    @IBOutlet var musicNext: UIButton!
    @IBOutlet var musicBack: UIButton!
    @IBOutlet var musicProgressBar: UISlider!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var remainingTimeLabel: UILabel!
    @IBOutlet var musicImageView: UIImageView!
    // MARK: - Methods
    // MARK: - Custom Method
    // MARK: - view 화면 초기화
    private func setView() {
        let colors: [CGColor] = [UIColor(red: 1.0, green: 0.7, blue: 0.7, alpha: 1.0).cgColor, UIColor.gray.cgColor, UIColor.black.cgColor]
        let changeColors: [CGColor] = [UIColor.gray.cgColor, UIColor.darkGray.cgColor, UIColor.black.cgColor]
        applyGradientAnimation(to: self.view, colors: colors, changeColors: changeColors, duration: 3.0)
    }
    
    // MARK: - 타이틀 이미지
    private func setMusicImage() {
        let img = UIImage(named: musicImageList[musicNumber])
        musicImageView.image = img
        musicImageView.layer.cornerRadius = CGFloat(5)
        musicImageView.layer.masksToBounds = true
    }
    
    private func setChangeMusicImage() {
        musicImageView.image = UIImage(named: musicImageList[musicNumber])
        musicImageView.layer.cornerRadius = CGFloat(5)
        musicImageView.layer.masksToBounds = true
    }
    
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
        setChangeMusicImage()
        musicPlayer?.play()
    }
    private func playListNumberMax() {
        if musicNumber >= musicPlayList.count { musicNumber = 0 }
    }
    private func playListNumberMin() {
        if musicNumber < 0 { musicNumber = musicPlayList.count - 1 }
    }
    
    // MARK: - 음악 재생 여부 체크
    private func musicOff() {
        self.musicPlayer?.stop()
    }
    private func musicOn() {
        self.musicPlayer?.play()
    }
    
    // MARK: - 음악 타이머
    func setupTimer() {
    // 타이머를 통해 현재 재생 시간 업데이트
        currentTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
        remainingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRemainingTime), userInfo: nil, repeats: true)
        sliderTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateSliderAndLabels), userInfo: nil, repeats: true)
        
    }
    // 현재 재생 시간을 분과 초로 변환하여 레이블에 업데이트
    @objc func updateCurrentTime() {
        if let currentTime = musicPlayer?.currentTime {
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
    
    // MARK: - view 설정
    func applyGradientAnimation(to view: UIView, colors: [CGColor], changeColors: [CGColor], duration: TimeInterval) {
        let gradientLayer: CAGradientLayer
        if let existingGradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer = existingGradientLayer
        } else {
            gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            view.layer.insertSublayer(gradientLayer, at: 0)
        }

        gradientLayer.colors = colors
        gradientLayer.locations = [0.1, 0.3, 0.5]
         

        let colorAnimation = CABasicAnimation(keyPath: "colors")
        colorAnimation.toValue = changeColors
        colorAnimation.duration = duration
        colorAnimation.autoreverses = true
        colorAnimation.repeatCount = .infinity
        gradientLayer.add(colorAnimation, forKey: "colorChangeAnimation")
    }
    
    //MARK: - Slider 설정
    private func setSlider (){
        musicProgressBar.minimumValue = 0.0
        musicProgressBar.maximumValue = Float(musicPlayer?.duration ?? 0.0)
        musicProgressBar.value = 0.0
    }
    
    @objc func updateSliderAndLabels() {
            // Update slider position based on current time
        musicProgressBar.value = Float(musicPlayer?.currentTime ?? 0.0)
        }

    
    
    @IBAction func touchUpPlayPauseButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.isSelected ? musicOn() : musicOff()
    }
    @IBAction func touchUpNextPauseButton(_ sender: UIButton) {
        musicNumber += 1
        playListNumberCheck()
    }
    @IBAction func touchUpBackPauseButton(_ sender: UIButton) {
        musicNumber -= 1
        playListNumberCheck()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        print("slider value changed")
        musicPlayer?.currentTime = TimeInterval(sender.value)
        
    }
}
