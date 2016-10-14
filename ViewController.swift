//
//  ViewController.swift
//  Player
//
//  Created by zeze on 16/10/13.
//  Copyright © 2016年 zeWill. All rights reserved.
//

import Cocoa
import AVFoundation
import AppKit

struct Song {
    let name: String
    let url: URL
}

 
class ViewController: NSViewController {

     
    @IBOutlet weak var albumImg: NSImageView!
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var titleLabel: NSTextField!
    var player = AVQueuePlayer()
    var timeObserver: AnyObject!
    var playerLayer: AVPlayerLayer!
    var paths: [Song]?
    var playIndex: Int = 0
    
    @IBOutlet weak var currentTimeLabel: NSTextField!
    @IBOutlet weak var maxTimeLabel: NSTextField!
    @IBOutlet weak var slider: NSSlider!
    @IBOutlet weak var pauseBtn: NSButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        playerLayer = AVPlayerLayer()
        self.view.layer?.addSublayer(playerLayer)
    }
    
    deinit{
        player.removeTimeObserver(timeObserver)
    }
}

// MARK: - User play Action
extension ViewController {
    //MARK - Select File path & load mp3 path
    @IBAction func selectFiles(_ sender: AnyObject) {
        let ps = FilesHelper().getMp3URLs()
        if (ps.count) > 0 {
            paths = ps
            
            let items = ps.map{ AVPlayerItem(url: $0.url) }
            player = AVQueuePlayer(items: items)
            self.tableView.reloadData()
        }
        
    }
  
    @IBAction func pauseOrPlay(_ sender: AnyObject) {
        let isPlaying = player.rate > 0
        let btn = sender as! NSButton
        if isPlaying {
            player.pause()
            btn.title = "▶️"
        } else {
            player.play()
            btn.title = "⏸"
        }
    }
 
    
    // Select Previous Song
    @IBAction func selectPrev(_ sender: AnyObject) {
        guard tableView.selectedRow >= 0 else {
            return
        }
        playIndex = playIndex == 0 ? (paths?.count)! - 1 : playIndex - 1
        selectSong(at: playIndex)
    }
    
    // Select Next Song
    @IBAction func selectNext(_ sender: AnyObject) {
        guard tableView.selectedRow >= 0 else {
            return
        }
        playIndex = playIndex == (paths?.count)! - 1 ? 0: playIndex + 1
        selectSong(at: playIndex)
    }
    
    
    private func selectSong(at index: Int) {
        let item = paths?[playIndex]
        
        let indexSet = NSIndexSet(index: playIndex)
        self.tableView.selectRowIndexes(indexSet as IndexSet, byExtendingSelection: false)
        loadPlayer(withSong: item!)
    }
    
    @IBAction func doubleClick(_ sender: AnyObject) {
        guard tableView.selectedRow >= 0 else {
            return
        }
        
        let item = paths?[tableView.selectedRow]
        playIndex = tableView.selectedRow
        print("play index: \(playIndex)")
        
        loadPlayer(withSong: item!)
        
    }
    
    @IBAction func sliderValueChanged(_ sender: AnyObject) {
        print(self.slider.doubleValue)
        
        
        let elapsedTime: Float64 = self.slider.doubleValue
        pauseOrPlay(pauseBtn)
        updateTimeLabel(elapsedTime: elapsedTime)
        player.seek(to: CMTimeMakeWithSeconds(elapsedTime, 100)) { (completed) in
            self.pauseOrPlay(self.pauseBtn)
        }
    }
    
    // MARK: load url & play song
    func loadPlayer(withSong songItem: Song) {
        
        
        let pItem = AVPlayerItem(url: songItem.url)
        player.replaceCurrentItem(with: pItem)
        
        // update ui
        updateSongInfo(song: songItem)
 
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
        timeObserver = player.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main, using: { (elapsedTime) in
            self.observeTime(t: elapsedTime)
        }) as AnyObject!
  
        playerLayer.player = player
        self.pauseOrPlay(pauseBtn)
   
    }
    
    private func observeTime(t: CMTime){
        let duration = CMTimeGetSeconds(player.currentItem!.duration)
        if duration.isFinite{
            let elapsedTime = CMTimeGetSeconds(t)
            updateTimeLabel(elapsedTime: elapsedTime)
        }
    }
 
}

// MARK: - UI
extension ViewController {
    
    func updateSongInfo(song: Song) {
        guard let playItem = player.currentItem else {
             return
        }
        
        // album image
        let metadata = playItem.asset.commonMetadata
        for meta in metadata {
            if meta.commonKey == "artwork" {
                let img = NSImage(data: meta.value as! Data)
                albumImg.image = img
            }
        }
        
        
        let duration:CMTime = playItem.asset.duration
        let seconds: Float64 = CMTimeGetSeconds(duration)
        
        self.slider.maxValue = seconds
        
        titleLabel.stringValue = song.name
        maxTimeLabel.stringValue = String(format: "%02d:%02d", ((lround(seconds) / 60) % 60), lround(seconds) % 60)
    }
    
    
    func updateTimeLabel(elapsedTime elapseTime: Float64) {
        self.slider.doubleValue = elapseTime
        currentTimeLabel.stringValue = String(format: "%02d:%02d", ((lround(elapseTime) / 60) % 60), lround(elapseTime) % 60)
        
    }
}

// MARK: - NSTableViewDelegate, NSTableViewDataSource
extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let p = paths {
            return p.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.make(withIdentifier: "cell", owner: self) as! NSTableCellView
        cell.textField?.stringValue = (paths?[row].name)!
        return cell
    }
}

