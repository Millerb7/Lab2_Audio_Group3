//
//  ViewController.swift
//  AudioLabSwift
//
//  Created by Eric Larson
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import UIKit
import Metal

class ViewController: UIViewController {

    @IBOutlet weak var userView: UIView!
    struct AudioConstants {
        static let AUDIO_BUFFER_SIZE = 1024 * 4
    }
    
    // Setup audio model
    let audio = AudioModel(buffer_size: AudioConstants.AUDIO_BUFFER_SIZE)
    lazy var graph: MetalGraph? = {
        return MetalGraph(userView: self.userView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let graph = self.graph {
            graph.setBackgroundColor(r: 0, g: 0, b: 0, a: 1)
            
            // Add in graphs for display
            // Note that we need to normalize the scale of this graph
            // because the FFT is returned in dB which has very large negative values and some large positive values
            graph.addGraph(withName: "fft",
                           shouldNormalizeForFFT: true,
                           numPointsInGraph: AudioConstants.AUDIO_BUFFER_SIZE / 2)
            
            graph.addGraph(withName: "time",
                           numPointsInGraph: AudioConstants.AUDIO_BUFFER_SIZE)
            
            graph.addGraph(withName: "equalizer",
                shouldNormalizeForFFT: true,
                numPointsInGraph: 20) // Miller
            
            graph.makeGrids() // Add grids to graph
        }
        
        // Start up the audio model here, querying the microphone
        audio.startMicrophoneProcessing(withFps: 20) // Preferred number of FFT calculations per second
        
        self.audio.play()
        
        // Run the loop for updating the graph periodically
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            self.updateGraph()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isBeingDismissed {
            pauseAudio()
        }
    }
    
    // Periodically, update the graph with refreshed FFT Data
    func updateGraph(){
        
        if let graph = self.graph{
            graph.updateGraph(
                data: self.audio.fftData,
                forKey: "fft"
            )
            
            graph.updateGraph(
                data: self.audio.timeData,
                forKey: "time"
            )
            

            graph.updateGraph( //miller
                data: self.audio.eqData,
                forKey: "equalizer"
            )
        }
        
    }
    
    // Function to pause the audio
    func pauseAudio() {
        self.audio.pause()
    }
}
