//
//  ViewController.swift
//  MusicPlayer
//
//  Created by 양원식 on 2024/01/10.
//

import UIKit
import AVFoundation
import Foundation

extension UITextView {
    func calculateNumberOfLines() -> Int {
        guard let font = self.font, let text = self.text else {
            return 0
        }
        
        let textContainer = NSTextContainer(size: CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage(string: text, attributes: [NSAttributedString.Key.font: font])
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        var numberOfLines = 0
        var index = 0
        var lineRange = NSRange(location: 0, length: 0)
        
        while index < layoutManager.numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        
        return numberOfLines
    }
}

class ViewController: UIViewController, AVAudioPlayerDelegate{
    
    // MARK: - Properties
    var musicPlayer: AVAudioPlayer?
    var currentTimer: Timer!
    var remainingTimer: Timer!
    var sliderTimer: Timer!
    var lyricsTimer: Timer?
    var musicPlayList = ["Drama.mp3", "Spicy.mp3", "ZOOM-ZOOM.mp3"]
    var musicImageList = ["Drama.jpeg", "Spicy.jpeg", "ZOOM-ZOOM.jpeg"]
    var musicNumber = 0
    var totalDuration: TimeInterval = 0
    var currentLineIndex: Int = 0
    var animator: UIViewPropertyAnimator?
    
