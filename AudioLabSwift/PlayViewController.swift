import UIKit
import Metal



class PlayViewController: UIViewController {

    @IBOutlet weak var userView: UIView!
    struct AudioConstants {
        static let AUDIO_BUFFER_SIZE = 1024 * 4
    }
    
    let audio = AudioModel(buffer_size: AudioConstants.AUDIO_BUFFER_SIZE)
    
    @IBOutlet weak var volumeLabel: UILabel!
    
    lazy var graph: MetalGraph? = {
        return MetalGraph(userView: self.userView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Why this way?
        // There are easier ways to play a song, but this version give so much control over the audio samples, which is what we want for this class!
        if let graph = self.graph {
            graph.setBackgroundColor(r: 0, g: 0, b: 0, a: 1)
            
            graph.addGraph(withName: "equalizer",
                shouldNormalizeForFFT: true,
                numPointsInGraph: 20) // Miller
            
            graph.makeGrids() // Add grids to graph
        }
        
        // Run the loop for updating the graph periodically
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            self.updateGraph()
        }
        
        // starts graph data for listening to speakers
        audio.startSpeakerProcessing(withFps: 20)
        audio.startProcesingAudioFileForPlayback()
        audio.togglePlaying()
    }
    
    

    @IBAction func play(_ sender: UIButton) {
        audio.togglePlaying()
    }
    
    
    @IBAction func volumeChanged(_ sender: UISlider) {
        // set the volumen using the audio model, this controls the output block
        audio.setVolume(val: sender.value)
        // let the user know what the volume is!
        volumeLabel.text = String(format: "Volume: %.1f", sender.value )
    }
    
    func updateGraph(){
        print(self.audio.eqData)

        if let graph = self.graph{
            graph.updateGraph( //miller
                data: self.audio.eqData,
                forKey: "equalizer"
            )
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isBeingDismissed {
            self.audio.pause()
        }
    }
    
}