    struct Lyric {
        let text: String
        let startTime: TimeInterval
        let endTime: TimeInterval
    }
    // 가사 내용
    var lyrics: [Lyric] = [
        Lyric(text: "Ya Ya I'm the drama", startTime: 0.0, endTime: 12.9),
        Lyric(text: "Ziggy ziggy zag, I'm new", startTime: 13.0, endTime: 14.9),
        Lyric(text: "'Cause I go biggie biggie bad It's true", startTime: 15.0, endTime: 16.9),
        Lyric(text: "날카로운 눈 안에 비친 Toxic", startTime: 17.0, endTime: 18.9),
        Lyric(text: "내 본능을 당겨 Zoom", startTime: 19.0, endTime: 20.5),
        Lyric(text: "Hold up, What? Oh my God", startTime: 20.6, endTime: 22.1),
        Lyric(text: "You say, What? 다쳐 넌", startTime: 22.2, endTime: 24.5),
        Lyric(text: "You better watch out", startTime: 24.6, endTime: 24.9),
        Lyric(text: "우린 이미 거센 Boom", startTime: 25.0, endTime: 26.0),
        Lyric(text: "달려가고 있어 Vroom", startTime: 26.1, endTime: 27.5),
        Lyric(text: "I li-li like me when I roll", startTime: 27.5, endTime: 29.4),
        Lyric(text: "Li-li-like me when I'm savage", startTime: 29.5, endTime: 31.4),
        Lyric(text: "Li-li-like me when I go", startTime: 31.5, endTime: 33.4),
        Lyric(text: "Li-li-likie when I baddest", startTime: 33.5, endTime: 35.5),
        Lyric(text: "Hold up 빛을 따라서", startTime: 35.6, endTime: 36.5),
        Lyric(text: "달아 다 다 달려나가 Run", startTime: 36.6, endTime: 39.5),
        Lyric(text: "Go Finally, Ra ta ta ta", startTime: 39.6, endTime: 40.5),
        Lyric(text: "다음 세계를 열어 난", startTime: 40.6, endTime: 42.5),
        Lyric(text: "1, 2 It's time to go", startTime: 42.6, endTime: 45.5),
        Lyric(text: "후회 없어 난", startTime: 45.6, endTime: 46.5),
        Lyric(text: "맞서 난 깨버렸지", startTime: 46.6, endTime: 49.5),
        Lyric(text: "날 따라서 움직일 Rules", startTime: 49.6, endTime: 50.5),
        Lyric(text: "손끝으로 세상을 두드려 움직여", startTime: 50.6, endTime: 55.5),
        Lyric(text: "Yeah, I'm coming", startTime: 55.6, endTime: 57.5),
        Lyric(text: "I bring, I bring", startTime: 57.6, endTime: 58.5),
        Lyric(text: "all the Drama-ma-ma-ma", startTime: 58.6, endTime: 60.5),
        Lyric(text: "I bring drama-ma-ma-ma", startTime: 60.6, endTime: 62.5),
        Lyric(text: "With my girls in the back", startTime: 62.6, endTime: 64.5),
        Lyric(text: "Girls in the back", startTime: 64.6, endTime: 65.5),
        Lyric(text: "Drama", startTime: 65.6, endTime: 66.5),
        Lyric(text: "Trauma-ma-ma-ma", startTime: 66.6, endTime: 67.5),
        Lyric(text: "I break trauma-ma-ma-ma", startTime: 67.6, endTime: 69.5),
        Lyric(text: "With MY WORLD in the back", startTime: 69.6, endTime: 71.5),
        Lyric(text: "나로 시작되는 Drama", startTime: 71.6, endTime: 73.5),
        Lyric(text: "(All that)", startTime: 73.6, endTime: 74.5),
        Lyric(text: "Drama-ma-ma-ma", startTime: 74.6, endTime: 75.5),
        Lyric(text: "(Bring it that)", startTime: 75.6, endTime: 76.5),
        Lyric(text: "Drama-ma-ma-ma", startTime: 75.6, endTime: 76.5),
        Lyric(text: "With my girls in the back", startTime: 76.6, endTime: 79.5),
        Lyric(text: "Girls in the back, Yeah", startTime: 79.6, endTime: 80.9),
        Lyric(text: "I break", startTime: 81.0, endTime: 81.7),
        Lyric(text: "Trauma-ma-ma-ma", startTime: 81.8, endTime: 82.8),
        Lyric(text: "(We them)", startTime: 82.9, endTime: 83.8),
        Lyric(text: "Trauma-ma-ma-ma", startTime: 83.9, endTime: 84.7),
        Lyric(text: "With MY WORLD in the back", startTime: 84.8, endTime: 86.6),
        Lyric(text: "나로 시작되는 Drama", startTime: 86.7, endTime: 89.0),
        Lyric(text: "Drama-ma-ma-ma", startTime: 89.1, endTime: 91.5),
        Lyric(text: "Drama-ma-ma-ma (3, 2, 1)", startTime: 91.6, endTime: 93.5),
        Lyric(text: "Drama-ma-ma", startTime: 93.6, endTime: 94.5),
        Lyric(text: "You know I've been kind of like", startTime: 94.6, endTime: 96.5),
        Lyric(text: "1, 2, 3 깜짝 놀랄 다음 Scene", startTime: 96.6, endTime: 99.5),
        Lyric(text: "키를 거머쥔", startTime: 99.6, endTime: 101.5),
        Lyric(text: "주인공은 나", startTime: 101.6, endTime: 103.5),
        Lyric(text: "4, 3, 2, Going down ", startTime: 103.6, endTime: 105.5),
        Lyric(text: "쉽게 Through", startTime: 105.6, endTime: 106.5),
        Lyric(text: "Deja vu 같이", startTime: 106.6, endTime: 108.5),
        Lyric(text: "그려지는 이미지", startTime: 108.6, endTime: 110.5),
        Lyric(text: "날 굳이 막지 말아", startTime: 110.6, endTime: 112.5),
        Lyric(text: "이건 내 Drama", startTime: 112.6, endTime: 113.5),
        Lyric(text: "도발은 굳이 안 막아", startTime: 113.6, endTime: 115.5),
        Lyric(text: "Uh, I'm a stunner", startTime: 115.6, endTime: 117.5),
        Lyric(text: "1, 2, It's time to go", startTime: 117.6, endTime: 120.5),
        Lyric(text: "타오르는 날 (타는 날)", startTime: 120.6, endTime: 122.3),
        Lyric(text: "느껴 난 And I love it", startTime: 122.4, endTime: 124.5),
        Lyric(text: "새로워지는 Rules", startTime: 124.6, endTime: 126.3),
        Lyric(text: "난 눈을 떠 (두 눈을 떠)", startTime: 126.4, endTime: 128.4),
        Lyric(text: "시작된 걸 (넌) 알아 (Now)", startTime: 128.5, endTime: 130.5),
        Lyric(text: "It's coming", startTime: 130.6, endTime: 133.1),
        Lyric(text: "I bring, I bring", startTime: 133.2, endTime: 134.3),
        Lyric(text: "all the Drama-ma-ma-ma", startTime: 134.4, endTime: 135.9),
        Lyric(text: "I bring drama-ma-ma-ma", startTime: 136.0, endTime: 137.3),
        Lyric(text: "With my girls in the back", startTime: 137.4, endTime: 139.3),
        Lyric(text: "Girls in the back", startTime: 139.4, endTime: 141.2),
        Lyric(text: "Drama", startTime: 141.3, endTime: 141.9),
        Lyric(text: "Trauma-ma-ma-ma", startTime: 142.0, endTime: 143.3),
        Lyric(text: "I break Trauma-ma-ma-ma", startTime: 143.4, endTime: 145.5),
        Lyric(text: "With MY WORLD in the back", startTime: 145.6, endTime: 146.9),
        Lyric(text: "나로 시작되는 Drama", startTime: 147.0, endTime: 149.3),
        Lyric(text: "Into the REAL WORLD", startTime: 149.4, endTime: 152.9),
        Lyric(text: "다가온 Climax", startTime: 153.0, endTime: 154.6),
        Lyric(text: "두려워하지 마", startTime: 154.7, endTime: 157.7),
        Lyric(text: "You and I", startTime: 157.8, endTime: 161.3),
        Lyric(text: "함께 써 내려가는 Story", startTime: 161.4, endTime: 164.6),
        Lyric(text: "날 가로막았던 No", startTime: 164.7, endTime: 168.3),
        Lyric(text: "한계를 뛰어 넘어 Every day", startTime: 168.4, endTime: 172.3),
        Lyric(text: "Oh Imma make it my way", startTime: 172.4, endTime: 176.4),
        Lyric(text: "Out of the way Yeah", startTime: 176.5, endTime: 180.4),
        Lyric(text: "I bring I bring", startTime: 180.5, endTime: 181.4),
        Lyric(text: "all the Drama-ma-ma-ma", startTime: 181.5, endTime: 183.4),
        Lyric(text: "I bring Drama-ma-ma-ma", startTime: 183.5, endTime: 185.3),
        Lyric(text: "With my girls in the back", startTime: 185.4, endTime: 187.6),
        Lyric(text: "Girls in the back", startTime: 187.7, endTime: 188.5),
        Lyric(text: "Drama", startTime: 188.6, endTime: 189.2),
        Lyric(text: "Trauma-ma-ma-ma", startTime: 189.3, endTime: 190.9),
        Lyric(text: "I break Trauma-ma-ma-ma", startTime: 191.0, endTime: 192.4),
        Lyric(text: "With MY WORLD in the back", startTime: 192.5, endTime: 194.4),
        Lyric(text: "나와 함께하는 Drama", startTime: 194.5, endTime: 196.5),
        Lyric(text: "(All that)", startTime: 196.6, endTime: 197.2),
        Lyric(text: "You know, I'm savage", startTime: 197.3, endTime: 199.3),
        Lyric(text: "거침없는 Baddest", startTime: 199.4, endTime: 201.1),
        Lyric(text: "나를 둘러싼 Thrill", startTime: 201.2, endTime: 202.9),
        Lyric(text: "거친 여정 속의 Drama", startTime: 203.0, endTime: 205.2),
        Lyric(text: "(Drama-ma-ma)", startTime: 205.3, endTime: 206.3),
        Lyric(text: "내가 깨트릴 모든 Trauma", startTime: 206.4, endTime: 208.4),
        Lyric(text: "(Drama-ma-ma)", startTime: 208.5, endTime: 209.3),
        Lyric(text: "지금 시작되는 Drama", startTime: 209.4, endTime: 213.1),
        Lyric(text: "Ya, Ya 너로 시작될 my Drama", startTime: 213.2, endTime: 227.9)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMusicImage()
        setMusic()
        setupTimer()
        musicProgressBar.setThumbImage(UIImage(), for: .normal)
        setView()
        setSlider()
        setupLyricsTextView()
    }
    
    // MARK: - IBOutlets
    @IBOutlet var lyricsTextView: UITextView!
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
        let colors: [CGColor] = [UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0).cgColor, UIColor.gray.cgColor, UIColor.black.cgColor]
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
        selectedChange()
        musicPlayer?.play()
    }
    private func playListNumberMax() {
        if musicNumber >= musicPlayList.count { musicNumber = 0 }
    }
    private func playListNumberMin() {
        if musicNumber < 0 { musicNumber = musicPlayList.count - 1 }
    }
    private func selectedChange(){
        if !musicPlay.isSelected {
            musicPlay.isSelected.toggle()
        }
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
        sliderTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSliderAndLabels), userInfo: nil, repeats: true)
        lyricsTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateLyricsIfNeeded), userInfo: nil, repeats: true)
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
    @objc func updateLyricsIfNeeded() {
        // 노래가 재생 중이 아니라면 가사 업데이트 및 스크롤 처리를 하지 않음
        guard let musicPlayer = self.musicPlayer, musicPlayer.isPlaying else {
            return
        }

        updateLyrics()
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
        gradientLayer.locations = [0.1, 0.3, 0.65]
        
        
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
    
    //MARK: - UITextView 설정
    private func setupLyricsTextView() {
        lyricsTextView.translatesAutoresizingMaskIntoConstraints = false
        lyricsTextView.isEditable = false
        lyricsTextView.isScrollEnabled = true
        view.addSubview(lyricsTextView)
        lyricsTextView.translatesAutoresizingMaskIntoConstraints = false
        lyricsTextView.backgroundColor = UIColor.clear
        
        
    }
    private func updateLyrics() {
        DispatchQueue.main.async {
            // UI 업데이트를 비동기로 수행
            // 현재 재생 시간에 따라 가사 전환
            guard let musicPlayer = self.musicPlayer, musicPlayer.isPlaying else {
                // 노래가 없거나 재생 중이 아닌 경우에는 UI를 업데이트하지 않음
                return
            }

            let currentTime = musicPlayer.currentTime

            // 현재 재생 중인 가사의 인덱스를 찾기
            var currentLyricIndex: Int?

            for (index, lyric) in self.lyrics.enumerated() {
                if currentTime >= lyric.startTime && currentTime <= lyric.endTime {
                    currentLyricIndex = index
                    break
                }
            }

            // 전체 가사를 줄바꿈으로 구분하여 텍스트뷰에 표시
            let allLyrics = self.lyrics.map { $0.text }.joined(separator: "\n")
            self.lyricsTextView.text = allLyrics

            // 현재 재생 중인 가사가 있을 때 강조 표시
            if let currentLyricIndex = currentLyricIndex {
                let currentLyric = self.lyrics[currentLyricIndex]

                // 기존 애니메이터가 있다면 중지
                self.animator?.stopAnimation(true)

                // 애니메이션 설정
                self.animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
                    self.highlightCurrentLyric(lyric: currentLyric)
                }

                // 애니메이션 시작
                self.animator?.startAnimation()
            } else {
                // 현재 재생 중인 가사가 없을 때 모든 가사를 기본 색상으로 표시
                let attributedText = NSMutableAttributedString(string: allLyrics)
                attributedText.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: attributedText.length))
                self.lyricsTextView.attributedText = attributedText
            }

            // 가사 스크롤 처리
            if let index = currentLyricIndex {
                self.scrollLyricsIfNeeded(currentLyricIndex: index)
            }
        }
    }

    private func scrollLyricsIfNeeded(currentLyricIndex: Int) {
        // 현재 텍스트 뷰의 줄 수를 계산
        let totalLines = self.lyricsTextView.calculateNumberOfLines()

        // 현재 재생 중인 가사가 화면에 보이도록 스크롤
        let targetLine = currentLyricIndex + 1 // 1-based index
        let visibleLines = Int(self.lyricsTextView.bounds.height / (self.lyricsTextView.font?.lineHeight ?? 1.0)) // 사용자가 지정한 기본값 1.0

        let maxScrollableLine = max(0, totalLines - visibleLines)
        let scrollPosition = min(maxScrollableLine, max(0, targetLine - visibleLines / 2))

        // 새로운 스크롤 위치 계산
        let offsetY = (self.lyricsTextView.font?.lineHeight ?? 1.0) * CGFloat(scrollPosition)

        // 스크롤 애니메이션
        self.lyricsTextView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
    }



    private func highlightCurrentLyric(lyric: Lyric) {
        guard let text = lyricsTextView.text else {
            return
        }

        // 현재 재생 중인 가사의 범위를 찾기
        guard let range = text.range(of: lyric.text) else {
            return
        }

        let nsRange = NSRange(range, in: text)

        // 전체 가사에 대한 현재 텍스트뷰의 속성 복사
        let attributedText = NSMutableAttributedString(attributedString: lyricsTextView.attributedText ?? NSAttributedString())

        // 전체 가사를 기본 색상으로 설정
        attributedText.addAttribute(.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: attributedText.length))

        // 현재 재생 중인 가사 부분을 흰색으로 강조
        attributedText.addAttribute(.foregroundColor, value: UIColor.white, range: nsRange)

        // 가사 텍스트 업데이트
        lyricsTextView.attributedText = attributedText
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
        musicPlayer?.currentTime = TimeInterval(sender.value)
        
    }
}
